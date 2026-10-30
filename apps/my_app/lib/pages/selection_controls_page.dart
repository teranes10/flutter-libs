import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

/// Documentation page showcasing selection controls and option tiles:
/// TOptionTile, Checkboxes, Radio Groups, and Switches (both standard and 56dp tile mode).
class SelectionControlsPage extends StatefulWidget {
  const SelectionControlsPage({super.key});

  @override
  State<SelectionControlsPage> createState() => _SelectionControlsPageState();
}

class _SelectionControlsPageState extends State<SelectionControlsPage> {
  // OptionTile interactive demo state
  String _selectedPayment = 'card';
  final Set<String> _selectedAddons = {'insurance', 'tracking'};
  bool _optInUpdates = true;

  // Checkbox notifiers
  final _termsNotifier = ValueNotifier<bool?>(false);
  final _interestsNotifier = ValueNotifier<List<String>>(['Technology']);
  final _tileSkillsNotifier = ValueNotifier<List<String>>(['express', 'fragile']);

  // Radio notifiers
  final _contactMethodNotifier = ValueNotifier<String?>('email');
  final _deliverySpeedNotifier = ValueNotifier<String?>('standard');

  // Switch notifiers
  final _notificationsNotifier = ValueNotifier<bool>(false);
  final _offlineSyncNotifier = ValueNotifier<bool>(true);
  final _biometricsNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _termsNotifier.dispose();
    _interestsNotifier.dispose();
    _tileSkillsNotifier.dispose();
    _contactMethodNotifier.dispose();
    _deliverySpeedNotifier.dispose();
    _notificationsNotifier.dispose();
    _offlineSyncNotifier.dispose();
    _biometricsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Text(
            'Selection Controls & Option Tiles',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Checkboxes, radio groups, toggle switches, and touch-friendly 56dp option tiles for web, mobile, and handheld field interfaces.',
            style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),

          // ==================== OPTION TILE (TOPTIONTILE) ====================

          // Interactive OptionTile Archetypes
          WidgetDocCard(
            title: 'Option Tiles (TOptionTile)',
            description:
                'Full-width touch-friendly rows (min 56dp height) with leading icons, labels, descriptions, and radio/check/toggle indicators.',
            icon: HugeIcons.strokeRoundedAiView,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Single Choice (Radio Indicator)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.onSurface),
                ),
                const SizedBox(height: 8),
                TOptionTile(
                  label: 'Credit / Debit Card',
                  description: 'Pay securely with Visa, Mastercard, or Amex',
                  leading: TIcon.raw(HugeIcons.strokeRoundedCreditCard),
                  indicator: TOptionIndicator.radio,
                  selected: _selectedPayment == 'card',
                  onTap: () => setState(() => _selectedPayment = 'card'),
                ),
                const SizedBox(height: 8),
                TOptionTile(
                  label: 'Digital Wallet',
                  description: 'Apple Pay, Google Pay, or PayPal',
                  leading: TIcon.raw(HugeIcons.strokeRoundedWallet01),
                  indicator: TOptionIndicator.radio,
                  selected: _selectedPayment == 'wallet',
                  onTap: () => setState(() => _selectedPayment = 'wallet'),
                ),
                const SizedBox(height: 20),
                Text(
                  'Multiple Choice (Check Indicator)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.onSurface),
                ),
                const SizedBox(height: 8),
                TOptionTile(
                  label: 'Package Insurance',
                  description: 'Full coverage for loss or damage during transit',
                  leading: TIcon.raw(HugeIcons.strokeRoundedShield01),
                  indicator: TOptionIndicator.check,
                  selected: _selectedAddons.contains('insurance'),
                  onTap: () {
                    setState(() {
                      if (_selectedAddons.contains('insurance')) {
                        _selectedAddons.remove('insurance');
                      } else {
                        _selectedAddons.add('insurance');
                      }
                    });
                  },
                ),
                const SizedBox(height: 8),
                TOptionTile(
                  label: 'Real-time GPS Tracking',
                  description: 'Live courier updates sent via SMS & push',
                  leading: TIcon.raw(HugeIcons.strokeRoundedLocation01),
                  indicator: TOptionIndicator.check,
                  selected: _selectedAddons.contains('tracking'),
                  onTap: () {
                    setState(() {
                      if (_selectedAddons.contains('tracking')) {
                        _selectedAddons.remove('tracking');
                      } else {
                        _selectedAddons.add('tracking');
                      }
                    });
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Toggle Switch Indicator',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.onSurface),
                ),
                const SizedBox(height: 8),
                TOptionTile(
                  label: 'Order Status Alerts',
                  description: 'Receive SMS updates when package status changes',
                  leading: TIcon.raw(HugeIcons.strokeRoundedNotification02),
                  indicator: TOptionIndicator.toggle,
                  selected: _optInUpdates,
                  onTap: () => setState(() => _optInUpdates = !_optInUpdates),
                ),
              ],
            ),
            code: '''// Radio Indicator (Single Choice)
TOptionTile(
  label: 'Credit / Debit Card',
  description: 'Pay securely with Visa, Mastercard, or Amex',
  leading: const HugeIcon(icon: HugeIcons.strokeRoundedCreditCard),
  indicator: TOptionIndicator.radio,
  selected: selectedPayment == 'card',
  onTap: () => setState(() => selectedPayment = 'card'),
)

// Check Indicator (Multiple Choice)
TOptionTile(
  label: 'Package Insurance',
  description: 'Full coverage for loss or damage during transit',
  leading: const HugeIcon(icon: HugeIcons.strokeRoundedShield01),
  indicator: TOptionIndicator.check,
  selected: selectedAddons.contains('insurance'),
  onTap: () => toggleAddon('insurance'),
)

// Toggle Indicator (On / Off)
TOptionTile(
  label: 'Order Status Alerts',
  description: 'Receive SMS updates when package status changes',
  leading: const HugeIcon(icon: HugeIcons.strokeRoundedNotification02),
  indicator: TOptionIndicator.toggle,
  selected: isEnabled,
  onTap: () => setState(() => isEnabled = !isEnabled),
)''',
            properties: const [
              PropertyDoc(name: 'label', type: 'String', isRequired: true, description: 'Primary text displayed on the tile'),
              PropertyDoc(name: 'description', type: 'String?', description: 'Secondary text displayed underneath the label'),
              PropertyDoc(name: 'leading', type: 'Widget?', description: 'Optional leading widget (e.g. an icon or avatar)'),
              PropertyDoc(
                name: 'selected',
                type: 'bool',
                isRequired: true,
                description: 'Whether the option tile is currently active / selected',
              ),
              PropertyDoc(
                name: 'indicator',
                type: 'TOptionIndicator',
                defaultValue: 'TOptionIndicator.radio',
                description: 'Selection indicator drawn on the right (radio, check, or toggle)',
              ),
              PropertyDoc(name: 'color', type: 'Color?', description: 'Accent color for active background and border'),
              PropertyDoc(
                name: 'disabled',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether the tile is disabled with dimmed opacity',
              ),
              PropertyDoc(name: 'onTap', type: 'VoidCallback?', description: 'Callback fired on tap with haptic feedback'),
            ],
          ),

          // OptionTile Variants and States
          WidgetDocCard(
            title: 'Option Tile States & Colors',
            description: 'Custom accent colors, disabled state, and compact vs rich content support.',
            icon: HugeIcons.strokeRoundedPaintBoard,
            preview: Column(
              children: [
                TOptionTile(
                  label: 'Custom Emerald Accent',
                  description: 'Highlighted with custom emerald green branding',
                  leading: TIcon.raw(HugeIcons.strokeRoundedEcoLab, color: Colors.teal),
                  indicator: TOptionIndicator.check,
                  color: Colors.teal,
                  selected: true,
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                TOptionTile(
                  label: 'Disabled Option Tile',
                  description: 'Cannot be interacted with (read-only / unavailable)',
                  leading: TIcon.raw(HugeIcons.strokeRoundedLock),
                  indicator: TOptionIndicator.radio,
                  selected: false,
                  disabled: true,
                ),
                const SizedBox(height: 8),
                TOptionTile(label: 'Compact Title Only (No Description)', indicator: TOptionIndicator.radio, selected: true, onTap: () {}),
              ],
            ),
            code: '''// Custom Accent Color
TOptionTile(
  label: 'Custom Emerald Accent',
  description: 'Highlighted with custom emerald green branding',
  color: Colors.teal,
  selected: true,
  onTap: () {},
)

// Disabled State
TOptionTile(
  label: 'Disabled Option Tile',
  description: 'Cannot be interacted with',
  disabled: true,
  selected: false,
)''',
          ),

          // ==================== TILE MODE GROUPS ====================

          // Checkbox Group in Tile Mode
          WidgetDocCard(
            title: 'Checkbox Group in Tile Mode',
            description: 'TCheckboxGroup with tile: true renders each choice as a 56dp TOptionTile, ideal for touch and handheld screens.',
            icon: HugeIcons.strokeRoundedCheckList,
            preview: TCheckboxGroup<String>(
              label: 'Dispatch Options',
              tile: true,
              clearable: true,
              valueNotifier: _tileSkillsNotifier,
              items: const [
                TCheckboxGroupItem(value: 'express', label: 'Express Delivery'),
                TCheckboxGroupItem(value: 'fragile', label: 'Fragile Handling'),
                TCheckboxGroupItem(value: 'signature', label: 'Signature Required on Delivery'),
                TCheckboxGroupItem(value: 'weekend', label: 'Weekend Delivery Permitted'),
              ],
            ),
            code: '''TCheckboxGroup<String>(
  label: 'Dispatch Options',
  tile: true, // Renders each option as a 56dp TOptionTile
  clearable: true,
  valueNotifier: selectedNotifier,
  items: const [
    TCheckboxGroupItem(value: 'express', label: 'Express Delivery'),
    TCheckboxGroupItem(value: 'fragile', label: 'Fragile Handling'),
    TCheckboxGroupItem(value: 'signature', label: 'Signature Required on Delivery'),
    TCheckboxGroupItem(value: 'weekend', label: 'Weekend Delivery Permitted'),
  ],
  onValueChanged: (selected) => print(selected),
)''',
            properties: const [
              PropertyDoc(
                name: 'tile',
                type: 'bool',
                defaultValue: 'false',
                description: 'Renders each option as a full-width 56dp selectable TOptionTile (always vertical)',
              ),
              PropertyDoc(
                name: 'clearable',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether to show a clear button when items are selected',
              ),
              PropertyDoc(
                name: 'items',
                type: 'List<TCheckboxGroupItem<T>>',
                isRequired: true,
                description: 'List of checkbox group items',
              ),
              PropertyDoc(name: 'valueNotifier', type: 'ValueNotifier<List<T>?>?', description: 'Two-way binding notifier'),
            ],
          ),

          // Radio Group in Tile Mode
          WidgetDocCard(
            title: 'Radio Group in Tile Mode',
            description: 'TRadioGroup with tile: true renders a vertical list of 56dp touch-friendly single-selection tiles.',
            icon: HugeIcons.strokeRoundedRadioButton,
            preview: TRadioGroup<String>(
              label: 'Shipping Speed',
              tile: true,
              valueNotifier: _deliverySpeedNotifier,
              items: const [
                TRadioGroupItem(value: 'economy', label: 'Economy (5-7 business days)'),
                TRadioGroupItem(value: 'standard', label: 'Standard (2-3 business days)'),
                TRadioGroupItem(value: 'priority', label: 'Priority Overnight (Next day by 10:30 AM)'),
              ],
            ),
            code: '''TRadioGroup<String>(
  label: 'Shipping Speed',
  tile: true, // Renders each option as a 56dp TOptionTile
  valueNotifier: deliverySpeedNotifier,
  items: const [
    TRadioGroupItem(value: 'economy', label: 'Economy (5-7 business days)'),
    TRadioGroupItem(value: 'standard', label: 'Standard (2-3 business days)'),
    TRadioGroupItem(value: 'priority', label: 'Priority Overnight (Next day by 10:30 AM)'),
  ],
  onValueChanged: (value) => print(value),
)''',
            properties: const [
              PropertyDoc(
                name: 'tile',
                type: 'bool',
                defaultValue: 'false',
                description: 'Renders each option as a full-width 56dp selectable TOptionTile (always vertical)',
              ),
              PropertyDoc(name: 'items', type: 'List<TRadioGroupItem<T>>', isRequired: true, description: 'List of radio items'),
              PropertyDoc(name: 'valueNotifier', type: 'ValueNotifier<T?>?', description: 'Two-way binding notifier for selected value'),
            ],
          ),

          // Switch in Tile Mode
          WidgetDocCard(
            title: 'Switch in Tile Mode',
            description: 'TSwitch with tile: true renders a full-width 56dp tile with label, description, and toggle indicator.',
            icon: HugeIcons.strokeRoundedToggleOn,
            preview: Column(
              children: [
                TSwitch(
                  tile: true,
                  label: 'Offline Data Sync',
                  description: 'Keep local queue synchronized when connectivity returns',
                  valueNotifier: _offlineSyncNotifier,
                ),
                const SizedBox(height: 8),
                TSwitch(
                  tile: true,
                  label: 'Biometric Authentication',
                  description: 'Require Face ID or fingerprint scan before app launch',
                  valueNotifier: _biometricsNotifier,
                ),
              ],
            ),
            code: '''TSwitch(
  tile: true, // Renders as full-width 56dp TOptionTile
  label: 'Offline Data Sync',
  description: 'Keep local queue synchronized when connectivity returns',
  valueNotifier: offlineSyncNotifier,
  onValueChanged: (value) => print('Offline sync: \$value'),
)

TSwitch(
  tile: true,
  label: 'Biometric Authentication',
  description: 'Require Face ID or fingerprint scan before app launch',
  valueNotifier: biometricsNotifier,
)''',
            properties: const [
              PropertyDoc(
                name: 'tile',
                type: 'bool',
                defaultValue: 'false',
                description: 'Renders switch as a full-width 56dp TOptionTile with label/description on left and switch on right',
              ),
              PropertyDoc(name: 'description', type: 'String?', description: 'Secondary text displayed under the label in tile mode'),
              PropertyDoc(name: 'label', type: 'String?', description: 'Primary label text'),
              PropertyDoc(name: 'valueNotifier', type: 'ValueNotifier<bool?>?', description: 'Two-way binding notifier'),
            ],
          ),

          // ==================== STANDARD CHECKBOX ====================

          // Basic Checkbox
          WidgetDocCard(
            title: 'Checkbox',
            description: 'Single checkbox for boolean selection',
            icon: HugeIcons.strokeRoundedCheckmarkSquare01,
            preview: TCheckbox(label: 'I agree to the terms and conditions', valueNotifier: _termsNotifier),
            code: '''TCheckbox(
  label: 'I agree to the terms and conditions',
  onValueChanged: (value) {
    print('Checked: \$value');
  },
)''',
            properties: const [
              PropertyDoc(name: 'label', type: 'String?', description: 'Label text displayed next to the checkbox'),
              PropertyDoc(name: 'value', type: 'bool?', description: 'Current checkbox state (true, false, or null for indeterminate)'),
              PropertyDoc(name: 'onValueChanged', type: 'ValueChanged<bool?>?', description: 'Callback fired when checkbox state changes'),
            ],
          ),

          // Checkbox with Info
          WidgetDocCard(
            title: 'Checkbox with Info Tooltip',
            description: 'Checkbox with informational tooltip next to label',
            icon: HugeIcons.strokeRoundedInformationCircle,
            preview: TCheckbox(
              label: 'Subscribe to newsletter',
              info: 'We send weekly updates about new features and releases',
              valueNotifier: ValueNotifier<bool?>(false),
            ),
            code: '''TCheckbox(
  label: 'Subscribe to newsletter',
  info: 'We send weekly updates about new features and releases',
  onValueChanged: (value) {
    print('Subscribed: \$value');
  },
)''',
            properties: const [
              PropertyDoc(name: 'info', type: 'String?', description: 'Informational text displayed in a tooltip next to the label'),
            ],
          ),

          // Checkbox with Validation
          WidgetDocCard(
            title: 'Required Checkbox with Validation',
            description: 'Checkbox with required validation',
            icon: HugeIcons.strokeRoundedCheckmarkBadge01,
            preview: TCheckbox(
              label: 'I accept the privacy policy',
              isRequired: true,
              valueNotifier: ValueNotifier<bool?>(false),
              rules: [
                (value) {
                  if (value != true) return 'You must accept the privacy policy';
                  return null;
                },
              ],
            ),
            code: '''TCheckbox(
  label: 'I accept the privacy policy',
  isRequired: true,
  rules: [
    (value) {
      if (value != true) return 'You must accept the privacy policy';
      return null;
    },
  ],
  onValueChanged: (value) => print(value),
)''',
            properties: const [
              PropertyDoc(name: 'isRequired', type: 'bool', defaultValue: 'false', description: 'Whether the checkbox is required'),
              PropertyDoc(name: 'rules', type: 'List<String? Function(bool?)>?', description: 'Validation rules for the checkbox'),
            ],
          ),

          // Checkbox with Label Position Above
          WidgetDocCard(
            title: 'Checkbox with Label Above',
            description: 'TCheckbox configured with TLabelPosition.aboveField inside a custom input field theme',
            icon: HugeIcons.strokeRoundedAlignTop,
            preview: TCheckbox(
              label: 'Receive promotional emails',
              tag: 'New',
              info: 'Weekly marketing updates',
              helperText: 'You can opt out at any time.',
              isRequired: true,
              valueNotifier: ValueNotifier<bool?>(false),
              theme: context.theme.inputFieldTheme.copyWith(labelPosition: TLabelPosition.aboveField),
            ),
            code: '''TCheckbox(
  label: 'Receive promotional emails',
  tag: 'New',
  info: 'Weekly marketing updates',
  helperText: 'You can opt out at any time.',
  isRequired: true,
  theme: context.theme.inputFieldTheme.copyWith(
    labelPosition: TLabelPosition.aboveField,
  ),
  onValueChanged: (value) => print(value),
)''',
          ),

          // ==================== STANDARD CHECKBOX GROUP ====================

          // Basic Checkbox Group
          WidgetDocCard(
            title: 'Checkbox Group',
            description: 'Multiple checkbox selection with group management',
            icon: HugeIcons.strokeRoundedCheckList,
            preview: TCheckboxGroup<String>(
              label: 'Interests',
              items: [
                TCheckboxGroupItem.map('Technology'),
                TCheckboxGroupItem.map('Sports'),
                TCheckboxGroupItem.map('Music'),
                TCheckboxGroupItem.map('Travel'),
              ],
              valueNotifier: _interestsNotifier,
            ),
            code: '''TCheckboxGroup<String>(
  label: 'Interests',
  items: [
    TCheckboxGroupItem.map('Technology'),
    TCheckboxGroupItem.map('Sports'),
    TCheckboxGroupItem.map('Music'),
    TCheckboxGroupItem.map('Travel'),
  ],
  onValueChanged: (selected) {
    print('Selected: \$selected');
  },
)''',
            properties: const [
              PropertyDoc(name: 'items', type: 'List<TCheckboxGroupItem<T>>', description: 'List of checkbox items to display'),
              PropertyDoc(name: 'value', type: 'List<T>?', description: 'Currently selected values'),
              PropertyDoc(name: 'onValueChanged', type: 'ValueChanged<List<T>?>?', description: 'Callback fired when selection changes'),
            ],
          ),

          // Checkbox Group Layouts
          WidgetDocCard(
            title: 'Checkbox Group Layouts',
            description: 'Vertical and horizontal layouts for checkbox groups',
            icon: HugeIcons.strokeRoundedViewAgenda,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Horizontal Layout',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.colors.onSurface),
                ),
                const SizedBox(height: 8),
                TCheckboxGroup<String>(
                  label: 'Preferences',
                  items: [TCheckboxGroupItem.map('Email'), TCheckboxGroupItem.map('SMS'), TCheckboxGroupItem.map('Push')],
                  vertical: false,
                  valueNotifier: ValueNotifier<List<String>>([]),
                ),
                const SizedBox(height: 20),
                Text(
                  'Vertical Layout',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.colors.onSurface),
                ),
                const SizedBox(height: 8),
                TCheckboxGroup<String>(
                  label: 'Features',
                  items: [
                    TCheckboxGroupItem.map('Dark Mode'),
                    TCheckboxGroupItem.map('Notifications'),
                    TCheckboxGroupItem.map('Auto-save'),
                  ],
                  vertical: true,
                  valueNotifier: ValueNotifier<List<String>>([]),
                ),
              ],
            ),
            code: '''// Horizontal Layout
TCheckboxGroup<String>(
  label: 'Preferences',
  items: [
    TCheckboxGroupItem.map('Email'),
    TCheckboxGroupItem.map('SMS'),
    TCheckboxGroupItem.map('Push'),
  ],
  vertical: false, // Horizontal layout
)

// Vertical Layout
TCheckboxGroup<String>(
  label: 'Features',
  items: [
    TCheckboxGroupItem.map('Dark Mode'),
    TCheckboxGroupItem.map('Notifications'),
    TCheckboxGroupItem.map('Auto-save'),
  ],
  vertical: true, // Vertical layout (default)
)''',
            properties: const [
              PropertyDoc(name: 'vertical', type: 'bool', defaultValue: 'false', description: 'Whether to display checkboxes vertically'),
              PropertyDoc(name: 'block', type: 'bool', defaultValue: 'true', description: 'Whether checkboxes should take full width'),
            ],
          ),

          // Checkbox Group with Validation
          WidgetDocCard(
            title: 'Checkbox Group with Validation',
            description: 'Validate minimum/maximum selections',
            icon: HugeIcons.strokeRoundedRuler,
            preview: TCheckboxGroup<String>(
              label: 'Select Skills (min 2, max 4)',
              isRequired: true,
              items: [
                TCheckboxGroupItem.map('Flutter'),
                TCheckboxGroupItem.map('React'),
                TCheckboxGroupItem.map('Vue'),
                TCheckboxGroupItem.map('Angular'),
                TCheckboxGroupItem.map('Node.js'),
              ],
              valueNotifier: ValueNotifier<List<String>>([]),
              rules: [
                (selected) {
                  if (selected == null || selected.isEmpty) {
                    return 'Please select at least 2 skills';
                  }
                  if (selected.length < 2) {
                    return 'Please select at least 2 skills';
                  }
                  if (selected.length > 4) {
                    return 'Please select at most 4 skills';
                  }
                  return null;
                },
              ],
            ),
            code: '''TCheckboxGroup<String>(
  label: 'Select Skills (min 2, max 4)',
  isRequired: true,
  items: [
    TCheckboxGroupItem.map('Flutter'),
    TCheckboxGroupItem.map('React'),
    TCheckboxGroupItem.map('Vue'),
    TCheckboxGroupItem.map('Angular'),
    TCheckboxGroupItem.map('Node.js'),
  ],
  rules: [
    (selected) {
      if (selected == null || selected.isEmpty) {
        return 'Please select at least 2 skills';
      }
      if (selected.length < 2) {
        return 'Please select at least 2 skills';
      }
      if (selected.length > 4) {
        return 'Please select at most 4 skills';
      }
      return null;
    },
  ],
)''',
            properties: const [
              PropertyDoc(name: 'rules', type: 'List<String? Function(List<T>?)>?', description: 'Validation rules for the checkbox group'),
            ],
          ),

          // Checkbox Group with Clear Button
          WidgetDocCard(
            title: 'Checkbox Group with Clear Button',
            description: 'Checkbox group with clearable option to deselect all',
            icon: HugeIcons.strokeRoundedCancel02,
            preview: TCheckboxGroup<String>(
              label: 'Notifications',
              clearable: true,
              items: [
                TCheckboxGroupItem.map('Email Updates'),
                TCheckboxGroupItem.map('SMS Alerts'),
                TCheckboxGroupItem.map('Push Notifications'),
                TCheckboxGroupItem.map('Newsletter'),
              ],
              valueNotifier: ValueNotifier<List<String>>(['Email Updates', 'Push Notifications']),
            ),
            code: '''TCheckboxGroup<String>(
  label: 'Notifications',
  clearable: true, // Show clear button when items are selected
  items: [
    TCheckboxGroupItem.map('Email Updates'),
    TCheckboxGroupItem.map('SMS Alerts'),
    TCheckboxGroupItem.map('Push Notifications'),
    TCheckboxGroupItem.map('Newsletter'),
  ],
  value: ['Email Updates', 'Push Notifications'],
  onValueChanged: (selected) {
    print('Selected: \$selected');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'clearable',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether to show a clear button to deselect all items',
              ),
            ],
          ),

          // ==================== STANDARD RADIO GROUP ====================

          // Basic Radio Group
          WidgetDocCard(
            title: 'Radio Group',
            description: 'Single selection from a set of options',
            icon: HugeIcons.strokeRoundedRadioButton,
            preview: TRadioGroup<String>(
              label: 'Preferred Contact Method',
              valueNotifier: _contactMethodNotifier,
              items: const [
                TRadioGroupItem(value: 'email', label: 'Email'),
                TRadioGroupItem(value: 'phone', label: 'Phone'),
                TRadioGroupItem(value: 'mail', label: 'Mail'),
              ],
              onValueChanged: (value) => debugPrint('Selected: \$value'),
            ),
            code: '''TRadioGroup<String>(
  label: 'Preferred Contact Method',
  items: [
    TRadioGroupItem(value: 'email', label: 'Email'),
    TRadioGroupItem(value: 'phone', label: 'Phone'),
    TRadioGroupItem(value: 'mail', label: 'Mail'),
  ],
  onValueChanged: (value) => print('Selected: \$value'),
)''',
            properties: const [
              PropertyDoc(name: 'items', type: 'List<TRadioGroupItem<T>>', description: 'List of radio items to display'),
              PropertyDoc(name: 'value', type: 'T?', description: 'Currently selected value'),
              PropertyDoc(name: 'vertical', type: 'bool', defaultValue: 'false', description: 'Whether to display items vertically'),
            ],
          ),

          // Radio Group Layouts
          WidgetDocCard(
            title: 'Radio Group Layouts',
            description: 'Vertical and horizontal layouts for radio groups',
            icon: HugeIcons.strokeRoundedViewAgenda,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TRadioGroup<String>(
                  label: 'Vertical Layout',
                  vertical: true,
                  items: const [
                    TRadioGroupItem(value: 'option1', label: 'Option 1'),
                    TRadioGroupItem(value: 'option2', label: 'Option 2'),
                    TRadioGroupItem(value: 'option3', label: 'Option 3'),
                  ],
                  onValueChanged: (value) => debugPrint('Selected: \$value'),
                ),
              ],
            ),
            code: '''TRadioGroup<String>(
  label: 'Layout',
  vertical: true, // Display items in a column
  items: [
    TRadioGroupItem(value: 'option1', label: 'Option 1'),
    TRadioGroupItem(value: 'option2', label: 'Option 2'),
    TRadioGroupItem(value: 'option3', label: 'Option 3'),
  ],
)''',
            properties: const [
              PropertyDoc(name: 'vertical', type: 'bool', defaultValue: 'false', description: 'Whether to display items vertically'),
              PropertyDoc(name: 'spacing', type: 'double', defaultValue: '16', description: 'Horizontal spacing between items'),
              PropertyDoc(name: 'runSpacing', type: 'double', defaultValue: '8', description: 'Vertical spacing between items/rows'),
            ],
          ),

          // Radio Group with Validation
          WidgetDocCard(
            title: 'Radio Group with Validation',
            description: 'Required radio selection with custom validation',
            icon: HugeIcons.strokeRoundedUserShield01,
            preview: TRadioGroup<String>(
              label: 'Membership Tier',
              isRequired: true,
              items: const [
                TRadioGroupItem(value: 'basic', label: 'Basic Free'),
                TRadioGroupItem(value: 'pro', label: 'Professional'),
                TRadioGroupItem(value: 'enterprise', label: 'Enterprise'),
              ],
              rules: [(val) => (val == null || val.isEmpty) ? 'Please select a membership tier' : null],
            ),
            code: '''TRadioGroup<String>(
  label: 'Membership Tier',
  isRequired: true,
  items: const [
    TRadioGroupItem(value: 'basic', label: 'Basic Free'),
    TRadioGroupItem(value: 'pro', label: 'Professional'),
    TRadioGroupItem(value: 'enterprise', label: 'Enterprise'),
  ],
  rules: [
    (val) => val == null ? 'Please select a membership tier' : null,
  ],
)''',
          ),

          // ==================== STANDARD SWITCH ====================

          // Basic Switch
          WidgetDocCard(
            title: 'Switch (Toggle)',
            description: 'Toggle switch for boolean settings',
            icon: HugeIcons.strokeRoundedToggleOn,
            preview: TSwitch(label: 'Enable Notifications', valueNotifier: _notificationsNotifier),
            code: '''TSwitch(
  label: 'Enable Notifications',
  onValueChanged: (value) {
    print('Notifications: \$value');
  },
)''',
            properties: const [
              PropertyDoc(name: 'label', type: 'String?', description: 'Label text displayed next to the switch'),
              PropertyDoc(name: 'value', type: 'bool', defaultValue: 'false', description: 'Current switch state'),
              PropertyDoc(name: 'onValueChanged', type: 'ValueChanged<bool?>?', description: 'Callback fired when switch state changes'),
            ],
          ),

          // Switch States
          WidgetDocCard(
            title: 'Switch States, Sizes, and Colors',
            description: 'Different switch states, sizes, and custom active/inactive colors',
            icon: HugeIcons.strokeRoundedSettings01,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TSwitch(label: 'Enabled (On)', value: true, onValueChanged: (_) {}),
                const SizedBox(height: 12),
                TSwitch(label: 'Enabled (Off)', value: false, onValueChanged: (_) {}),
                const SizedBox(height: 12),
                TSwitch(
                  label: 'Custom Active & Inactive Color',
                  valueNotifier: ValueNotifier<bool>(false),
                  color: Colors.teal,
                  inactiveColor: Colors.amber.withAlpha(100),
                ),
                const SizedBox(height: 12),
                TSwitch(label: 'Disabled (On)', value: true, disabled: true, onValueChanged: (_) {}),
                const SizedBox(height: 12),
                TSwitch(label: 'Disabled (Off)', value: false, disabled: true, onValueChanged: (_) {}),
                const SizedBox(height: 12),
                TSwitch(label: 'Extra Small Size', value: true, size: TInputSize.xs, onValueChanged: (_) {}),
                const SizedBox(height: 12),
                TSwitch(label: 'Small Size', value: true, size: TInputSize.sm, onValueChanged: (_) {}),
                const SizedBox(height: 12),
                TSwitch(label: 'Large Size', value: true, size: TInputSize.lg, onValueChanged: (_) {}),
              ],
            ),
            code: '''// On state
TSwitch(
  label: 'Enabled (On)',
  value: true,
)

// Off state
TSwitch(
  label: 'Enabled (Off)',
  value: false,
)

// Custom Active & Inactive Colors
TSwitch(
  label: 'Custom Colors',
  color: Colors.teal, // Active/On state color
  inactiveColor: Colors.amber, // Optional Inactive/Off state track color
  onValueChanged: (value) => print(value),
)

// Disabled
TSwitch(
  label: 'Disabled',
  value: true,
  disabled: true,
)

// Different sizes
TSwitch(
  label: 'Small',
  value: true,
  size: TInputSize.sm,
)

TSwitch(
  label: 'Large',
  value: true,
  size: TInputSize.lg,
)''',
            properties: const [
              PropertyDoc(name: 'disabled', type: 'bool', defaultValue: 'false', description: 'Whether the switch is disabled'),
              PropertyDoc(name: 'size', type: 'TInputSize?', description: 'Size of the switch (xs, sm, md, lg)'),
              PropertyDoc(name: 'color', type: 'Color?', description: 'Custom color for the switch when active/on'),
              PropertyDoc(
                name: 'inactiveColor',
                type: 'Color?',
                description: 'Optional custom color for the switch track when inactive/off',
              ),
            ],
          ),

          // Switch with Validation
          WidgetDocCard(
            title: 'Switch with Validation',
            description: 'Required switch with validation rules',
            icon: HugeIcons.strokeRoundedCheckmarkBadge01,
            preview: TSwitch(
              label: 'I confirm I am 18 years or older',
              isRequired: true,
              valueNotifier: ValueNotifier<bool>(false),
              rules: [
                (value) {
                  if (value != true) return 'You must confirm you are 18 or older';
                  return null;
                },
              ],
            ),
            code: '''TSwitch(
  label: 'I confirm I am 18 years or older',
  isRequired: true,
  rules: [
    (value) {
      if (value != true) return 'You must confirm you are 18 or older';
      return null;
    },
  ],
  onValueChanged: (value) => print(value),
)''',
            properties: const [
              PropertyDoc(name: 'isRequired', type: 'bool', defaultValue: 'false', description: 'Whether the switch is required'),
              PropertyDoc(name: 'rules', type: 'List<String? Function(bool?)>?', description: 'Validation rules for the switch'),
            ],
          ),

          // Switch with Label Position Above
          WidgetDocCard(
            title: 'Switch with Label Above',
            description: 'TSwitch configured with TLabelPosition.aboveField inside a custom input field theme',
            icon: HugeIcons.strokeRoundedAlignTop,
            preview: TSwitch(
              label: 'Automatic Backups',
              tag: 'Recommended',
              info: 'Backs up data to the cloud every night',
              helperText: 'Requires an active internet connection.',
              isRequired: true,
              valueNotifier: ValueNotifier<bool>(true),
              theme: context.theme.inputFieldTheme.copyWith(labelPosition: TLabelPosition.aboveField),
            ),
            code: '''TSwitch(
  label: 'Automatic Backups',
  tag: 'Recommended',
  info: 'Backs up data to the cloud every night',
  helperText: 'Requires an active internet connection.',
  isRequired: true,
  theme: context.theme.inputFieldTheme.copyWith(
    labelPosition: TLabelPosition.aboveField,
  ),
  onValueChanged: (value) => print(value),
)''',
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
