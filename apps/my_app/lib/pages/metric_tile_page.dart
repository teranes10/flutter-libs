import 'package:flutter/material.dart';
import 'package:my_app/widgets/widget_doc_card.dart';
import 'package:te_widgets/te_widgets.dart';

/// Interactive showcase and documentation page for [TMetricGrid], [TMetricTile], and [TTile].
class MetricTilePage extends StatefulWidget {
  const MetricTilePage({super.key});

  @override
  State<MetricTilePage> createState() => _MetricTilePageState();
}

class _MetricTilePageState extends State<MetricTilePage> {
  // Playground state
  double _playgroundMinWidth = 200;
  int? _playgroundColumns;
  double _playgroundGap = 12;
  bool _playgroundUniformHeight = true;
  bool _playgroundCompact = false;
  final _playgroundVariant = ValueNotifier<String?>(_noVariant);

  static const _noVariant = 'default';

  TVariant? get _variant => _playgroundVariant.value == _noVariant ? null : TVariant.values.byName(_playgroundVariant.value!);

  @override
  void initState() {
    super.initState();
    _playgroundVariant.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _playgroundVariant.dispose();
    super.dispose();
  }

  // Selected tile for TTile active state demo
  int _selectedTileIndex = 0;
  int _selectedTaskIndex = 0;
  TKeyValueMode _selectedValuesMode = TKeyValueMode.inlineFlow;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = context.theme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================== PAGE HEADER ====================
          Text(
            'Metrics & Tiles',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Analytical KPI widgets, responsive metric grids, and versatile tile containers for admin panels and dashboards.',
            style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TChip.tonal(text: 'TMetricGrid', icon: HugeIcons.strokeRoundedGrid, color: theme.primary),
              TChip.tonal(text: 'TMetricTile', icon: HugeIcons.strokeRoundedDashboardSpeed01, color: theme.info),
              TChip.tonal(text: 'TTile', icon: HugeIcons.strokeRoundedLayoutLeft, color: theme.success),
              TChip.tonal(text: 'TTile.task', icon: HugeIcons.strokeRoundedTask01, color: theme.warning),
            ],
          ),
          const SizedBox(height: 32),

          // ==================== SECTION 1: LIVE INTERACTIVE PLAYGROUND ====================
          _buildPlaygroundCard(context),

          const SizedBox(height: 28),

          // ==================== SECTION 2: TMETRICGRID ====================
          _buildSectionHeader(
            title: '1. TMetricGrid',
            subtitle:
                'Responsive grid purpose-built for KPI tiles. Automatically computes column count based on available width and minTileWidth, guaranteeing uniform height across all tiles.',
            icon: HugeIcons.strokeRoundedGrid,
          ),
          const SizedBox(height: 16),

          // 2.1 Auto-Responsive Columns
          WidgetDocCard(
            title: 'Auto-Responsive Columns (minTileWidth)',
            description:
                'Derives optimal column count dynamically from available container width and minTileWidth without hardcoded breakpoint spans.',
            icon: HugeIcons.strokeRoundedAutoConversations,
            preview: TMetricGrid(
              minTileWidth: 210,
              gapX: 12,
              gapY: 12,
              children: [
                TMetricTile(
                  label: 'Gross Sales',
                  value: '\$84,230.00',
                  subtitle: '+18.2% vs last month',
                  icon: HugeIcons.strokeRoundedPayment02,
                  color: theme.success,
                  trend: '+18.2%',
                  trendUp: true,
                ),
                TMetricTile(
                  label: 'Net Profit',
                  value: '\$29,450.00',
                  subtitle: 'Margin: 34.9%',
                  icon: HugeIcons.strokeRoundedWallet01,
                  color: theme.primary,
                  trend: '+4.5%',
                  trendUp: true,
                ),
                TMetricTile(
                  label: 'Refunds & Returns',
                  value: '\$1,120.00',
                  subtitle: '14 return requests',
                  icon: HugeIcons.strokeRoundedTaskEdit02,
                  color: theme.danger,
                  trend: '-1.8%',
                  trendUp: false,
                ),
                TMetricTile(
                  label: 'Pending Shipments',
                  value: '48 orders',
                  subtitle: 'All in packaging queue',
                  icon: HugeIcons.strokeRoundedDeliveryTruck01,
                  color: theme.warning,
                  badge: const TBadge(label: 'Queue', color: Colors.orange),
                ),
              ],
            ),
            code: '''TMetricGrid(
  minTileWidth: 210,
  gapX: 12,
  gapY: 12,
  children: [
    TMetricTile(
      label: 'Gross Sales',
      value: '\$84,230.00',
      subtitle: '+18.2% vs last month',
      icon: HugeIcons.strokeRoundedPayment02,
      color: context.theme.success,
      trend: '+18.2%',
      trendUp: true,
    ),
    TMetricTile(
      label: 'Net Profit',
      value: '\$29,450.00',
      subtitle: 'Margin: 34.9%',
      icon: HugeIcons.strokeRoundedWallet01,
      color: context.theme.primary,
      trend: '+4.5%',
      trendUp: true,
    ),
    TMetricTile(
      label: 'Refunds & Returns',
      value: '\$1,120.00',
      subtitle: '14 return requests',
      icon: HugeIcons.strokeRoundedTaskEdit02,
      color: context.theme.danger,
      trend: '-1.8%',
      trendUp: false,
    ),
    TMetricTile(
      label: 'Pending Shipments',
      value: '48 orders',
      subtitle: 'All in packaging queue',
      icon: HugeIcons.strokeRoundedDeliveryTruck01,
      color: context.theme.warning,
      badge: TBadge(label: 'Queue', color: Colors.orange),
    ),
  ],
)''',
            properties: const [
              PropertyDoc(name: 'children', type: 'List<Widget>', isRequired: true, description: 'The metric tile widgets to lay out.'),
              PropertyDoc(
                name: 'minTileWidth',
                type: 'double',
                defaultValue: '180.0',
                description: 'Preferred minimum tile width before wrapping to fewer columns.',
              ),
              PropertyDoc(name: 'columns', type: 'int?', description: 'Optional pinned column count overriding auto-calculation.'),
              PropertyDoc(name: 'gapX', type: 'double', defaultValue: '12.0', description: 'Horizontal gap between tiles in the same row.'),
              PropertyDoc(name: 'gapY', type: 'double', defaultValue: '12.0', description: 'Vertical gap between rows.'),
              PropertyDoc(
                name: 'uniformHeight',
                type: 'bool',
                defaultValue: 'true',
                description:
                    'When true, every tile across all rows shares the height of the tallest child. When false, height is equalized within each row.',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 2.2 Uniform Height Feature
          WidgetDocCard(
            title: 'Uniform Height Guarantee',
            description:
                'TMetricGrid measures natural unconstrained child heights and synchronizes all tiles to the tallest child, preventing awkward layout misalignment.',
            icon: HugeIcons.strokeRoundedAlignBottom,
            preview: TMetricGrid(
              minTileWidth: 220,
              uniformHeight: true,
              children: [
                TMetricTile(label: 'Single-line Content', value: '1,240', icon: HugeIcons.strokeRoundedFilter, color: theme.primary),
                TMetricTile(
                  label: 'One-line Subtitle',
                  value: '4,890',
                  subtitle: 'Target: 5,000 units',
                  icon: HugeIcons.strokeRoundedFilter,
                  color: theme.info,
                  trend: '+3.1%',
                  trendUp: true,
                ),
                TMetricTile(
                  label: 'Multi-line Subtitle',
                  value: '99.9%',
                  subtitle: 'Aggregated SLA across US-East, EU-Central, and AP-South regions',
                  icon: HugeIcons.strokeRoundedFilter,
                  color: theme.success,
                  badge: const TBadge(label: 'SLA', color: Colors.green),
                ),
              ],
            ),
            code: '''TMetricGrid(
  minTileWidth: 220,
  uniformHeight: true, // Equalizes height across all tiles
  children: [
    TMetricTile(
      label: 'Single-line Content',
      value: '1,240',
      icon: HugeIcons.strokeRoundedFilter,
    ),
    TMetricTile(
      label: 'One-line Subtitle',
      value: '4,890',
      subtitle: 'Target: 5,000 units',
      icon: HugeIcons.strokeRoundedFilter,
    ),
    TMetricTile(
      label: 'Multi-line Subtitle',
      value: '99.9%',
      subtitle: 'Aggregated SLA across US-East, EU-Central, and AP-South regions',
      icon: HugeIcons.strokeRoundedFilter,
    ),
  ],
)''',
          ),

          const SizedBox(height: 24),

          // 2.3 Pinned Columns
          WidgetDocCard(
            title: 'Pinned Column Count (columns: 2 / 4)',
            description: 'Override the automatic width calculation to enforce a precise column count across all container widths.',
            icon: HugeIcons.strokeRoundedViewOff,
            preview: TMetricGrid(
              columns: 2,
              gapX: 12,
              gapY: 12,
              children: [
                TMetricTile(
                  label: 'API Request Rate',
                  value: '4,280 req/s',
                  subtitle: 'Peak throughput: 6,100 req/s',
                  icon: HugeIcons.strokeRoundedDashboardSpeed01,
                  color: theme.info,
                  trend: '+12.4%',
                  trendUp: true,
                ),
                TMetricTile(
                  label: 'Error Rate',
                  value: '0.04%',
                  subtitle: 'Threshold budget: < 0.10%',
                  icon: HugeIcons.strokeRoundedAlertCircle,
                  color: theme.success,
                  trend: '-0.02%',
                  trendUp: true, // Trend down on errors is positive!
                ),
              ],
            ),
            code: '''TMetricGrid(
  columns: 2, // Pins exactly 2 columns regardless of available width
  children: [
    TMetricTile(
      label: 'API Request Rate',
      value: '4,280 req/s',
      subtitle: 'Peak throughput: 6,100 req/s',
      icon: HugeIcons.strokeRoundedDashboardSpeed01,
      color: context.theme.info,
      trend: '+12.4%',
      trendUp: true,
    ),
    TMetricTile(
      label: 'Error Rate',
      value: '0.04%',
      subtitle: 'Threshold budget: < 0.10%',
      icon: HugeIcons.strokeRoundedAlertCircle,
      color: context.theme.success,
      trend: '-0.02%',
      trendUp: true,
    ),
  ],
)''',
          ),

          const SizedBox(height: 36),

          // ==================== SECTION 3: TMETRICTILE ====================
          _buildSectionHeader(
            title: '2. TMetricTile',
            subtitle:
                'Versatile KPI summary card with numerical values, guidance subtitles, trend badges, custom icons, interactive ripples, and compact modes.',
            icon: HugeIcons.strokeRoundedDashboardSpeed01,
          ),
          const SizedBox(height: 16),

          // 3.1 Trends & Colors
          WidgetDocCard(
            title: 'Trend Indicators & Color Themes',
            description: 'Directional percentage badges with trendUp (green positive arrow) or trendDown (red negative arrow).',
            icon: HugeIcons.strokeRoundedChartAverage,
            preview: TMetricGrid(
              minTileWidth: 200,
              children: [
                TMetricTile(
                  label: 'Annual Recurring Revenue',
                  value: '\$1.42M',
                  subtitle: 'Target: \$1.50M by Q4',
                  icon: HugeIcons.strokeRoundedChartAverage,
                  color: theme.success,
                  trend: '+24.8%',
                  trendUp: true,
                ),
                TMetricTile(
                  label: 'Customer Churn Rate',
                  value: '3.4%',
                  subtitle: '+0.6% vs benchmark',
                  icon: HugeIcons.strokeRoundedUserRemove01,
                  color: theme.danger,
                  trend: '+0.6%',
                  trendUp: false,
                ),
                TMetricTile(
                  label: 'Average Resolution Time',
                  value: '18m 42s',
                  subtitle: '-4m 12s reduction',
                  icon: HugeIcons.strokeRoundedTimeline,
                  color: theme.info,
                  trend: '-18.5%',
                  trendUp: true, // Improvement!
                ),
                TMetricTile(
                  label: 'Active System Nodes',
                  value: '32 / 32',
                  subtitle: 'All health checks passing',
                  icon: HugeIcons.strokeRoundedDna,
                  color: theme.primary,
                  trend: '100%',
                  trendUp: true,
                ),
              ],
            ),
            code: '''TMetricTile(
  label: 'Annual Recurring Revenue',
  value: '\$1.42M',
  subtitle: 'Target: \$1.50M by Q4',
  icon: HugeIcons.strokeRoundedChartAverage,
  color: context.theme.success,
  trend: '+24.8%',
  trendUp: true, // Displays green trending_up badge
)

TMetricTile(
  label: 'Customer Churn Rate',
  value: '3.4%',
  subtitle: '+0.6% vs benchmark',
  icon: HugeIcons.strokeRoundedUserRemove01,
  color: context.theme.danger,
  trend: '+0.6%',
  trendUp: false, // Displays red trending_down badge
)''',
            properties: const [
              PropertyDoc(name: 'label', type: 'String', isRequired: true, description: 'Primary metric label (e.g. Total Revenue).'),
              PropertyDoc(name: 'value', type: 'String', isRequired: true, description: 'Numerical or status value (e.g. \$12,450, 42).'),
              PropertyDoc(name: 'subtitle', type: 'String?', description: 'Optional guidance or contextual note beneath value.'),
              PropertyDoc(name: 'icon', type: 'IconData?', description: 'Leading icon displayed in accent container.'),
              PropertyDoc(name: 'color', type: 'Color?', description: 'Accent theme color for the icon container and highlight.'),
              PropertyDoc(name: 'trend', type: 'String?', description: 'Trend badge text (e.g. +12.5%, -3.2%).'),
              PropertyDoc(
                name: 'trendUp',
                type: 'bool?',
                defaultValue: 'true',
                description: 'Whether trend is positive (green) or negative (red).',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 3.2 Badges, Tooltips & Interactivity
          WidgetDocCard(
            title: 'Interactive Tap, Tooltips & Status Badges',
            description:
                'Tap callback with InkWell ripple, automatic trailing chevron, hover tooltips via TTooltip, and status badges next to label.',
            icon: HugeIcons.strokeRoundedTouch10,
            preview: TMetricGrid(
              minTileWidth: 220,
              children: [
                TMetricTile(
                  label: 'Pending Invoices',
                  value: '14 unpaid',
                  subtitle: 'Tap to view overdue list',
                  icon: HugeIcons.strokeRoundedInvoice,
                  color: theme.warning,
                  badge: const TBadge(label: 'Action Needed', color: Colors.amber),
                  tooltip: 'Invoices outstanding past standard 30-day net terms',
                  onTap: () => TToastService.info(context, 'Navigating to unpaid invoices...'),
                ),
                TMetricTile(
                  label: 'Security Audit',
                  value: 'Passed',
                  subtitle: 'Checked 5 mins ago',
                  icon: HugeIcons.strokeRoundedUserShield01,
                  color: theme.success,
                  badge: const TBadge(label: 'SOC 2', color: Colors.green),
                  tooltip: 'Automated compliance scan verified across infrastructure',
                  onTap: () => TToastService.success(context, 'Security audit report ready'),
                ),
                TMetricTile(
                  label: 'Custom Trailing Widget',
                  value: '3 Reports',
                  subtitle: 'Generated today',
                  icon: HugeIcons.strokeRoundedAnalytics01,
                  color: theme.primary,
                  trailing: TButton(
                    icon: HugeIcons.strokeRoundedDownload01,
                    size: TButtonSize.xs,
                    type: TButtonType.tonal,
                    onTap: () => TToastService.info(context, 'Downloading reports...'),
                  ),
                ),
              ],
            ),
            code: '''TMetricTile(
  label: 'Pending Invoices',
  value: '14 unpaid',
  subtitle: 'Tap to view overdue list',
  icon: HugeIcons.strokeRoundedInvoice,
  color: context.theme.warning,
  badge: TBadge(label: 'Action Needed', color: Colors.amber),
  tooltip: 'Invoices outstanding past standard 30-day net terms',
  onTap: () => handleViewInvoices(), // Renders InkWell + trailing chevron
)

TMetricTile(
  label: 'Custom Trailing Widget',
  value: '3 Reports',
  subtitle: 'Generated today',
  icon: HugeIcons.strokeRoundedAnalytics01,
  color: context.theme.primary,
  trailing: TButton(
    icon: HugeIcons.strokeRoundedDownload01,
    size: TButtonSize.xs,
    type: TButtonType.tonal,
    onTap: () => handleDownload(),
  ),
)''',
            properties: const [
              PropertyDoc(
                name: 'onTap',
                type: 'VoidCallback?',
                description: 'Tap callback. Wraps tile in InkWell and renders trailing chevron if trailing is null.',
              ),
              PropertyDoc(name: 'tooltip', type: 'String?', description: 'Helpful explanation text rendered as a TTooltip on hover.'),
              PropertyDoc(name: 'badge', type: 'Widget?', description: 'Optional status indicator widget placed alongside the label.'),
              PropertyDoc(name: 'trailing', type: 'Widget?', description: 'Custom widget rendered on the right side of the tile.'),
            ],
          ),

          const SizedBox(height: 24),

          // 3.3 Compact Mode
          WidgetDocCard(
            title: 'Compact Mode (compact: true)',
            description:
                'Dense horizontal representation with smaller icons and tight padding, ideal for toolbars, side panels, and table headers.',
            icon: HugeIcons.strokeRoundedCompass,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Compact Grid (compact: true):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TMetricGrid(
                  minTileWidth: 170,
                  children: [
                    TMetricTile(
                      compact: true,
                      label: 'CPU Usage',
                      value: '42.8%',
                      icon: HugeIcons.strokeRoundedRamMemory,
                      color: theme.primary,
                      trend: '+1.2%',
                      trendUp: false,
                    ),
                    TMetricTile(
                      compact: true,
                      label: 'RAM Load',
                      value: '12.4 GB',
                      subtitle: '16 GB allocated',
                      icon: HugeIcons.strokeRoundedDeveloper,
                      color: theme.info,
                    ),
                    TMetricTile(
                      compact: true,
                      label: 'Network I/O',
                      value: '840 MB/s',
                      icon: HugeIcons.strokeRoundedArrowUpDown,
                      color: theme.success,
                      trend: '+8%',
                      trendUp: true,
                    ),
                    TMetricTile(
                      compact: true,
                      label: 'Disk Free',
                      value: '384 GB',
                      subtitle: 'SSD NVMe',
                      icon: HugeIcons.strokeRoundedDatabase,
                      color: theme.warning,
                      onTap: () => TToastService.info(context, 'Storage stats opened'),
                    ),
                  ],
                ),
              ],
            ),
            code: '''TMetricTile(
  compact: true, // Dense mode with compact fonts and padding
  label: 'CPU Usage',
  value: '42.8%',
  icon: HugeIcons.strokeRoundedRamMemory,
  color: context.theme.primary,
  trend: '+1.2%',
  trendUp: false,
)''',
            properties: const [
              PropertyDoc(
                name: 'compact',
                type: 'bool',
                defaultValue: 'false',
                description: 'Enables condensed sizing: 16px icon, 10px label font, 13px value font, and tight padding.',
              ),
            ],
          ),

          const SizedBox(height: 36),

          // ==================== SECTION 4: TTILE ====================
          _buildSectionHeader(
            title: '3. TTile',
            subtitle:
                'Multi-purpose tile widget containing a leading icon/image container, title, subtitle, and optional trailing widget. Used standalone, in cards, lists, and tables.',
            icon: HugeIcons.strokeRoundedLayoutLeft,
          ),
          const SizedBox(height: 16),

          // 4.0 Heading Sizing Scale (h1 to h6)
          WidgetDocCard(
            title: 'Heading Sizes (TTile.h1 to TTile.h6)',
            description:
                'Standardized heading scale matching typography hierarchies from h1 (page/hero headers) down to h6 (compact/dense rows). Named constructors or size: TTileSize.* are supported.',
            icon: HugeIcons.strokeRoundedImageActualSize,
            preview: Column(
              children: [
                _buildTileContainer(
                  context,
                  child: TTile.h1(
                    icon: HugeIcons.strokeRoundedOneSquare,
                    iconBackgroundColor: theme.primary.withAlpha(25),
                    iconColor: theme.primary,
                    title: 'Heading 1 (h1 • 24px/w700)',
                    subtitle: 'Hero headers & main dashboards • Icon 32px • Spacing 16px',
                    trailing: TBadge(label: 'h1', color: theme.primary),
                  ),
                ),
                const SizedBox(height: 10),
                _buildTileContainer(
                  context,
                  child: TTile.h2(
                    icon: HugeIcons.strokeRoundedTwoSquare,
                    iconBackgroundColor: theme.info.withAlpha(25),
                    iconColor: theme.info,
                    title: 'Heading 2 (h2 • 20px/w600)',
                    subtitle: 'Major section headers & modal titles • Icon 28px • Spacing 14px',
                    trailing: TBadge(label: 'h2', color: theme.info),
                  ),
                ),
                const SizedBox(height: 10),
                _buildTileContainer(
                  context,
                  child: TTile.h3(
                    icon: HugeIcons.strokeRoundedBook03,
                    iconBackgroundColor: theme.success.withAlpha(25),
                    iconColor: theme.success,
                    title: 'Heading 3 (h3 • 18px/w600)',
                    subtitle: 'Subsection titles & large cards • Icon 24px • Spacing 13px',
                    trailing: TBadge(label: 'h3', color: theme.success),
                  ),
                ),
                const SizedBox(height: 10),
                _buildTileContainer(
                  context,
                  child: TTile.h4(
                    icon: HugeIcons.strokeRoundedBook04,
                    iconBackgroundColor: theme.warning.withAlpha(25),
                    iconColor: theme.warning,
                    title: 'Heading 4 (h4 • 16px/w600)',
                    subtitle: 'Prominent card & list items • Icon 22px • Spacing 12px',
                    trailing: TBadge(label: 'h4', color: theme.warning),
                  ),
                ),
                const SizedBox(height: 10),
                _buildTileContainer(
                  context,
                  child: TTile.h5(
                    icon: HugeIcons.strokeRoundedBlocks,
                    iconBackgroundColor: theme.primary.withAlpha(25),
                    iconColor: theme.primary,
                    title: 'Heading 5 (h5 • 14px/w500 • Default)',
                    subtitle: 'Standard default tile for lists, accordions & tables • Icon 20px',
                    trailing: TBadge(label: 'h5 (default)', color: theme.primary),
                  ),
                ),
                const SizedBox(height: 10),
                _buildTileContainer(
                  context,
                  child: TTile.h6(
                    icon: HugeIcons.strokeRoundedBlocks,
                    iconBackgroundColor: colors.onSurface.withAlpha(15),
                    iconColor: colors.onSurfaceVariant,
                    title: 'Heading 6 (h6 • 12.5px/w500)',
                    subtitle: 'Dense sidebar & compact table row tile • Icon 16px • Spacing 10px',
                    trailing: TBadge(label: 'h6', color: colors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            code: '''// 1. Using named constructors:
TTile.h1(
  title: 'Page Title (h1)',
  subtitle: 'Hero description text',
  icon: HugeIcons.strokeRoundedDashboardSquare01,
)

TTile.h2(
  title: 'Section Header (h2)',
  subtitle: 'Major subsection text',
  icon: HugeIcons.strokeRoundedFolder01,
)

TTile.h3(title: 'Card Title (h3)', subtitle: 'Card info', icon: HugeIcons.strokeRoundedFence)
TTile.h4(title: 'Prominent Item (h4)', subtitle: 'Item details', icon: HugeIcons.strokeRoundedStar)
TTile.h5(title: 'Standard Default (h5)', subtitle: 'List item', icon: HugeIcons.strokeRoundedList)
TTile.h6(title: 'Compact Row (h6)', subtitle: 'Dense item', icon: HugeIcons.strokeRoundedFilterEdit)

// 2. Or using the size property:
TTile(
  size: TTileSize.h2,
  title: 'Configurable Tile Size',
  subtitle: 'Scales title, subtitle, icon, padding, and spacing uniformly',
  icon: HugeIcons.strokeRoundedAiAutoRotate,
)''',
            properties: const [
              PropertyDoc(
                name: 'size',
                type: 'TSize',
                defaultValue: 'TTileSize.h5',
                description:
                    'Unified size configuration (TSize) with presets TTileSize.h1 (24px), h2 (20px), h3 (18px), h4 (16px), h5 (14px default), or h6 (12.5px). Named constructors TTile.h1 to TTile.h6 are also available.',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 4.1 Basic & Themed Icon Tiles
          WidgetDocCard(
            title: 'Basic & Themed Leading Icon Tiles',
            description: 'Configurable icon containers with custom padding, border radius, background colors, and typography.',
            icon: HugeIcons.strokeRoundedPaintBoard,
            preview: Column(
              children: [
                _buildTileContainer(
                  context,
                  child: TTile(
                    icon: HugeIcons.strokeRoundedCloudCheck,
                    iconBackgroundColor: theme.success.withAlpha(25),
                    iconColor: theme.success,
                    title: 'Cloud Backup Complete',
                    subtitle: '4.8 GB synchronized to storage bucket',
                    trailing: const TBadge(label: 'Verified', color: Colors.green),
                  ),
                ),
                const SizedBox(height: 10),
                _buildTileContainer(
                  context,
                  child: TTile(
                    icon: HugeIcons.strokeRoundedSecurityWarning,
                    iconBackgroundColor: theme.warning.withAlpha(25),
                    iconColor: theme.warning,
                    title: 'SSL Certificate Expiring Soon',
                    subtitle: 'Expires in 6 days • Auto-renewal in progress',
                    trailing: TChip.tonal(text: 'Warning', color: theme.warning, size: TChipSize.sm),
                  ),
                ),
                const SizedBox(height: 10),
                _buildTileContainer(
                  context,
                  child: TTile(
                    icon: HugeIcons.strokeRoundedSingRight,
                    iconBackgroundColor: theme.primary.withAlpha(25),
                    iconColor: theme.primary,
                    iconBorderRadius: BorderRadius.circular(24), // Circular icon badge
                    title: 'Traffic Surge Detected',
                    subtitle: '+140% incoming sessions from direct campaign',
                    trailing: TIcon.raw(HugeIcons.strokeRoundedArrowRight01, color: colors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            code: '''TTile(
  icon: HugeIcons.strokeRoundedCloudCheck,
  iconBackgroundColor: context.theme.success.withAlpha(25),
  iconColor: context.theme.success,
  title: 'Cloud Backup Complete',
  subtitle: '4.8 GB synchronized to storage bucket',
  trailing: TBadge(label: 'Verified', color: Colors.green),
)

// Circular icon container:
TTile(
  icon: HugeIcons.strokeRoundedSingRight,
  iconBackgroundColor: context.theme.primary.withAlpha(25),
  iconColor: context.theme.primary,
  iconBorderRadius: BorderRadius.circular(24),
  title: 'Traffic Surge Detected',
  subtitle: '+140% incoming sessions',
  trailing: HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01),
)''',
            properties: const [
              PropertyDoc(
                name: 'size',
                type: 'TSize',
                defaultValue: 'TTileSize.h5',
                description: 'Unified size configuration (TSize) with presets TTileSize.h1 to h6 scaling typography, icons, and spacing.',
              ),
              PropertyDoc(name: 'title', type: 'String?', description: 'Primary title text displayed on top.'),
              PropertyDoc(name: 'subtitle', type: 'String?', description: 'Optional subtitle text displayed below the title.'),
              PropertyDoc(name: 'icon', type: 'dynamic', description: 'Leading icon. Supports IconData, HugeIcon, or Widget.'),
              PropertyDoc(name: 'iconColor', type: 'Color?', description: 'Color of the leading icon.'),
              PropertyDoc(name: 'iconBackgroundColor', type: 'Color?', description: 'Background color of the leading icon container.'),
              PropertyDoc(
                name: 'iconBorderRadius',
                type: 'BorderRadius?',
                defaultValue: 'BorderRadius.circular(12.0)',
                description: 'Border radius of the leading icon container.',
              ),
              PropertyDoc(
                name: 'iconPadding',
                type: 'EdgeInsetsGeometry?',
                defaultValue: 'EdgeInsets.all(8.0)',
                description: 'Internal padding inside the leading icon container.',
              ),
              PropertyDoc(name: 'trailing', type: 'Widget?', description: 'Optional trailing widget rendered on the right.'),
            ],
          ),

          const SizedBox(height: 24),

          // 4.2 Rich Widgets & Trailing Controls
          WidgetDocCard(
            title: 'Rich Content & Trailing Controls',
            description:
                'Use titleWidget and subtitleWidget for custom layouts, inline badges, and switches or actions as trailing widgets.',
            icon: HugeIcons.strokeRoundedImages,
            preview: Column(
              children: [
                _buildTileContainer(
                  context,
                  child: TTile(
                    icon: HugeIcons.strokeRoundedNotification02,
                    iconColor: theme.info,
                    iconBackgroundColor: theme.info.withAlpha(25),
                    titleWidget: Row(
                      children: [
                        const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(width: 8),
                        TChip.tonal(text: 'Realtime', color: theme.info, size: TChipSize.sm),
                      ],
                    ),
                    subtitle: 'Receive instant order updates and customer inquiries',
                    trailing: TSwitch(value: true, onValueChanged: (val) => TToastService.info(context, 'Notifications toggled: \$val')),
                  ),
                ),
                const SizedBox(height: 10),
                _buildTileContainer(
                  context,
                  child: TTile(
                    leading: TAvatar(name: 'Sarah Jenkins', size: TInputSize.sm),
                    title: 'Sarah Jenkins',
                    subtitleWidget: Row(
                      children: [
                        TIcon.raw(HugeIcons.strokeRoundedShield01, size: 13, color: colors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text('Lead Security Engineer • Active now', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                      ],
                    ),
                    trailing: TButton(
                      size: TButtonSize.xs,
                      type: TButtonType.outline,
                      text: 'Message',
                      icon: HugeIcons.strokeRoundedBubbleChat,
                      onTap: () => TToastService.info(context, 'Opening chat with Sarah...'),
                    ),
                  ),
                ),
              ],
            ),
            code: '''TTile(
  icon: HugeIcons.strokeRoundedNotification02,
  iconColor: context.theme.info,
  iconBackgroundColor: context.theme.info.withAlpha(25),
  titleWidget: Row(
    children: [
      Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
      SizedBox(width: 8),
      TChip.tonal(text: 'Realtime', size: TChipSize.sm),
    ],
  ),
  subtitle: 'Receive instant order updates',
  trailing: TSwitch(value: true, onValueChanged: (v) {}),
)

// Leading avatar with action button:
TTile(
  leading: TAvatar(name: 'Sarah Jenkins', size: TInputSize.sm),
  title: 'Sarah Jenkins',
  subtitle: 'Lead Security Engineer',
  trailing: TButton(
    size: TButtonSize.xs,
    type: TButtonType.outline,
    text: 'Message',
    onTap: () {},
  ),
)''',
            properties: const [
              PropertyDoc(name: 'titleWidget', type: 'Widget?', description: 'Custom widget replacing default title text.'),
              PropertyDoc(name: 'subtitleWidget', type: 'Widget?', description: 'Custom widget replacing default subtitle text.'),
              PropertyDoc(
                name: 'leading',
                type: 'dynamic',
                description: 'Custom widget (e.g. TAvatar, TImage) replacing the standard icon container.',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 4.3 Interactive States (isHovered, isExpanded, onTap)
          WidgetDocCard(
            title: 'Interactive States: Active & Expanded',
            description:
                'TTile includes built-in hover and expanded/active styling via isExpanded, expandedIconBackgroundColor, and expandedIconColor.',
            icon: HugeIcons.strokeRoundedToggleOn,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select a destination below to see active/expanded highlights:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                for (int i = 0; i < 3; i++) ...[
                  InkWell(
                    onTap: () => setState(() => _selectedTileIndex = i),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: _selectedTileIndex == i ? theme.primary.withAlpha(20) : colors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _selectedTileIndex == i ? theme.primary : colors.outlineVariant.withAlpha(60)),
                      ),
                      child: TTile(
                        isExpanded: _selectedTileIndex == i,
                        expandedIconBackgroundColor: theme.primary,
                        expandedIconColor: Colors.white,
                        icon: [HugeIcons.strokeRoundedPackage, HugeIcons.strokeRoundedAnalytics01, HugeIcons.strokeRoundedSettings02][i],
                        title: ['Product Catalog', 'Analytics Dashboard', 'System Preferences'][i],
                        subtitle: [
                          '1,420 SKU records active',
                          'Realtime funnel conversion metrics',
                          'API keys and webhook web dispatchers',
                        ][i],
                        trailing: _selectedTileIndex == i
                            ? TBadge(label: 'Active', color: theme.primary)
                            : TIcon.raw(HugeIcons.strokeRoundedRadioButton, size: 18),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            code: '''TTile(
  isExpanded: isSelected, // Active state
  expandedIconBackgroundColor: context.theme.primary,
  expandedIconColor: Colors.white,
  icon: HugeIcons.strokeRoundedPackage,
  title: 'Product Catalog',
  subtitle: '1,420 SKU records active',
  trailing: isSelected
      ? TBadge(label: 'Active', color: context.theme.primary)
      : HugeIcon(icon: HugeIcons.strokeRoundedRadioButton),
)''',
            properties: const [
              PropertyDoc(
                name: 'isExpanded',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether the tile is in an expanded or active state.',
              ),
              PropertyDoc(
                name: 'expandedIconBackgroundColor',
                type: 'Color?',
                description: 'Icon container background color when isExpanded is true.',
              ),
              PropertyDoc(name: 'expandedIconColor', type: 'Color?', description: 'Icon color when isExpanded is true.'),
              PropertyDoc(
                name: 'onTap',
                type: 'VoidCallback?',
                description: 'Interactive click handler wrapping the tile in an InkWell ripple.',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 4.4 Product Image Sizing Scale & Smart Descriptions
          WidgetDocCard(
            title: 'Product Tiles & Smart Descriptions (TTile.sm, md, lg & desc)',
            description:
                'Product-focused image scale (sm: 50px, md: 75px, lg: 100px) with start alignment. Smart desc positioning automatically places description beside the image below subtitle if it fits within image height, or spans below the image across full width if it exceeds image height.',
            icon: HugeIcons.strokeRoundedPackage,
            preview: Column(
              children: [
                _buildTileContainer(
                  context,
                  child: TTile.sm(
                    imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=100',
                    title: 'Nike Air Max',
                    subtitle: 'SKU: NK-AIR-90 • In Stock (120 units)',
                    desc: 'Short note fits beside the 50px image below subtitle.',
                    trailing: const TChip(text: '\$129.99', color: Colors.blue),
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTileContainer(
                  context,
                  child: TTile(
                    size: TTileSize.md.copyWith(fontWeight: FontWeight.w800, subtitleFontWeight: FontWeight.w600),
                    imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=150',
                    title: 'Custom font weights',
                    subtitle: 'TTileSize.fontWeight / subtitleFontWeight',
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTileContainer(
                  context,
                  child: TTile.md(
                    imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=150',
                    title: 'Minimalist Chrono Watch',
                    subtitle: 'SKU: WT-CHR-01 • Genuine Leather Strap',
                    desc:
                        'Detailed multi-line specification that exceeds image height automatically flows below the image across the full tile width.',
                    trailing: const TChip(text: '\$249.00', color: Colors.teal),
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTileContainer(
                  context,
                  child: TTile.lg(
                    imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=200',
                    title: 'Wireless Studio Headphones',
                    subtitle: 'SKU: HP-ST-PRO',
                    desc:
                        'Full specifications: 40mm neodymium drivers, 30-hour battery life, fast charging via USB-C, memory foam cushions.',
                    trailing: const TChip(text: '\$349.50', color: Colors.purple),

                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
              ],
            ),
            code: '''// Small product tile (50px image, 14px title font, start-aligned)
TTile.sm(
  imageUrl: 'https://.../shoe.jpg',
  title: 'Nike Air Max',
  subtitle: 'SKU: NK-AIR-90 • In Stock (120 units)',
  desc: 'Short note fits beside the image below subtitle.',
  trailing: TBadge(label: '\$129.99', color: Colors.blue),
)

// Medium product tile (75px image, 16px title font, start-aligned)
TTile.md(
  imageUrl: 'https://.../watch.jpg',
  title: 'Minimalist Chrono Watch',
  subtitle: 'SKU: WT-CHR-01 • Genuine Leather Strap',
  desc: 'Detailed specs exceeding image height flow below the image container.',
  trailing: TBadge(label: '\$249.00', color: Colors.teal),
)

// Large product tile (100px image, 18px title font, start-aligned)
TTile.lg(
  imageUrl: 'https://.../headphones.jpg',
  title: 'Wireless Studio Headphones',
  subtitle: 'SKU: HP-ST-PRO • Active Noise Cancellation',
  desc: 'Full specifications: 40mm neodymium drivers, 30-hour battery life, USB-C fast charging.',
  trailing: TBadge(label: '\$349.50', color: Colors.purple),
)''',
            properties: const [
              PropertyDoc(
                name: 'size',
                type: 'TSize',
                defaultValue: 'TTileSize.h5',
                description:
                    'Product image sizes TTileSize.sm (50px, font 14), md (75px, font 16), lg (100px, font 18) default to CrossAxisAlignment.start; headings h1-h6 default to CrossAxisAlignment.center.',
              ),
              PropertyDoc(
                name: 'crossAxisAlignment',
                type: 'CrossAxisAlignment?',
                description: 'Vertical alignment of leading image, title column, and trailing. Defaults to size.crossAxisAlignment.',
              ),
              PropertyDoc(
                name: 'desc',
                type: 'String?',
                description:
                    'Smart description: automatically renders beside the image below subtitle if total text height fits within image height, or moves below image across full width if it exceeds image height.',
              ),
              PropertyDoc(
                name: 'imageUrl',
                type: 'String?',
                description:
                    'Network image rendered as the leading thumbnail, sized by size.icon. Overridden by leading; takes precedence over icon.',
              ),
              PropertyDoc(name: 'leading', type: 'dynamic', description: 'Custom leading widget or icon. Overrides imageUrl and icon.'),
              PropertyDoc(name: 'descWidget', type: 'Widget?', description: 'Custom widget replacing the default description text.'),
              PropertyDoc(name: 'descStyle', type: 'TextStyle?', description: 'Custom text style for the description.'),
            ],
          ),

          const SizedBox(height: 24),

          // 4.5 Key-Value Metadata & Layout Modes (values, valuesMode)
          WidgetDocCard(
            title: 'Embedded Key-Value Data (values & valuesMode)',
            description:
                'TTile supports structured key-value metadata embedded directly below the tile header using the values property and TKeyValueSection. The valuesMode property controls layout across 5 presentation styles: inlineFlow, stackedFlow, inlineColumns, stackedColumns, and split.',
            icon: HugeIcons.strokeRoundedDataRecovery,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select a valuesMode to switch presentation layout:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final mode in TKeyValueMode.values)
                      InkWell(
                        onTap: () => setState(() => _selectedValuesMode = mode),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _selectedValuesMode == mode ? theme.primary : colors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _selectedValuesMode == mode ? theme.primary : colors.outlineVariant.withAlpha(80)),
                          ),
                          child: Text(
                            mode.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _selectedValuesMode == mode ? FontWeight.w600 : FontWeight.normal,
                              color: _selectedValuesMode == mode ? Colors.white : colors.onSurface,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.primary.withAlpha(40)),
                  ),
                  child: Row(
                    children: [
                      TIcon.raw(HugeIcons.strokeRoundedInformationCircle, size: 16, color: theme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(switch (_selectedValuesMode) {
                          TKeyValueMode.inlineFlow => 'inlineFlow (default): Keys and values flow inline (Key: Value), wrapping naturally.',
                          TKeyValueMode.stackedFlow => 'stackedFlow: Keys stacked above values, flowing dynamically into wrapped rows.',
                          TKeyValueMode.inlineColumns => 'inlineColumns: Multi-column uniform grid with keys and values inline.',
                          TKeyValueMode.stackedColumns =>
                            'stackedColumns: Multi-column uniform grid with keys stacked vertically above values.',
                          TKeyValueMode.split => 'split: Single-column full-width layout with keys on left and values on right.',
                        }, style: TextStyle(fontSize: 12, color: theme.primary, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _buildTileContainer(
                  context,
                  child: TTile(
                    icon: HugeIcons.strokeRoundedInvoice,
                    iconBackgroundColor: theme.primary.withAlpha(25),
                    iconColor: theme.primary,
                    title: 'Purchase Order #PO-94021',
                    subtitle: 'Vendor: Global Logistics Ltd · Created Oct 8, 2026',
                    trailing: const TBadge(label: 'Approved', color: Colors.green),
                    valuesMode: _selectedValuesMode,
                    values: [
                      TKeyValue('Vendor ID', value: 'VND-4810'),
                      TKeyValue('Department', value: 'Procurement'),
                      TKeyValue('Payment Terms', value: 'Net 30'),
                      TKeyValue('Warehouse', value: 'Central Hub (B-12)'),
                      TKeyValue('Total Amount', value: '\$18,450.00'),
                      TKeyValue.chip('Status', 'Ready to Ship', color: theme.primary),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Side-by-Side Mode Comparisons:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                _buildTileContainer(
                  context,
                  child: TTile(
                    icon: HugeIcons.strokeRoundedWallet01,
                    iconBackgroundColor: theme.success.withAlpha(25),
                    iconColor: theme.success,
                    title: 'Settlement Breakdown (valuesMode: TKeyValueMode.split)',
                    subtitle: 'Invoice #INV-2024-009 · Auto-calculated',
                    valuesMode: TKeyValueMode.split,
                    values: [
                      TKeyValue('Subtotal', value: '\$1,200.00'),
                      TKeyValue('Tax (8.25%)', value: '\$99.00'),
                      TKeyValue('Shipping Fee', value: '\$15.00'),
                      TKeyValue('Net Payable', value: '\$1,314.00'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _buildTileContainer(
                  context,
                  child: TTile(
                    icon: HugeIcons.strokeRoundedDna,
                    iconBackgroundColor: theme.info.withAlpha(25),
                    iconColor: theme.info,
                    title: 'Kubernetes Cluster Node (valuesMode: TKeyValueMode.stackedColumns)',
                    subtitle: 'Pod Fleet: us-east-prod-01 • Healthy',
                    valuesMode: TKeyValueMode.stackedColumns,
                    values: [
                      TKeyValue('CPU Usage', value: '42.8%'),
                      TKeyValue('Memory', value: '18.4 / 32 GB'),
                      TKeyValue('Uptime', value: '99.98%'),
                      TKeyValue('Pods Active', value: '28 / 30'),
                    ],
                  ),
                ),
              ],
            ),
            code: '''// 1. Default inlineFlow mode (Key: Value wrapped dynamically)
TTile(
  icon: HugeIcons.strokeRoundedInvoice,
  title: 'Purchase Order #PO-94021',
  subtitle: 'Vendor: Global Logistics Ltd',
  trailing: TBadge(label: 'Approved', color: Colors.green),
  valuesMode: TKeyValueMode.inlineFlow, // Default
  values: [
    TKeyValue('Vendor ID', value: 'VND-4810'),
    TKeyValue('Department', value: 'Procurement'),
    TKeyValue('Payment Terms', value: 'Net 30'),
    TKeyValue('Total Amount', value: '\$18,450.00'),
    TKeyValue.chip('Status', 'Ready to Ship', color: context.theme.primary),
  ],
)

// 2. stackedColumns mode (Uniform grid columns with keys stacked above values)
TTile(
  icon: HugeIcons.strokeRoundedDna,
  title: 'Kubernetes Cluster Node',
  subtitle: 'Pod Fleet: us-east-prod-01',
  valuesMode: TKeyValueMode.stackedColumns,
  values: [
    TKeyValue('CPU Usage', value: '42.8%'),
    TKeyValue('Memory', value: '18.4 / 32 GB'),
    TKeyValue('Uptime', value: '99.98%'),
    TKeyValue('Pods Active', value: '28 / 30'),
  ],
)

// 3. split mode (Single column with keys on left and values on right)
TTile(
  icon: HugeIcons.strokeRoundedWallet01,
  title: 'Settlement Breakdown',
  subtitle: 'Invoice #INV-2024-009',
  valuesMode: TKeyValueMode.split,
  values: [
    TKeyValue('Subtotal', value: '\$1,200.00'),
    TKeyValue('Tax (8.25%)', value: '\$99.00'),
    TKeyValue('Shipping Fee', value: '\$15.00'),
    TKeyValue('Net Payable', value: '\$1,314.00'),
  ],
)''',
            properties: const [
              PropertyDoc(
                name: 'values',
                type: 'List<TKeyValue>?',
                description: 'List of structured key-value items rendered below the tile content via TKeyValueSection.',
              ),
              PropertyDoc(
                name: 'valuesMode',
                type: 'TKeyValueMode?',
                defaultValue: 'TKeyValueMode.inlineFlow',
                description: 'Layout presentation mode: inlineFlow (default), stackedFlow, inlineColumns, stackedColumns, or split.',
              ),
              PropertyDoc(
                name: 'valuesSpacing',
                type: 'double?',
                defaultValue: '16.0',
                description: 'Vertical spacing between the tile header row and the values key-value section.',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 4.5 Card wrapper + shadow levels
          WidgetDocCard(
            title: 'Card Wrapper & Shadow Levels (.card / TCardShadow)',
            description:
                'TTile never draws its own card. Wrap any widget with .card() for a flat TCard surface. Prefer no shadow; add TCardShadow.sm only when elevation is genuinely needed.',
            icon: HugeIcons.strokeRoundedLayers01,
            preview: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final level in TCardShadow.values)
                  TTile.h5(
                    icon: HugeIcons.strokeRoundedLayers01,
                    title: 'TCardShadow.${level.name}',
                    subtitle: 'Shadow level',
                  ).card(shadow: level),
              ],
            ),
            code: '''// Tiles shrink to fit when there is no trailing widget,
// so they can be dropped straight into a Wrap or Row.
TTile.h5(icon: HugeIcons.strokeRoundedLayers01, title: 'Flat', subtitle: 'none')
    .card();

// Only when elevation is needed (keep it sm):
TTile.h5(icon: HugeIcons.strokeRoundedLayers01, title: 'Raised', subtitle: 'sm')
    .cardSm();''',
            properties: const [
              PropertyDoc(
                name: 'shadow',
                type: 'TCardShadow',
                defaultValue: 'TCardShadow.none',
                description: 'Preset shadow depth: none, sm, md, lg.',
              ),
              PropertyDoc(
                name: 'padding',
                type: 'EdgeInsetsGeometry',
                defaultValue: 'EdgeInsets.all(12)',
                description: 'Inner padding of the card.',
              ),
              PropertyDoc(
                name: 'margin',
                type: 'EdgeInsetsGeometry',
                defaultValue: 'EdgeInsets.zero',
                description: 'Outer margin of the card.',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 4.5b Icon on top
          WidgetDocCard(
            title: 'Icon On Top (iconOnTop)',
            description:
                'Set iconOnTop to stack the icon above the title block, ideal for hub/launcher tiles. A trailing widget moves to the far end of the icon row.',
            icon: HugeIcons.strokeRoundedDashboardSquare01,
            preview: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 200,
                  child: TTile.h4(
                    iconOnTop: true,
                    icon: HugeIcons.strokeRoundedPackage,
                    iconColor: theme.primary,
                    title: 'Stocktake',
                    subtitle: '12 open counts',
                    trailing: TBadge(label: '12', color: theme.primary),
                  ).card(padding: const EdgeInsets.all(16)),
                ),
                SizedBox(
                  width: 200,
                  child: TTile.h4(
                    iconOnTop: true,
                    icon: HugeIcons.strokeRoundedDeliveryTruck01,
                    iconColor: theme.warning,
                    title: 'Dispatch',
                    subtitle: '3 pending',
                  ).card(padding: const EdgeInsets.all(16)),
                ),
              ],
            ),
            code: '''TTile.h4(
  iconOnTop: true,
  icon: HugeIcons.strokeRoundedPackage,
  title: 'Stocktake',
  subtitle: '12 open counts',
  trailing: TBadge(label: '12', color: context.theme.primary),
).card(padding: const EdgeInsets.all(16))''',
            properties: const [
              PropertyDoc(
                name: 'iconOnTop',
                type: 'bool',
                defaultValue: 'false',
                description: 'Stacks the icon above the title/subtitle/desc instead of beside them.',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 4.5c Product accordion
          WidgetDocCard(
            title: 'Product Accordion (TAccordion + TTile header)',
            description:
                'TAccordion accepts the same image, size, subtitle, desc and trailing options as TTile. The header shows image, title, SKU and price; expanding reveals the details.',
            icon: HugeIcons.strokeRoundedShoppingBag01,
            preview: Column(
              children: [
                TAccordion(
                  size: TTileSize.md,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=150',
                  title: 'Minimalist Chrono Watch',
                  subtitle: 'SKU: WT-CHR-01',
                  trailing: const TBadge(label: '\$249.00', color: Colors.teal),
                  content: TKeyValueSection(
                    values: [
                      TKeyValue('Strap', value: 'Genuine leather'),
                      TKeyValue('Stock', value: '38 units'),
                      TKeyValue('Warehouse', value: 'Central Hub (B-12)'),
                    ],
                    mode: TKeyValueMode.split,
                  ),
                ),
              ],
            ),
            code: '''TAccordion(
  size: TTileSize.md,
  crossAxisAlignment: CrossAxisAlignment.start,
  imageUrl: product.imageUrl,
  title: product.name,
  subtitle: 'SKU: \${product.sku}',
  trailing: TBadge(label: product.price, color: Colors.teal),
  content: TKeyValueSection(values: details, mode: TKeyValueMode.split),
)''',
            properties: const [
              PropertyDoc(name: 'imageUrl', type: 'String?', description: 'Leading product thumbnail.'),
              PropertyDoc(name: 'size', type: 'TSize', defaultValue: 'TTileSize.h5', description: 'Header tile size (h1-h6, sm, md, lg).'),
              PropertyDoc(name: 'trailing', type: 'Widget?', description: 'Always-visible widget before the expand arrow, e.g. a price.'),
              PropertyDoc(
                name: 'iconOnTop',
                type: 'bool',
                defaultValue: 'false',
                description: 'Stack the icon above the title in the header.',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 4.6 Task Cards (TTile.task)
          WidgetDocCard(
            title: 'Task Cards (TTile.task)',
            description:
                'Touch-friendly task rows for mobile and handheld field apps (warehouse picking, dispatch, delivery, and audits). Features an accent status strip, status chip, fine-print metadata, and a built-in done/total progress bar. Like every TTile it has no card chrome; wrap it with .card() for a surface and shadow.',
            icon: HugeIcons.strokeRoundedTask01,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tap any task card below to toggle active selection:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                TTile.task(
                  icon: HugeIcons.strokeRoundedPackage,
                  title: 'SO-10452 · Order Picking',
                  subtitle: 'Zone A · Electronics · Aisle 3, Shelf B',
                  meta: 'Due today at 3:30 PM • 12 lines remaining',
                  status: 'Picking',
                  statusColor: theme.primary,
                  done: 8,
                  total: 12,
                  selected: _selectedTaskIndex == 0,
                  onTap: () {
                    setState(() => _selectedTaskIndex = 0);
                    TToastService.info(context, 'Selected picking task SO-10452');
                  },
                ).card(padding: EdgeInsets.zero),
                const SizedBox(height: 10),
                TTile.task(
                  icon: HugeIcons.strokeRoundedDeliveryTruck01,
                  title: 'DO-90312 · Express Dispatch',
                  subtitle: 'Dock 4 · Carrier: FreightWay Express',
                  meta: 'Urgent departure in 20 min • Awaiting supervisor scan',
                  status: 'Urgent',
                  statusColor: theme.danger,
                  done: 1,
                  total: 6,
                  selected: _selectedTaskIndex == 1,
                  onTap: () {
                    setState(() => _selectedTaskIndex = 1);
                    TToastService.info(context, 'Selected dispatch task DO-90312');
                  },
                ).card(padding: EdgeInsets.zero),
                const SizedBox(height: 10),
                TTile.task(
                  icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                  title: 'WO-88201 · Assembly & Packaging',
                  subtitle: 'Station 2 · 24 finished units packaged',
                  meta: 'Completed by Alex Miller at 2:15 PM',
                  status: 'Done',
                  statusColor: theme.success,
                  done: 24,
                  total: 24,
                  selected: _selectedTaskIndex == 2,
                  onTap: () {
                    setState(() => _selectedTaskIndex = 2);
                    TToastService.info(context, 'Selected completed task WO-88201');
                  },
                ).card(padding: EdgeInsets.zero),
                const SizedBox(height: 10),
                TTile.task(
                  icon: HugeIcons.strokeRoundedNavigation,
                  title: 'PO-30119 · Inbound Receiving Audit',
                  subtitle: 'Receiving Bay 1 • 50 cartons expected',
                  meta: 'Scheduled for tomorrow 09:00 AM',
                  status: 'Scheduled',
                  statusColor: theme.warning,
                  selected: _selectedTaskIndex == 3,
                  onTap: () {
                    setState(() => _selectedTaskIndex = 3);
                    TToastService.info(context, 'Selected audit task PO-30119');
                  },
                ).card(padding: EdgeInsets.zero),
              ],
            ),
            code: '''// 1. In-progress task with progress bar & status chip:
TTile.task(
  icon: HugeIcons.strokeRoundedPackage,
  title: 'SO-10452 · Order Picking',
  subtitle: 'Zone A · Electronics · Aisle 3, Shelf B',
  meta: 'Due today at 3:30 PM • 12 lines remaining',
  status: 'Picking',
  statusColor: context.theme.primary,
  done: 8,
  total: 12,
  selected: isSelected,
  onTap: () => onTaskTapped(),
)

// 2. Urgent task with high-priority status color:
TTile.task(
  icon: HugeIcons.strokeRoundedDeliveryTruck01,
  title: 'DO-90312 · Express Dispatch',
  subtitle: 'Dock 4 · Carrier: FreightWay Express',
  meta: 'Urgent departure in 20 min',
  status: 'Urgent',
  statusColor: context.theme.danger,
  done: 1,
  total: 6,
  onTap: () {},
)

// 3. Completed task:
TTile.task(
  icon: HugeIcons.strokeRoundedCheckmarkCircle01,
  title: 'WO-88201 · Assembly & Packaging',
  subtitle: 'Station 2 · 24 finished units packaged',
  meta: 'Completed by Alex at 2:15 PM',
  status: 'Done',
  statusColor: context.theme.success,
  done: 24,
  total: 24,
  onTap: () {},
)

// 4. Milestone / pending task without progress bar:
TTile.task(
  icon: HugeIcons.strokeRoundedNavigation,
  title: 'PO-30119 · Inbound Receiving Audit',
  subtitle: 'Receiving Bay 1 • 50 cartons expected',
  meta: 'Scheduled for tomorrow 09:00 AM',
  status: 'Scheduled',
  statusColor: context.theme.warning,
  onTap: () {},
)''',
            properties: const [
              PropertyDoc(
                name: 'title',
                type: 'String',
                isRequired: true,
                description: 'Bold title text (maxLines: 1) displayed prominently at the top.',
              ),
              PropertyDoc(
                name: 'subtitle',
                type: 'String?',
                description: 'Optional secondary line describing task details, location, or SKU info.',
              ),
              PropertyDoc(
                name: 'meta',
                type: 'String?',
                description: 'Optional fine-print metadata line (e.g. due time, priority, assignee).',
              ),
              PropertyDoc(name: 'status', type: 'String?', description: 'Label text rendered inside a pill chip next to the title.'),
              PropertyDoc(
                name: 'statusColor',
                type: 'Color?',
                description: 'Color theme applied to the left accent strip, status chip, icon, and progress bar.',
              ),
              PropertyDoc(name: 'done', type: 'int?', description: 'Number of completed units/items for the linear progress bar.'),
              PropertyDoc(
                name: 'total',
                type: 'int?',
                description: 'Total number of units/items. When greater than 0, renders a progress bar and done/total counter.',
              ),
              PropertyDoc(
                name: 'icon',
                type: 'dynamic',
                description: 'Leading icon displayed beside the title. Accepts IconData, HugeIcon, or Widget.',
              ),
              PropertyDoc(
                name: 'selected',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether the task card is highlighted with a themed background tint and border.',
              ),
              PropertyDoc(
                name: 'onTap',
                type: 'VoidCallback?',
                description: 'Callback when the card is pressed, enabling touch-friendly task interaction.',
              ),
            ],
          ),

          const SizedBox(height: 36),

          // ==================== SECTION 5: REALISTIC DASHBOARD SUMMARY ====================
          _buildSectionHeader(
            title: '4. Executive Dashboard Example',
            subtitle: 'A complete production-ready KPI dashboard header powered by TMetricGrid and TMetricTile widgets.',
            icon: HugeIcons.strokeRoundedDashboardSquare01,
          ),
          const SizedBox(height: 16),

          _buildDashboardShowcase(context),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  // ==================== PLAYGROUND BUILDER ====================
  Widget _buildPlaygroundCard(BuildContext context) {
    final colors = context.colors;
    final theme = context.theme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: theme.primary.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                  child: TIcon.raw(HugeIcons.strokeRoundedFilterEdit, color: theme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Interactive TMetricGrid & TMetricTile Playground',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Adjust controls below to observe live auto-column derivation, uniform heights, and tile configurations.',
                        style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Control Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 24,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Min Tile Width Slider
                SizedBox(
                  width: 260,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Min Tile Width:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(
                            '${_playgroundMinWidth.toInt()} px',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primary),
                          ),
                        ],
                      ),
                      Slider(
                        value: _playgroundMinWidth,
                        min: 140,
                        max: 320,
                        divisions: 18,
                        onChanged: (val) => setState(() => _playgroundMinWidth = val),
                      ),
                    ],
                  ),
                ),

                // Gap Slider
                SizedBox(
                  width: 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Grid Spacing (gap):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(
                            '${_playgroundGap.toInt()} px',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primary),
                          ),
                        ],
                      ),
                      Slider(
                        value: _playgroundGap,
                        min: 4,
                        max: 28,
                        divisions: 12,
                        onChanged: (val) => setState(() => _playgroundGap = val),
                      ),
                    ],
                  ),
                ),

                // Variant Select
                SizedBox(
                  width: 200,
                  child: TSelect<String, String, String>(
                    label: 'Variant',
                    items: [_noVariant, for (final v in TVariant.values) v.name],
                    valueNotifier: _playgroundVariant,
                  ),
                ),

                // Columns Dropdown / Selector
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Columns: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    DropdownButton<int?>(
                      value: _playgroundColumns,
                      isDense: true,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem<int?>(value: null, child: Text('Auto (Width-based)')),
                        DropdownMenuItem<int?>(value: 2, child: Text('2 Columns')),
                        DropdownMenuItem<int?>(value: 3, child: Text('3 Columns')),
                        DropdownMenuItem<int?>(value: 4, child: Text('4 Columns')),
                        DropdownMenuItem<int?>(value: 6, child: Text('6 Columns')),
                      ],
                      onChanged: (val) => setState(() => _playgroundColumns = val),
                    ),
                  ],
                ),

                // Uniform Height Toggle
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Uniform Height: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    TSwitch(
                      value: _playgroundUniformHeight,
                      onValueChanged: (val) => setState(() => _playgroundUniformHeight = val ?? true),
                    ),
                  ],
                ),

                // Compact Toggle
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Compact Mode: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    TSwitch(value: _playgroundCompact, onValueChanged: (val) => setState(() => _playgroundCompact = val ?? false)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Live Resulting Grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: TMetricGrid(
              minTileWidth: _playgroundMinWidth,
              columns: _playgroundColumns,
              gapX: _playgroundGap,
              gapY: _playgroundGap,
              uniformHeight: _playgroundUniformHeight,
              children: [
                TMetricTile(
                  compact: _playgroundCompact,
                  type: _variant,
                  label: 'Total Revenue',
                  value: '\$148,290.00',
                  subtitle: '+14.2% from prior period',
                  icon: HugeIcons.strokeRoundedInvestigation,
                  color: theme.success,
                  trend: '+14.2%',
                  trendUp: true,
                  onTap: () => TToastService.info(context, 'Total Revenue clicked'),
                ),
                TMetricTile(
                  compact: _playgroundCompact,
                  type: _variant,
                  label: 'New Customers',
                  value: '1,842',
                  subtitle: '89 acquired via referral program',
                  icon: HugeIcons.strokeRoundedUserGroup,
                  color: theme.primary,
                  trend: '+6.1%',
                  trendUp: true,
                  badge: const TBadge(label: 'Growing', color: Colors.blue),
                  onTap: () => TToastService.info(context, 'New Customers clicked'),
                ),
                TMetricTile(
                  compact: _playgroundCompact,
                  type: _variant,
                  label: 'Server Load',
                  value: '84.2%',
                  subtitle: 'Noticeable CPU spike in cluster node 4',
                  icon: HugeIcons.strokeRoundedDna,
                  color: theme.warning,
                  trend: '+12.0%',
                  trendUp: false,
                  tooltip: 'Calculated over the last 15 minutes across all pods',
                  onTap: () => TToastService.warning(context, 'Cluster node warning inspect'),
                ),
                TMetricTile(
                  compact: _playgroundCompact,
                  type: _variant,
                  label: 'Pending Approvals',
                  value: '19',
                  subtitle: 'Requires supervisor sign-off',
                  icon: HugeIcons.strokeRoundedNavigation,
                  color: theme.danger,
                  badge: const TBadge(label: 'Urgent', color: Colors.red),
                  onTap: () => TToastService.error(context, '19 Approvals pending'),
                ),
                TMetricTile(
                  compact: _playgroundCompact,
                  type: _variant,
                  label: 'Fulfillment Rate',
                  value: '99.4%',
                  subtitle: 'Avg ship duration: 1.2 business days',
                  icon: HugeIcons.strokeRoundedDeliveryTruck01,
                  color: theme.info,
                  trend: '+0.4%',
                  trendUp: true,
                ),
                TMetricTile(
                  compact: _playgroundCompact,
                  type: _variant,
                  label: 'Customer CSAT',
                  value: '4.9 / 5.0',
                  subtitle: 'Based on 2,420 customer feedback surveys',
                  icon: HugeIcons.strokeRoundedStarCircle,
                  color: Colors.amber,
                  badge: const TBadge(label: 'Top 1%', color: Colors.amber),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DASHBOARD KPI SHOWCASE ====================
  Widget _buildDashboardShowcase(BuildContext context) {
    final colors = context.colors;
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TAlignedRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            left: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Store Analytics & KPIs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('Real-time overview for past 30 days', style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
                ],
              ),
            ],
            right: [
              TButton(
                type: TButtonType.outline,
                size: TButtonSize.sm,
                icon: HugeIcons.strokeRoundedDownload01,
                text: 'Export CSV',
                onTap: () => TToastService.info(context, 'Exporting analytical report...'),
              ),
              TButton(
                size: TButtonSize.sm,
                icon: HugeIcons.strokeRoundedRefresh,
                text: 'Refresh',
                onTap: () => TToastService.success(context, 'Metrics reloaded'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TMetricGrid(
            minTileWidth: 200,
            gapX: 14,
            gapY: 14,
            children: [
              TMetricTile(
                label: 'Gross Volume',
                value: '\$248,920.00',
                subtitle: 'Target: \$220,000 (+13.1%)',
                icon: HugeIcons.strokeRoundedBank,
                color: theme.success,
                trend: '+14.8%',
                trendUp: true,
                onTap: () => TToastService.info(context, 'Volume report opened'),
              ),
              TMetricTile(
                label: 'Active Subscriptions',
                value: '3,420',
                subtitle: '312 new subscriptions this month',
                icon: HugeIcons.strokeRoundedRefresh,
                color: theme.primary,
                trend: '+8.2%',
                trendUp: true,
                onTap: () => TToastService.info(context, 'Subscription list opened'),
              ),
              TMetricTile(
                label: 'Processing Orders',
                value: '184 orders',
                subtitle: 'Avg dispatch time: 1.4 hrs',
                icon: HugeIcons.strokeRoundedShoppingBag01,
                color: theme.warning,
                badge: const TBadge(label: 'Live', color: Colors.orange),
              ),
              TMetricTile(
                label: 'Global Uptime',
                value: '99.98%',
                subtitle: 'Zero critical disruptions recorded',
                icon: HugeIcons.strokeRoundedCloudCheck,
                color: theme.info,
                trend: '+0.04%',
                trendUp: true,
              ),
              TMetricTile(
                label: 'Customer Rating',
                value: '4.92 / 5.0',
                subtitle: 'From 1,840 verified customer reviews',
                icon: HugeIcons.strokeRoundedStar,
                color: Colors.amber,
                badge: const TBadge(label: 'Top Tier', color: Colors.amber),
              ),
              TMetricTile(
                label: 'Avg Order Value',
                value: '\$72.78',
                subtitle: 'Cross-sell conversion at 18.2%',
                icon: HugeIcons.strokeRoundedShoppingCart01,
                color: Colors.purple,
                trend: '+5.4%',
                trendUp: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================
  Widget _buildSectionHeader({required String title, required String subtitle, required dynamic icon}) {
    final colors = context.colors;
    final theme = context.theme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: theme.primary.withAlpha(25), borderRadius: BorderRadius.circular(8)),
          child: TIcon.raw(icon, color: theme.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.onSurface),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTileContainer(BuildContext context, {required Widget child}) {
    return child.card(
      backgroundColor: context.colors.surfaceContainerLowest,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: BorderRadius.circular(10),
    );
  }
}
