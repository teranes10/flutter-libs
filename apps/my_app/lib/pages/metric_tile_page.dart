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

  // Selected tile for TTile active state demo
  int _selectedTileIndex = 0;

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
              TChip.tonal(text: 'TMetricGrid', icon: Icons.grid_view_rounded, color: theme.primary),
              TChip.tonal(text: 'TMetricTile', icon: Icons.speed_rounded, color: theme.info),
              TChip.tonal(text: 'TTile', icon: Icons.splitscreen_rounded, color: theme.success),
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
            icon: Icons.grid_view_rounded,
          ),
          const SizedBox(height: 16),

          // 2.1 Auto-Responsive Columns
          WidgetDocCard(
            title: 'Auto-Responsive Columns (minTileWidth)',
            description:
                'Derives optimal column count dynamically from available container width and minTileWidth without hardcoded breakpoint spans.',
            icon: Icons.auto_awesome_mosaic_rounded,
            preview: TMetricGrid(
              minTileWidth: 210,
              gapX: 12,
              gapY: 12,
              children: [
                TMetricTile(
                  label: 'Gross Sales',
                  value: '\$84,230.00',
                  subtitle: '+18.2% vs last month',
                  icon: Icons.payments_rounded,
                  color: theme.success,
                  trend: '+18.2%',
                  trendUp: true,
                ),
                TMetricTile(
                  label: 'Net Profit',
                  value: '\$29,450.00',
                  subtitle: 'Margin: 34.9%',
                  icon: Icons.account_balance_wallet_rounded,
                  color: theme.primary,
                  trend: '+4.5%',
                  trendUp: true,
                ),
                TMetricTile(
                  label: 'Refunds & Returns',
                  value: '\$1,120.00',
                  subtitle: '14 return requests',
                  icon: Icons.assignment_return_rounded,
                  color: theme.danger,
                  trend: '-1.8%',
                  trendUp: false,
                ),
                TMetricTile(
                  label: 'Pending Shipments',
                  value: '48 orders',
                  subtitle: 'All in packaging queue',
                  icon: Icons.local_shipping_rounded,
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
      icon: Icons.payments_rounded,
      color: context.theme.success,
      trend: '+18.2%',
      trendUp: true,
    ),
    TMetricTile(
      label: 'Net Profit',
      value: '\$29,450.00',
      subtitle: 'Margin: 34.9%',
      icon: Icons.account_balance_wallet_rounded,
      color: context.theme.primary,
      trend: '+4.5%',
      trendUp: true,
    ),
    TMetricTile(
      label: 'Refunds & Returns',
      value: '\$1,120.00',
      subtitle: '14 return requests',
      icon: Icons.assignment_return_rounded,
      color: context.theme.danger,
      trend: '-1.8%',
      trendUp: false,
    ),
    TMetricTile(
      label: 'Pending Shipments',
      value: '48 orders',
      subtitle: 'All in packaging queue',
      icon: Icons.local_shipping_rounded,
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
            icon: Icons.align_vertical_bottom_rounded,
            preview: TMetricGrid(
              minTileWidth: 220,
              uniformHeight: true,
              children: [
                TMetricTile(label: 'Single-line Content', value: '1,240', icon: Icons.filter_1_rounded, color: theme.primary),
                TMetricTile(
                  label: 'One-line Subtitle',
                  value: '4,890',
                  subtitle: 'Target: 5,000 units',
                  icon: Icons.filter_2_rounded,
                  color: theme.info,
                  trend: '+3.1%',
                  trendUp: true,
                ),
                TMetricTile(
                  label: 'Multi-line Subtitle',
                  value: '99.9%',
                  subtitle: 'Aggregated SLA across US-East, EU-Central, and AP-South regions',
                  icon: Icons.filter_3_rounded,
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
      icon: Icons.filter_1_rounded,
    ),
    TMetricTile(
      label: 'One-line Subtitle',
      value: '4,890',
      subtitle: 'Target: 5,000 units',
      icon: Icons.filter_2_rounded,
    ),
    TMetricTile(
      label: 'Multi-line Subtitle',
      value: '99.9%',
      subtitle: 'Aggregated SLA across US-East, EU-Central, and AP-South regions',
      icon: Icons.filter_3_rounded,
    ),
  ],
)''',
          ),

          const SizedBox(height: 24),

          // 2.3 Pinned Columns
          WidgetDocCard(
            title: 'Pinned Column Count (columns: 2 / 4)',
            description: 'Override the automatic width calculation to enforce a precise column count across all container widths.',
            icon: Icons.view_column_rounded,
            preview: TMetricGrid(
              columns: 2,
              gapX: 12,
              gapY: 12,
              children: [
                TMetricTile(
                  label: 'API Request Rate',
                  value: '4,280 req/s',
                  subtitle: 'Peak throughput: 6,100 req/s',
                  icon: Icons.speed_rounded,
                  color: theme.info,
                  trend: '+12.4%',
                  trendUp: true,
                ),
                TMetricTile(
                  label: 'Error Rate',
                  value: '0.04%',
                  subtitle: 'Threshold budget: < 0.10%',
                  icon: Icons.error_outline_rounded,
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
      icon: Icons.speed_rounded,
      color: context.theme.info,
      trend: '+12.4%',
      trendUp: true,
    ),
    TMetricTile(
      label: 'Error Rate',
      value: '0.04%',
      subtitle: 'Threshold budget: < 0.10%',
      icon: Icons.error_outline_rounded,
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
            icon: Icons.speed_rounded,
          ),
          const SizedBox(height: 16),

          // 3.1 Trends & Colors
          WidgetDocCard(
            title: 'Trend Indicators & Color Themes',
            description: 'Directional percentage badges with trendUp (green positive arrow) or trendDown (red negative arrow).',
            icon: Icons.trending_up_rounded,
            preview: TMetricGrid(
              minTileWidth: 200,
              children: [
                TMetricTile(
                  label: 'Annual Recurring Revenue',
                  value: '\$1.42M',
                  subtitle: 'Target: \$1.50M by Q4',
                  icon: Icons.trending_up_rounded,
                  color: theme.success,
                  trend: '+24.8%',
                  trendUp: true,
                ),
                TMetricTile(
                  label: 'Customer Churn Rate',
                  value: '3.4%',
                  subtitle: '+0.6% vs benchmark',
                  icon: Icons.person_remove_rounded,
                  color: theme.danger,
                  trend: '+0.6%',
                  trendUp: false,
                ),
                TMetricTile(
                  label: 'Average Resolution Time',
                  value: '18m 42s',
                  subtitle: '-4m 12s reduction',
                  icon: Icons.timelapse_rounded,
                  color: theme.info,
                  trend: '-18.5%',
                  trendUp: true, // Improvement!
                ),
                TMetricTile(
                  label: 'Active System Nodes',
                  value: '32 / 32',
                  subtitle: 'All health checks passing',
                  icon: Icons.dns_rounded,
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
  icon: Icons.trending_up_rounded,
  color: context.theme.success,
  trend: '+24.8%',
  trendUp: true, // Displays green trending_up badge
)

TMetricTile(
  label: 'Customer Churn Rate',
  value: '3.4%',
  subtitle: '+0.6% vs benchmark',
  icon: Icons.person_remove_rounded,
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
            icon: Icons.touch_app_rounded,
            preview: TMetricGrid(
              minTileWidth: 220,
              children: [
                TMetricTile(
                  label: 'Pending Invoices',
                  value: '14 unpaid',
                  subtitle: 'Tap to view overdue list',
                  icon: Icons.receipt_long_rounded,
                  color: theme.warning,
                  badge: const TBadge(label: 'Action Needed', color: Colors.amber),
                  tooltip: 'Invoices outstanding past standard 30-day net terms',
                  onTap: () => TToastService.info(context, 'Navigating to unpaid invoices...'),
                ),
                TMetricTile(
                  label: 'Security Audit',
                  value: 'Passed',
                  subtitle: 'Checked 5 mins ago',
                  icon: Icons.verified_user_rounded,
                  color: theme.success,
                  badge: const TBadge(label: 'SOC 2', color: Colors.green),
                  tooltip: 'Automated compliance scan verified across infrastructure',
                  onTap: () => TToastService.success(context, 'Security audit report ready'),
                ),
                TMetricTile(
                  label: 'Custom Trailing Widget',
                  value: '3 Reports',
                  subtitle: 'Generated today',
                  icon: Icons.analytics_rounded,
                  color: theme.primary,
                  trailing: TButton(
                    icon: Icons.download_rounded,
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
  icon: Icons.receipt_long_rounded,
  color: context.theme.warning,
  badge: TBadge(label: 'Action Needed', color: Colors.amber),
  tooltip: 'Invoices outstanding past standard 30-day net terms',
  onTap: () => handleViewInvoices(), // Renders InkWell + trailing chevron
)

TMetricTile(
  label: 'Custom Trailing Widget',
  value: '3 Reports',
  subtitle: 'Generated today',
  icon: Icons.analytics_rounded,
  color: context.theme.primary,
  trailing: TButton(
    icon: Icons.download_rounded,
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
            icon: Icons.compress_rounded,
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
                      icon: Icons.memory_rounded,
                      color: theme.primary,
                      trend: '+1.2%',
                      trendUp: false,
                    ),
                    TMetricTile(
                      compact: true,
                      label: 'RAM Load',
                      value: '12.4 GB',
                      subtitle: '16 GB allocated',
                      icon: Icons.developer_board_rounded,
                      color: theme.info,
                    ),
                    TMetricTile(
                      compact: true,
                      label: 'Network I/O',
                      value: '840 MB/s',
                      icon: Icons.swap_vert_rounded,
                      color: theme.success,
                      trend: '+8%',
                      trendUp: true,
                    ),
                    TMetricTile(
                      compact: true,
                      label: 'Disk Free',
                      value: '384 GB',
                      subtitle: 'SSD NVMe',
                      icon: Icons.storage_rounded,
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
  icon: Icons.memory_rounded,
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
            icon: Icons.splitscreen_rounded,
          ),
          const SizedBox(height: 16),

          // 4.0 Heading Sizing Scale (h1 to h6)
          WidgetDocCard(
            title: 'Heading Sizes (TTile.h1 to TTile.h6)',
            description:
                'Standardized heading scale matching typography hierarchies from h1 (page/hero headers) down to h6 (compact/dense rows). Named constructors or size: TTileSize.* are supported.',
            icon: Icons.format_size_rounded,
            preview: Column(
              children: [
                _buildTileContainer(
                  context,
                  child: TTile.h1(
                    icon: Icons.looks_one_rounded,
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
                    icon: Icons.looks_two_rounded,
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
                    icon: Icons.looks_3_rounded,
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
                    icon: Icons.looks_4_rounded,
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
                    icon: Icons.looks_5_rounded,
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
                    icon: Icons.looks_6_rounded,
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
  icon: Icons.dashboard_rounded,
)

TTile.h2(
  title: 'Section Header (h2)',
  subtitle: 'Major subsection text',
  icon: Icons.folder_rounded,
)

TTile.h3(title: 'Card Title (h3)', subtitle: 'Card info', icon: Icons.feed)
TTile.h4(title: 'Prominent Item (h4)', subtitle: 'Item details', icon: Icons.star)
TTile.h5(title: 'Standard Default (h5)', subtitle: 'List item', icon: Icons.list)
TTile.h6(title: 'Compact Row (h6)', subtitle: 'Dense item', icon: Icons.tune)

// 2. Or using the size property:
TTile(
  size: TTileSize.h2,
  title: 'Configurable Tile Size',
  subtitle: 'Scales title, subtitle, icon, padding, and spacing uniformly',
  icon: Icons.auto_awesome,
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
            icon: Icons.palette_outlined,
            preview: Column(
              children: [
                _buildTileContainer(
                  context,
                  child: TTile(
                    icon: Icons.cloud_done_rounded,
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
                    icon: Icons.security_update_warning_rounded,
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
                    icon: Icons.insights_rounded,
                    iconBackgroundColor: theme.primary.withAlpha(25),
                    iconColor: theme.primary,
                    iconBorderRadius: BorderRadius.circular(24), // Circular icon badge
                    title: 'Traffic Surge Detected',
                    subtitle: '+140% incoming sessions from direct campaign',
                    trailing: Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            code: '''TTile(
  icon: Icons.cloud_done_rounded,
  iconBackgroundColor: context.theme.success.withAlpha(25),
  iconColor: context.theme.success,
  title: 'Cloud Backup Complete',
  subtitle: '4.8 GB synchronized to storage bucket',
  trailing: TBadge(label: 'Verified', color: Colors.green),
)

// Circular icon container:
TTile(
  icon: Icons.insights_rounded,
  iconBackgroundColor: context.theme.primary.withAlpha(25),
  iconColor: context.theme.primary,
  iconBorderRadius: BorderRadius.circular(24),
  title: 'Traffic Surge Detected',
  subtitle: '+140% incoming sessions',
  trailing: Icon(Icons.chevron_right_rounded),
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
            icon: Icons.widgets_rounded,
            preview: Column(
              children: [
                _buildTileContainer(
                  context,
                  child: TTile(
                    icon: Icons.notifications_active_rounded,
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
                        Icon(Icons.shield_outlined, size: 13, color: colors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text('Lead Security Engineer • Active now', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                      ],
                    ),
                    trailing: TButton(
                      size: TButtonSize.xs,
                      type: TButtonType.outline,
                      text: 'Message',
                      icon: Icons.chat_bubble_outline_rounded,
                      onTap: () => TToastService.info(context, 'Opening chat with Sarah...'),
                    ),
                  ),
                ),
              ],
            ),
            code: '''TTile(
  icon: Icons.notifications_active_rounded,
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
            icon: Icons.toggle_on_rounded,
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
                        icon: [Icons.inventory_2_rounded, Icons.analytics_rounded, Icons.settings_suggest_rounded][i],
                        title: ['Product Catalog', 'Analytics Dashboard', 'System Preferences'][i],
                        subtitle: [
                          '1,420 SKU records active',
                          'Realtime funnel conversion metrics',
                          'API keys and webhook web dispatchers',
                        ][i],
                        trailing: _selectedTileIndex == i
                            ? TBadge(label: 'Active', color: theme.primary)
                            : const Icon(Icons.radio_button_off, size: 18),
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
  icon: Icons.inventory_2_rounded,
  title: 'Product Catalog',
  subtitle: '1,420 SKU records active',
  trailing: isSelected
      ? TBadge(label: 'Active', color: context.theme.primary)
      : Icon(Icons.radio_button_off),
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

          const SizedBox(height: 36),

          // ==================== SECTION 5: REALISTIC DASHBOARD SUMMARY ====================
          _buildSectionHeader(
            title: '4. Executive Dashboard Example',
            subtitle: 'A complete production-ready KPI dashboard header powered by TMetricGrid and TMetricTile widgets.',
            icon: Icons.dashboard_customize_rounded,
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
                  child: Icon(Icons.tune_rounded, color: theme.primary, size: 20),
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
                  label: 'Total Revenue',
                  value: '\$148,290.00',
                  subtitle: '+14.2% from prior period',
                  icon: Icons.monetization_on_rounded,
                  color: theme.success,
                  trend: '+14.2%',
                  trendUp: true,
                  onTap: () => TToastService.info(context, 'Total Revenue clicked'),
                ),
                TMetricTile(
                  compact: _playgroundCompact,
                  label: 'New Customers',
                  value: '1,842',
                  subtitle: '89 acquired via referral program',
                  icon: Icons.people_alt_rounded,
                  color: theme.primary,
                  trend: '+6.1%',
                  trendUp: true,
                  badge: const TBadge(label: 'Growing', color: Colors.blue),
                  onTap: () => TToastService.info(context, 'New Customers clicked'),
                ),
                TMetricTile(
                  compact: _playgroundCompact,
                  label: 'Server Load',
                  value: '84.2%',
                  subtitle: 'Noticeable CPU spike in cluster node 4',
                  icon: Icons.dns_rounded,
                  color: theme.warning,
                  trend: '+12.0%',
                  trendUp: false,
                  tooltip: 'Calculated over the last 15 minutes across all pods',
                  onTap: () => TToastService.warning(context, 'Cluster node warning inspect'),
                ),
                TMetricTile(
                  compact: _playgroundCompact,
                  label: 'Pending Approvals',
                  value: '19',
                  subtitle: 'Requires supervisor sign-off',
                  icon: Icons.pending_actions_rounded,
                  color: theme.danger,
                  badge: const TBadge(label: 'Urgent', color: Colors.red),
                  onTap: () => TToastService.error(context, '19 Approvals pending'),
                ),
                TMetricTile(
                  compact: _playgroundCompact,
                  label: 'Fulfillment Rate',
                  value: '99.4%',
                  subtitle: 'Avg ship duration: 1.2 business days',
                  icon: Icons.local_shipping_rounded,
                  color: theme.info,
                  trend: '+0.4%',
                  trendUp: true,
                ),
                TMetricTile(
                  compact: _playgroundCompact,
                  label: 'Customer CSAT',
                  value: '4.9 / 5.0',
                  subtitle: 'Based on 2,420 customer feedback surveys',
                  icon: Icons.star_rate_rounded,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Store Analytics & KPIs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('Real-time overview for past 30 days', style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
                ],
              ),
              Row(
                children: [
                  TButton(
                    type: TButtonType.outline,
                    size: TButtonSize.sm,
                    icon: Icons.file_download_outlined,
                    text: 'Export CSV',
                    onTap: () => TToastService.info(context, 'Exporting analytical report...'),
                  ),
                  const SizedBox(width: 8),
                  TButton(
                    size: TButtonSize.sm,
                    icon: Icons.refresh_rounded,
                    text: 'Refresh',
                    onTap: () => TToastService.success(context, 'Metrics reloaded'),
                  ),
                ],
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
                icon: Icons.account_balance_rounded,
                color: theme.success,
                trend: '+14.8%',
                trendUp: true,
                onTap: () => TToastService.info(context, 'Volume report opened'),
              ),
              TMetricTile(
                label: 'Active Subscriptions',
                value: '3,420',
                subtitle: '312 new subscriptions this month',
                icon: Icons.autorenew_rounded,
                color: theme.primary,
                trend: '+8.2%',
                trendUp: true,
                onTap: () => TToastService.info(context, 'Subscription list opened'),
              ),
              TMetricTile(
                label: 'Processing Orders',
                value: '184 orders',
                subtitle: 'Avg dispatch time: 1.4 hrs',
                icon: Icons.local_mall_rounded,
                color: theme.warning,
                badge: const TBadge(label: 'Live', color: Colors.orange),
              ),
              TMetricTile(
                label: 'Global Uptime',
                value: '99.98%',
                subtitle: 'Zero critical disruptions recorded',
                icon: Icons.cloud_done_rounded,
                color: theme.info,
                trend: '+0.04%',
                trendUp: true,
              ),
              TMetricTile(
                label: 'Customer Rating',
                value: '4.92 / 5.0',
                subtitle: 'From 1,840 verified customer reviews',
                icon: Icons.star_rounded,
                color: Colors.amber,
                badge: const TBadge(label: 'Top Tier', color: Colors.amber),
              ),
              TMetricTile(
                label: 'Avg Order Value',
                value: '\$72.78',
                subtitle: 'Cross-sell conversion at 18.2%',
                icon: Icons.shopping_cart_checkout_rounded,
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
  Widget _buildSectionHeader({required String title, required String subtitle, required IconData icon}) {
    final colors = context.colors;
    final theme = context.theme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: theme.primary.withAlpha(25), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: theme.primary, size: 22),
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
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant.withAlpha(80)),
      ),
      child: child,
    );
  }
}
