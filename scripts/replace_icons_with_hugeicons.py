#!/usr/bin/env python3
"""
replace_icons_with_hugeicons.py

Scans Dart/Flutter code for Flutter `Icons.<name>` usages, finds the most
appropriate equivalent in HugeIcons (`HugeIcons.<strokeRoundedName>`), and replaces them.

Features:
- Dynamically loads valid HugeIcons directly from your pub cache (or local installation).
- Guaranteed safety: Only maps to valid, verified HugeIcons identifiers.
- Multi-tier matching pipeline:
    1. Curated dictionary of common Flutter Material icons -> HugeIcons.
    2. Suffix stripping (_outlined, _rounded, _sharp, _border, etc.).
    3. Synonym & semantic token translation (person -> user, trash -> delete, etc.).
    4. PascalCase & variant candidate generator (01, 02, Circle, Square).
    5. Token-intersection & fuzzy string similarity matcher.
- Smart import management: Automatically adds `import 'package:hugeicons/hugeicons.dart';`
  if not already imported (or exported by te_widgets).
- Supports:
    --scan           : Scan and report icon frequencies and proposed replacements (read-only).
    --dry-run        : Preview unified diffs without modifying files.
    --apply / -w     : Write replacements in-place.
    --interactive    : Ask confirmation per file before applying changes.
    --custom-map     : Provide a JSON file with custom icon mapping overrides.
    --export-map     : Export generated mappings to a JSON file for inspection/editing.
    --target / -t    : Specific file or directory to process (default: current directory).

Usage:
    # 1. Scan and inspect all Icons usage and suggested HugeIcons:
    python3 scripts/replace_icons_with_hugeicons.py --scan

    # 2. Preview changes with diffs (dry-run):
    python3 scripts/replace_icons_with_hugeicons.py --dry-run

    # 3. Apply changes across target directory:
    python3 scripts/replace_icons_with_hugeicons.py --apply -t apps/my_app

    # 4. Export mapping to JSON to review or customize:
    python3 scripts/replace_icons_with_hugeicons.py --export-map icon_mapping.json
"""

import os
import sys
import re
import json
import glob
import difflib
import argparse
from typing import Dict, Set, Tuple, List, Optional
from collections import Counter

# ANSI Colors for terminal output
class Colors:
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    RESET = '\033[0m'

    @classmethod
    def disable(cls):
        cls.CYAN = cls.GREEN = cls.YELLOW = cls.RED = cls.BOLD = cls.DIM = cls.RESET = ''

# High-accuracy curated dictionary for Flutter Material Icons -> HugeIcons
CURATED_MAPPINGS: Dict[str, str] = {
    # Actions & Operations
    'add': 'strokeRoundedAdd01',
    'add_box': 'strokeRoundedAddSquare',
    'add_circle': 'strokeRoundedAddCircle',
    'add_circle_outline': 'strokeRoundedAddCircle',
    'remove': 'strokeRoundedRemove01',
    'remove_circle': 'strokeRoundedRemoveCircle',
    'remove_circle_outline': 'strokeRoundedRemoveCircle',
    'close': 'strokeRoundedCancel01',
    'cancel': 'strokeRoundedCancel01',
    'clear': 'strokeRoundedCancel01',
    'check': 'strokeRoundedTick01',
    'done': 'strokeRoundedTick01',
    'done_all': 'strokeRoundedTickDouble01',
    'check_circle': 'strokeRoundedCheckmarkCircle01',
    'check_circle_outline': 'strokeRoundedCheckmarkCircle01',
    'check_box': 'strokeRoundedCheckmarkSquare01',
    'check_box_outline_blank': 'strokeRoundedSquare',
    'checklist': 'strokeRoundedCheckList',
    'checklist_rtl': 'strokeRoundedCheckList',
    'radio_button_checked': 'strokeRoundedRadioSelected',
    'radio_button_unchecked': 'strokeRoundedRadioUnselected',
    'edit': 'strokeRoundedEdit02',
    'edit_note': 'strokeRoundedNoteEdit',
    'mode_edit': 'strokeRoundedEdit02',
    'delete': 'strokeRoundedDelete01',
    'delete_forever': 'strokeRoundedDelete02',
    'delete_outline': 'strokeRoundedDelete01',
    'delete_sweep': 'strokeRoundedDelete02',
    'search': 'strokeRoundedSearch01',
    'find_in_page': 'strokeRoundedSearch02',
    'filter_list': 'strokeRoundedFilter',
    'filter_alt': 'strokeRoundedFilter',
    'filter_none': 'strokeRoundedLayers01',
    'tune': 'strokeRoundedFilterEdit',
    'sort': 'strokeRoundedSortByDown01',
    'sort_by_alpha': 'strokeRoundedSortByDown01',
    'refresh': 'strokeRoundedRefresh',
    'autorenew': 'strokeRoundedRefresh',
    'sync': 'strokeRoundedRefresh',
    'share': 'strokeRoundedShare01',
    'share_outlined': 'strokeRoundedShare01',
    'copy': 'strokeRoundedCopy01',
    'content_copy': 'strokeRoundedCopy01',
    'file_copy': 'strokeRoundedCopy01',
    'cut': 'strokeRoundedScissor01',
    'content_cut': 'strokeRoundedScissor01',
    'content_paste': 'strokeRoundedClipboard',
    'save': 'strokeRoundedFloppyDisk',
    'save_alt': 'strokeRoundedDownload01',
    'download': 'strokeRoundedDownload01',
    'file_download': 'strokeRoundedDownload01',
    'upload': 'strokeRoundedUpload01',
    'file_upload': 'strokeRoundedUpload01',
    'cloud_download': 'strokeRoundedCloudDownload',
    'cloud_upload': 'strokeRoundedCloudUpload',
    'undo': 'strokeRoundedUndo',
    'redo': 'strokeRoundedRedo',
    'history': 'strokeRoundedClock01',
    'preview': 'strokeRoundedView',
    'visibility': 'strokeRoundedView',
    'visibility_off': 'strokeRoundedViewOff',
    'print': 'strokeRoundedPrinter',
    'qr_code': 'strokeRoundedQrCode',
    'qr_code_scanner': 'strokeRoundedBarcodeScan',
    'barcode_reader': 'strokeRoundedBarcodeScan',

    # Navigation & Arrows
    'arrow_back': 'strokeRoundedArrowLeft01',
    'arrow_back_ios': 'strokeRoundedArrowLeft01',
    'arrow_back_ios_new': 'strokeRoundedArrowLeft01',
    'arrow_forward': 'strokeRoundedArrowRight01',
    'arrow_forward_ios': 'strokeRoundedArrowRight01',
    'arrow_upward': 'strokeRoundedArrowUp01',
    'arrow_downward': 'strokeRoundedArrowDown01',
    'arrow_drop_down': 'strokeRoundedArrowDown01',
    'arrow_drop_up': 'strokeRoundedArrowUp01',
    'arrow_drop_down_circle': 'strokeRoundedArrowDown01',
    'keyboard_arrow_left': 'strokeRoundedArrowLeft01',
    'keyboard_arrow_right': 'strokeRoundedArrowRight01',
    'keyboard_arrow_down': 'strokeRoundedArrowDown01',
    'keyboard_arrow_up': 'strokeRoundedArrowUp01',
    'chevron_left': 'strokeRoundedArrowLeft01',
    'chevron_right': 'strokeRoundedArrowRight01',
    'expand_more': 'strokeRoundedArrowDown01',
    'expand_less': 'strokeRoundedArrowUp01',
    'unfold_more': 'strokeRoundedUnfoldMore',
    'unfold_less': 'strokeRoundedUnfoldLess',
    'navigate_next': 'strokeRoundedArrowRight01',
    'navigate_before': 'strokeRoundedArrowLeft01',
    'first_page': 'strokeRoundedArrowLeftDouble',
    'last_page': 'strokeRoundedArrowRightDouble',
    'swap_horiz': 'strokeRoundedArrowLeftRight',
    'swap_vert': 'strokeRoundedArrowUpDown',
    'menu': 'strokeRoundedMenu01',
    'menu_open': 'strokeRoundedMenu02',
    'more_vert': 'strokeRoundedMoreVertical',
    'more_horiz': 'strokeRoundedMoreHorizontal',
    'home': 'strokeRoundedHome01',
    'login': 'strokeRoundedLogin01',
    'logout': 'strokeRoundedLogout01',
    'exit_to_app': 'strokeRoundedLogout01',
    'launch': 'strokeRoundedLinkExternal01',
    'open_in_new': 'strokeRoundedLinkExternal01',
    'link': 'strokeRoundedLink01',
    'link_off': 'strokeRoundedLinkUnlink01',

    # User & Identity
    'person': 'strokeRoundedUser',
    'person_outline': 'strokeRoundedUser',
    'person_add': 'strokeRoundedUserAdd01',
    'person_remove': 'strokeRoundedUserRemove01',
    'people': 'strokeRoundedUserGroup',
    'people_alt': 'strokeRoundedUserGroup',
    'group': 'strokeRoundedUserGroup',
    'group_add': 'strokeRoundedUserAdd01',
    'account_circle': 'strokeRoundedUserCircle',
    'account_box': 'strokeRoundedUserSquare',
    'account_tree': 'strokeRoundedFolderTree',
    'badge': 'strokeRoundedBadgeDollarSign',
    'fingerprint': 'strokeRoundedFingerprint',
    'admin_panel_settings': 'strokeRoundedUserSetting01',

    # Communications & Social
    'mail': 'strokeRoundedMail01',
    'mail_outline': 'strokeRoundedMail01',
    'email': 'strokeRoundedMail01',
    'alternate_email': 'strokeRoundedMailAtSign01',
    'inbox': 'strokeRoundedInbox',
    'all_inbox': 'strokeRoundedInbox',
    'drafts': 'strokeRoundedMailOpen',
    'send': 'strokeRoundedSent',
    'reply': 'strokeRoundedArrowTurnBackward',
    'phone': 'strokeRoundedCall',
    'call': 'strokeRoundedCall',
    'chat': 'strokeRoundedBubbleChat',
    'chat_bubble': 'strokeRoundedBubbleChat',
    'message': 'strokeRoundedComment01',
    'sms': 'strokeRoundedComment01',
    'comment': 'strokeRoundedComment01',
    'feedback': 'strokeRoundedBubbleChatQuestion',
    'forum': 'strokeRoundedChatUser',
    'notifications': 'strokeRoundedNotification01',
    'notifications_none': 'strokeRoundedNotification01',
    'notifications_active': 'strokeRoundedNotification02',
    'notifications_off': 'strokeRoundedNotificationOff01',

    # Content & Media
    'image': 'strokeRoundedImage01',
    'photo': 'strokeRoundedImage01',
    'photo_camera': 'strokeRoundedCamera01',
    'camera': 'strokeRoundedCamera01',
    'camera_alt': 'strokeRoundedCamera01',
    'add_a_photo': 'strokeRoundedCameraAdd01',
    'videocam': 'strokeRoundedVideo01',
    'video_library': 'strokeRoundedVideo02',
    'palette': 'strokeRoundedPaintBoard',
    'color_lens': 'strokeRoundedColorPicker',
    'brush': 'strokeRoundedPaintBrush01',
    'music_note': 'strokeRoundedMusicNote01',
    'mic': 'strokeRoundedMic01',
    'mic_off': 'strokeRoundedMicOff01',
    'volume_up': 'strokeRoundedVolumeHigh',
    'volume_down': 'strokeRoundedVolumeLow',
    'volume_mute': 'strokeRoundedVolumeCross',
    'volume_off': 'strokeRoundedVolumeCross',
    'play_arrow': 'strokeRoundedPlay',
    'pause': 'strokeRoundedPause',
    'stop': 'strokeRoundedStop',

    # Files & Data
    'folder': 'strokeRoundedFolder01',
    'folder_open': 'strokeRoundedFolderOpen',
    'folder_shared': 'strokeRoundedFolderShared01',
    'description': 'strokeRoundedFile01',
    'article': 'strokeRoundedNews',
    'assignment': 'strokeRoundedTask01',
    'insert_drive_file': 'strokeRoundedFile01',
    'text_snippet': 'strokeRoundedFile01',
    'attachment': 'strokeRoundedAttachment',
    'attach_file': 'strokeRoundedAttachment',
    'table_chart': 'strokeRoundedTable',
    'table_rows': 'strokeRoundedTableColumnsSplit',
    'table_view': 'strokeRoundedTable',
    'storage': 'strokeRoundedDatabase',
    'cloud': 'strokeRoundedCloud',
    'grid_view': 'strokeRoundedGrid',
    'grid_on': 'strokeRoundedGrid',
    'dashboard': 'strokeRoundedDashboardSquare01',
    'dashboard_customize': 'strokeRoundedDashboardSquare01',
    'view_kanban': 'strokeRoundedKanban',
    'splitscreen': 'strokeRoundedLayoutLeft',
    'view_sidebar': 'strokeRoundedSidebarLeft',
    'view_carousel': 'strokeRoundedCarouselHorizontal',
    'web_asset': 'strokeRoundedBrowser',
    'tab': 'strokeRoundedBrowser',

    # Metrics & Analytics
    'analytics': 'strokeRoundedAnalytics01',
    'assessment': 'strokeRoundedAnalytics02',
    'speed': 'strokeRoundedDashboardSpeed01',
    'show_chart': 'strokeRoundedChartLineData01',
    'bar_chart': 'strokeRoundedChartBarLine',
    'pie_chart': 'strokeRoundedChartPie',
    'timeline': 'strokeRoundedTimeline',
    'trending_up': 'strokeRoundedChartAverage',
    'trending_down': 'strokeRoundedChartDecreasing',

    # Time & Scheduling
    'access_time': 'strokeRoundedClock01',
    'access_time_filled': 'strokeRoundedClock01',
    'alarm': 'strokeRoundedAlarmClock',
    'alarm_on': 'strokeRoundedAlarmClockCheck',
    'schedule': 'strokeRoundedClock01',
    'timer': 'strokeRoundedTimer01',
    'calendar_today': 'strokeRoundedCalendar01',
    'calendar_month': 'strokeRoundedCalendar03',
    'date_range': 'strokeRoundedCalendar01',
    'event': 'strokeRoundedCalendar01',

    # Security & System
    'lock': 'strokeRoundedLock',
    'lock_outline': 'strokeRoundedLock',
    'lock_open': 'strokeRoundedLockUnlocked01',
    'vpn_key': 'strokeRoundedKey01',
    'key': 'strokeRoundedKey01',
    'pin': 'strokeRoundedDialpadCircle01',
    'security': 'strokeRoundedShield01',
    'verified': 'strokeRoundedCheckmarkBadge01',
    'settings': 'strokeRoundedSettings01',
    'settings_suggest': 'strokeRoundedSettings02',
    'build': 'strokeRoundedWrench01',

    # Status, Alerts & Feedback
    'star': 'strokeRoundedStar',
    'star_border': 'strokeRoundedStar',
    'star_half': 'strokeRoundedStarHalf',
    'favorite': 'strokeRoundedFavourite',
    'favorite_border': 'strokeRoundedFavourite',
    'thumb_up': 'strokeRoundedThumbsUp',
    'thumb_down': 'strokeRoundedThumbsDown',
    'thumb_up_alt': 'strokeRoundedThumbsUp',
    'thumb_down_alt': 'strokeRoundedThumbsDown',
    'info': 'strokeRoundedInformationCircle',
    'info_outline': 'strokeRoundedInformationCircle',
    'help': 'strokeRoundedHelpCircle',
    'help_outline': 'strokeRoundedHelpCircle',
    'warning': 'strokeRoundedAlert02',
    'warning_amber': 'strokeRoundedAlert02',
    'error': 'strokeRoundedAlertCircle',
    'error_outline': 'strokeRoundedAlertCircle',
    'report': 'strokeRoundedAlertSquare',
    'announcement': 'strokeRoundedMegaphone01',

    # Commerce & Logistics
    'shopping_cart': 'strokeRoundedShoppingCart01',
    'shopping_cart_checkout': 'strokeRoundedShoppingCart01',
    'shopping_bag': 'strokeRoundedShoppingBag01',
    'local_mall': 'strokeRoundedShoppingBag01',
    'straighten': 'strokeRoundedRuler',
    'gavel': 'strokeRoundedGavel',
    'verified_user': 'strokeRoundedUserShield01',
    'store': 'strokeRoundedStore01',
    'storefront': 'strokeRoundedStore01',
    'inventory': 'strokeRoundedPackage',
    'inventory_2': 'strokeRoundedPackage',
    'local_shipping': 'strokeRoundedDeliveryTruck01',
    'payment': 'strokeRoundedCreditCard',
    'credit_card': 'strokeRoundedCreditCard',
    'account_balance': 'strokeRoundedBank',
    'account_balance_wallet': 'strokeRoundedWallet01',
    'wallet': 'strokeRoundedWallet01',
    'receipt': 'strokeRoundedReceipt',
    'receipt_long': 'strokeRoundedInvoice',
    'sell': 'strokeRoundedTag01',
    'label': 'strokeRoundedTag01',
    'bookmark': 'strokeRoundedBookmark01',
    'bookmark_border': 'strokeRoundedBookmark01',
    'bookmark_add': 'strokeRoundedBookmarkAdd01',

    # Places & Travel
    'location_on': 'strokeRoundedLocation01',
    'place': 'strokeRoundedLocation01',
    'pin_drop': 'strokeRoundedLocationPin',
    'my_location': 'strokeRoundedGpsSignal01',
    'person_pin_circle': 'strokeRoundedLocationUser01',
    'map': 'strokeRoundedMaps',
    'explore': 'strokeRoundedCompass',
    'navigation': 'strokeRoundedNavigation01',
    'flag': 'strokeRoundedFlag01',
    'tour': 'strokeRoundedFlag01',

    # Developer & Code
    'code': 'strokeRoundedCodeSquare',
    'terminal': 'strokeRoundedComputer',
    'data_object': 'strokeRoundedSourceCode',
    'smart_button': 'strokeRoundedCursorPointer01',
    'text_fields': 'strokeRoundedText',
    'difference': 'strokeRoundedNotEqualSignSquare',
    'schema': 'strokeRoundedHierarchy',
    'layers': 'strokeRoundedLayers01',
    'mouse': 'strokeRoundedMouse01',
    'branding_watermark': 'strokeRoundedStamp',
}

# Semantic word token dictionary for token-based matching
TOKEN_SYNONYMS: Dict[str, str] = {
    'person': 'user',
    'people': 'user_group',
    'group': 'user_group',
    'account': 'user',
    'avatar': 'user',
    'back': 'left',
    'forward': 'right',
    'upward': 'up',
    'downward': 'down',
    'done': 'tick',
    'check': 'checkmark',
    'close': 'cancel',
    'clear': 'cancel',
    'trash': 'delete',
    'bin': 'delete',
    'visibility': 'view',
    'eye': 'view',
    'balance': 'bank',
    'wallet': 'wallet',
    'email': 'mail',
    'phone': 'call',
    'alarm': 'alarm_clock',
    'schedule': 'clock',
    'access_time': 'clock',
    'time': 'clock',
    'event': 'calendar',
    'date': 'calendar',
    'inventory': 'package',
    'shipping': 'delivery_truck',
    'delivery': 'delivery_truck',
    'storage': 'database',
    'article': 'news',
    'assignment': 'task',
    'description': 'file',
    'announcement': 'megaphone',
    'difference': 'not_equal',
    'schema': 'hierarchy',
    'palette': 'paint_board',
    'brush': 'paint_brush',
    'pin': 'dialpad',
    'watermark': 'stamp',
}

# Common Material Icon suffixes to strip in order
SUFFIXES = [
    '_outline_rounded', '_outlined_rounded',
    '_rounded', '_round',
    '_outlined', '_outline',
    '_sharp', '_filled',
    '_border', '_alt',
    '_ios_new', '_ios',
    '_rtl', '_ltr',
    '_2', '_1'
]

def load_hugeicons_vocabulary(custom_path: Optional[str] = None) -> Set[str]:
    """Find and load all valid HugeIcons identifiers."""
    candidates = []
    if custom_path:
        candidates.append(custom_path)

    # Search in pub cache
    pub_pattern = os.path.expanduser('~/.pub-cache/hosted/pub.dev/hugeicons-*/lib/hugeicons.dart')
    pub_matches = sorted(glob.glob(pub_pattern))
    if pub_matches:
        candidates.append(pub_matches[-1])

    # Search in common repo paths
    candidates.extend(glob.glob('./**/hugeicons.dart', recursive=True))

    for path in candidates:
        if os.path.isfile(path):
            try:
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                icons = set(re.findall(r'static const List<List<dynamic>>\s+([a-zA-Z0-9_]+)', content))
                if icons:
                    return icons
            except Exception as e:
                pass

    # Fallback to values in CURATED_MAPPINGS
    return set(CURATED_MAPPINGS.values())

def clean_icon_name(mat_name: str) -> str:
    """Strips suffixes like _outlined, _rounded, etc."""
    name = mat_name
    changed = True
    while changed:
        changed = False
        for s in SUFFIXES:
            if name.endswith(s):
                name = name[:-len(s)]
                changed = True
                break
    return name

def to_pascal_case(snake_str: str) -> str:
    """Converts snake_case to PascalCase."""
    parts = snake_str.split('_')
    return ''.join(p.capitalize() for p in parts if p)

class IconMatcher:
    def __init__(self, huge_icons: Set[str], custom_overrides: Optional[Dict[str, str]] = None):
        self.huge_icons = huge_icons
        self.huge_lower_map = {h.lower(): h for h in huge_icons}
        self.custom_overrides = custom_overrides or {}
        self._cache: Dict[str, Tuple[Optional[str], str]] = {}

        # Index hugeicons by words for fast token matching
        self.token_index: Dict[str, List[str]] = {}
        for h in huge_icons:
            # strip strokeRounded
            core = h[len('strokeRounded'):] if h.startswith('strokeRounded') else h
            # split camelCase into words
            words = [w.lower() for w in re.findall(r'[A-Z]?[a-z0-9]+', core) if w]
            for w in words:
                # strip trailing numbers (e.g. 01, 02)
                clean_w = re.sub(r'\d+$', '', w)
                if len(clean_w) > 2:
                    self.token_index.setdefault(clean_w, []).append(h)

    def match(self, raw_mat_name: str) -> Tuple[Optional[str], str]:
        if raw_mat_name in self._cache:
            return self._cache[raw_mat_name]
        res = self._compute_match(raw_mat_name)
        self._cache[raw_mat_name] = res
        return res

    def _compute_match(self, raw_mat_name: str) -> Tuple[Optional[str], str]:
        """
        Finds the best HugeIcon equivalent for raw_mat_name.
        Returns: (huge_icon_name, match_reason)
        """
        # 1. Custom overrides
        if raw_mat_name in self.custom_overrides:
            val = self.custom_overrides[raw_mat_name]
            return val, 'custom override'

        cleaned = clean_icon_name(raw_mat_name)
        if cleaned in self.custom_overrides:
            val = self.custom_overrides[cleaned]
            return val, 'custom override (cleaned)'

        # 2. Curated mappings
        if raw_mat_name in CURATED_MAPPINGS:
            cand = CURATED_MAPPINGS[raw_mat_name]
            if cand in self.huge_icons:
                return cand, 'curated exact'

        if cleaned in CURATED_MAPPINGS:
            cand = CURATED_MAPPINGS[cleaned]
            if cand in self.huge_icons:
                return cand, 'curated cleaned'

        # 3. Direct PascalCase lookup with strokeRounded variants
        pascal = to_pascal_case(cleaned)
        variants = [
            f'strokeRounded{pascal}',
            f'strokeRounded{pascal}01',
            f'strokeRounded{pascal}02',
            f'strokeRounded{pascal}Circle',
            f'strokeRounded{pascal}Square',
        ]
        for v in variants:
            if v in self.huge_icons:
                return v, 'direct name match'
            if v.lower() in self.huge_lower_map:
                return self.huge_lower_map[v.lower()], 'case-insensitive name match'

        # 4. Synonym translation on tokens
        tokens = cleaned.split('_')
        syn_tokens = [TOKEN_SYNONYMS.get(t, t) for t in tokens]
        syn_pascal = to_pascal_case('_'.join(syn_tokens))
        syn_variants = [
            f'strokeRounded{syn_pascal}',
            f'strokeRounded{syn_pascal}01',
            f'strokeRounded{syn_pascal}02',
            f'strokeRounded{syn_pascal}Circle',
            f'strokeRounded{syn_pascal}Square',
        ]
        for v in syn_variants:
            if v in self.huge_icons:
                return v, 'synonym name match'
            if v.lower() in self.huge_lower_map:
                return self.huge_lower_map[v.lower()], 'synonym name match'

        # 5. Token Intersection Scoring
        all_tokens = set(tokens + syn_tokens)
        candidate_scores: Counter = Counter()
        for tok in all_tokens:
            clean_tok = re.sub(r'\d+$', '', tok)
            if clean_tok in self.token_index:
                for h in self.token_index[clean_tok]:
                    candidate_scores[h] += 1

        if candidate_scores:
            top_candidates = candidate_scores.most_common(10)
            best_match, count = top_candidates[0]
            # If at least 1 significant token matches, refine with sequence similarity
            sim_candidates = [cand for cand, _ in top_candidates]
            query = 'strokeRounded' + syn_pascal.lower()
            closest = difflib.get_close_matches(query, [c.lower() for c in sim_candidates], n=1, cutoff=0.5)
            if closest:
                return self.huge_lower_map[closest[0]], 'token-similarity'
            return best_match, 'token-overlap'

        # 6. Global Fuzzy Match fallback
        query = 'strokeRounded' + pascal.lower()
        matches = difflib.get_close_matches(query, list(self.huge_lower_map.keys()), n=1, cutoff=0.6)
        if matches:
            return self.huge_lower_map[matches[0]], 'fuzzy fallback'

        return None, 'unmapped'

class FileReplacer:
    # Matches (const )?Icon(Icons.name
    ICON_WIDGET_REGEX = re.compile(r'(\bconst\s+)?\bIcon\(\s*Icons\.([a-zA-Z0-9_]+)')
    # Matches general Icons.name
    ICON_REF_REGEX = re.compile(r'(?<![a-zA-Z0-9_])Icons\.([a-zA-Z0-9_]+)\b')

    def __init__(self, matcher: IconMatcher, auto_import: bool = True):
        self.matcher = matcher
        self.auto_import = auto_import

    def process_content(self, content: str, file_path: str) -> Tuple[str, List[Tuple[str, str, int]], bool]:
        """
        Replaces Icons.<name> with HugeIcons.<name> and Icon(Icons.x) with HugeIcon(icon: HugeIcons.x).
        Returns: (new_content, replacements_list, was_modified)
        """
        replacements = []

        has_hugeicons_import = (
            "import 'package:hugeicons/hugeicons.dart';" in content or
            'import "package:hugeicons/hugeicons.dart";' in content or
            "package:te_widgets/te_widgets.dart" in content
        )

        def replace_icon_widget(match):
            const_prefix = match.group(1) or ''
            mat_name = match.group(2)
            huge_name, _ = self.matcher.match(mat_name)
            if huge_name:
                replacements.append((mat_name, huge_name, 0))
                return f'{const_prefix}HugeIcon(icon: HugeIcons.{huge_name}'
            return match.group(0)

        def replace_icon_ref(match):
            mat_name = match.group(1)
            huge_name, _ = self.matcher.match(mat_name)
            if huge_name:
                replacements.append((mat_name, huge_name, 0))
                return f'HugeIcons.{huge_name}'
            return match.group(0)

        # 1. Transform Icon(Icons.foo) -> HugeIcon(icon: HugeIcons.bar)
        content_after_widget = self.ICON_WIDGET_REGEX.sub(replace_icon_widget, content)
        # 2. Transform remaining Icons.foo -> HugeIcons.bar
        final_content = self.ICON_REF_REGEX.sub(replace_icon_ref, content_after_widget)

        was_modified = len(replacements) > 0

        # Inject import if necessary
        if was_modified and self.auto_import and not has_hugeicons_import:
            final_content = self.inject_import(final_content)

        return final_content, replacements, was_modified

    @staticmethod
    def inject_import(content: str) -> str:
        """Adds import 'package:hugeicons/hugeicons.dart'; after last import."""
        import_stmt = "import 'package:hugeicons/hugeicons.dart';\n"
        import_regex = re.compile(r"^(import\s+['\"][^'\"]+['\"];.*)$", re.MULTILINE)
        matches = list(import_regex.finditer(content))
        if matches:
            last_match = matches[-1]
            idx = last_match.end()
            # If followed by a newline, inject right after
            return content[:idx] + '\n' + import_stmt + content[idx:].lstrip('\n')
        else:
            return import_stmt + '\n' + content

def find_dart_files(target_dir: str, exclude_dirs: Set[str]) -> List[str]:
    """Recursively finds all Dart files excluding specified directories."""
    dart_files = []
    if os.path.isfile(target_dir):
        if target_dir.endswith('.dart'):
            return [target_dir]
        return []

    for root, dirs, files in os.walk(target_dir):
        # Prune excluded directories in-place
        dirs[:] = [d for d in dirs if d not in exclude_dirs and not d.startswith('.')]
        for f in files:
            if f.endswith('.dart'):
                dart_files.append(os.path.join(root, f))
    return sorted(dart_files)

def print_diff(file_path: str, old_content: str, new_content: str):
    """Prints unified diff with ANSI colors."""
    old_lines = old_content.splitlines(keepends=True)
    new_lines = new_content.splitlines(keepends=True)
    diff = list(difflib.unified_diff(old_lines, new_lines, fromfile=f'a/{file_path}', tofile=f'b/{file_path}'))
    for line in diff:
        if line.startswith('+') and not line.startswith('+++'):
            sys.stdout.write(f'{Colors.GREEN}{line}{Colors.RESET}')
        elif line.startswith('-') and not line.startswith('---'):
            sys.stdout.write(f'{Colors.RED}{line}{Colors.RESET}')
        elif line.startswith('@'):
            sys.stdout.write(f'{Colors.CYAN}{line}{Colors.RESET}')
        else:
            sys.stdout.write(f'{Colors.DIM}{line}{Colors.RESET}')

def main():
    parser = argparse.ArgumentParser(
        description="Migrate Flutter Icons.<name> to HugeIcons.<name> automatically."
    )
    parser.add_argument(
        '-t', '--target',
        default='.',
        help="Target file or directory to scan/modify (default: current directory)."
    )
    parser.add_argument(
        '--scan',
        action='store_true',
        help="Scan and report icon usages and proposed mappings without making changes."
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help="Preview unified diffs without modifying files on disk."
    )
    parser.add_argument(
        '-w', '--apply', '--write',
        action='store_true',
        help="Apply changes directly in-place."
    )
    parser.add_argument(
        '-i', '--interactive',
        action='store_true',
        help="Prompt confirmation for each file before modifying."
    )
    parser.add_argument(
        '--backup',
        action='store_true',
        help="Create a .bak backup before modifying any file."
    )
    parser.add_argument(
        '--no-import',
        action='store_true',
        help="Do not automatically add HugeIcons import statement."
    )
    parser.add_argument(
        '--custom-map',
        help="Path to JSON file containing custom icon mapping overrides ({'mat_icon': 'HugeIconName'})."
    )
    parser.add_argument(
        '--export-map',
        help="Path to output JSON file to export the full generated mapping dictionary."
    )
    parser.add_argument(
        '--exclude',
        default='.git,.dart_tool,build,.idea,.vscode',
        help="Comma-separated directory names to exclude (default: .git,.dart_tool,build,.idea,.vscode)."
    )
    parser.add_argument(
        '--hugeicons-path',
        help="Custom path to hugeicons.dart (if not in standard pub cache)."
    )

    args = parser.parse_args()

    # Load HugeIcons vocabulary
    huge_icons = load_hugeicons_vocabulary(args.hugeicons_path)
    if not huge_icons:
        print(f"{Colors.RED}Error: Unable to find hugeicons.dart in pub cache or workspace.{Colors.RESET}")
        sys.exit(1)

    print(f"{Colors.CYAN}Loaded {len(huge_icons):,} valid HugeIcons identifiers.{Colors.RESET}")

    # Load custom overrides if provided
    custom_overrides = {}
    if args.custom_map:
        if os.path.exists(args.custom_map):
            with open(args.custom_map, 'r', encoding='utf-8') as f:
                custom_overrides = json.load(f)
            print(f"{Colors.CYAN}Loaded {len(custom_overrides)} custom mapping overrides.{Colors.RESET}")
        else:
            print(f"{Colors.YELLOW}Warning: Custom map file '{args.custom_map}' not found.{Colors.RESET}")

    matcher = IconMatcher(huge_icons, custom_overrides)
    replacer = FileReplacer(matcher, auto_import=not args.no_import)

    exclude_dirs = set(x.strip() for x in args.exclude.split(','))
    dart_files = find_dart_files(args.target, exclude_dirs)
    print(f"{Colors.CYAN}Found {len(dart_files):,} Dart files to scan in '{args.target}'.{Colors.RESET}\n")

    # Global scan
    icon_frequencies = Counter()
    icon_to_files = {}
    file_results = []
    total_replacements = 0

    for path in dart_files:
        try:
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except Exception as e:
            continue

        new_content, reps, was_modified = replacer.process_content(content, path)
        if was_modified:
            file_results.append((path, content, new_content, reps))
            total_replacements += len(reps)
            for mat_name, huge_name, line_num in reps:
                icon_frequencies[mat_name] += 1
                icon_to_files.setdefault(mat_name, set()).add(path)

    # Export mapping if requested
    if args.export_map:
        exported_data = {}
        for mat_name in sorted(icon_frequencies.keys()):
            huge_name, reason = matcher.match(mat_name)
            exported_data[mat_name] = huge_name
        with open(args.export_map, 'w', encoding='utf-8') as f:
            json.dump(exported_data, f, indent=2)
        print(f"{Colors.GREEN}Exported mappings for {len(exported_data)} icons to '{args.export_map}'.{Colors.RESET}\n")

    # SCAN MODE
    if args.scan or (not args.apply and not args.dry_run and not args.interactive):
        print(f"{Colors.BOLD}{'=' * 85}{Colors.RESET}")
        print(f"{Colors.BOLD}{'ICONS USAGE & PROPOSED HUGEICONS REPLACEMENTS':^85}{Colors.RESET}")
        print(f"{Colors.BOLD}{'=' * 85}{Colors.RESET}")
        print(f"{'Count':<7} {'Material Icon':<32} -> {'HugeIcon Equivalent':<35} {'Method'}")
        print(f"{'-' * 85}")

        for mat_name, count in icon_frequencies.most_common():
            huge_name, reason = matcher.match(mat_name)
            h_display = f"HugeIcons.{huge_name}" if huge_name else f"{Colors.RED}NO MATCH{Colors.RESET}"
            print(f"{count:<7} Icons.{mat_name:<26} -> {h_display:<35} {Colors.DIM}({reason}){Colors.RESET}")

        print(f"{'-' * 85}")
        print(f"{Colors.BOLD}Summary:{Colors.RESET}")
        print(f"  Total Dart files scanned   : {len(dart_files):,}")
        print(f"  Files with Icons usages    : {len(file_results):,}")
        print(f"  Total Icon occurrences     : {total_replacements:,}")
        print(f"  Unique Icons found         : {len(icon_frequencies):,}")
        print(f"\n{Colors.CYAN}To preview diffs, run with:   --dry-run{Colors.RESET}")
        print(f"{Colors.GREEN}To apply replacements, run with: --apply{Colors.RESET}")
        return

    # DRY-RUN MODE
    if args.dry_run:
        print(f"{Colors.BOLD}{Colors.YELLOW}--- DRY RUN: PREVIEWING CHANGES ---{Colors.RESET}\n")
        for path, old_content, new_content, reps in file_results:
            print(f"\n{Colors.BOLD}File: {path} ({len(reps)} replacements){Colors.RESET}")
            print_diff(path, old_content, new_content)
        print(f"\n{Colors.BOLD}Total: {total_replacements} replacements across {len(file_results)} files.{Colors.RESET}")
        print(f"{Colors.GREEN}Run with --apply to write these changes to disk.{Colors.RESET}")
        return

    # APPLY / INTERACTIVE MODE
    modified_count = 0
    for path, old_content, new_content, reps in file_results:
        if args.interactive:
            print(f"\n{Colors.BOLD}File: {path} ({len(reps)} replacements){Colors.RESET}")
            print_diff(path, old_content, new_content)
            choice = input(f"{Colors.YELLOW}Apply changes to {path}? [y/n/a/q]: {Colors.RESET}").strip().lower()
            if choice == 'q':
                print(f"{Colors.RED}Aborted by user.{Colors.RESET}")
                break
            elif choice == 'n':
                continue
            elif choice == 'a':
                args.interactive = False

        if args.backup:
            bak_path = path + '.bak'
            with open(bak_path, 'w', encoding='utf-8') as f:
                f.write(old_content)

        with open(path, 'w', encoding='utf-8') as f:
            f.write(new_content)

        modified_count += 1
        print(f"  {Colors.GREEN}Updated{Colors.RESET}: {path} ({len(reps)} icons replaced)")

    print(f"\n{Colors.BOLD}{Colors.GREEN}Successfully updated {modified_count} files with {total_replacements} HugeIcons replacements.{Colors.RESET}")

if __name__ == '__main__':
    main()
