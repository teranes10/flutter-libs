import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'A timeline displays sequential milestones, events, or tracking steps with circular icons, colored status rings, dashed lines, and detailed titles, subtitles, and descriptions.',
            style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),

          // Section 1: Order Tracking / Status Timeline with Dashed Lines & Ring Indicators
          WidgetDocCard(
            title: 'Order Status Timeline',
            description:
                'Circle indicators surrounded by colored status rings with inner icons, connecting dashed lines, title, subtitle, and description for every step.',
            icon: HugeIcons.strokeRoundedTimeline,
            preview: TTimeline(
              lineStyle: TTimelineLineStyle.dashed,
              dashLength: 5.0,
              dashGap: 3.5,
              items: [
                TTimelineItem(
                  titleText: 'Order Placed & Verified',
                  subtitleText: 'Order #ORD-2026-8942',
                  descriptionText: 'Customer confirmed payment of \$149.00 via Apple Pay. Order details sent to dispatch team.',
                  timeText: '09:30 AM',
                  iconData: HugeIcons.strokeRoundedTick01,
                  color: context.theme.success,
                  isCompleted: true,
                ),
                TTimelineItem(
                  titleText: 'Packaging & Quality Check',
                  subtitleText: 'Warehouse Hub B, Bay 14',
                  descriptionText: 'All 3 items packed securely with bubble wrap and passed barcode verification.',
                  timeText: '11:45 AM',
                  iconData: HugeIcons.strokeRoundedPackage,
                  color: context.theme.success,
                  isCompleted: true,
                ),
                TTimelineItem(
                  titleText: 'Dispatched with Courier',
                  subtitleText: 'FedEx Express (Tracking #9400 1118 9956 0000)',
                  descriptionText: 'Courier driver picked up the shipment and is currently en route to the regional sorting center.',
                  timeText: '02:15 PM',
                  iconData: HugeIcons.strokeRoundedDeliveryTruck01,
                  color: context.theme.primary,
                  isActive: true,
                  content: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.outlineVariant.withAlpha(80)),
                    ),
                    child: Row(
                      children: [
                        TIcon.raw(HugeIcons.strokeRoundedLocationUser01, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Assigned Driver: Alex Morgan • Vehicle #CA-8821',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.onSurface),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                TTimelineItem(
                  titleText: 'Customs & Clearance Delay',
                  subtitleText: 'Border Checkpoint #3',
                  descriptionText: 'Routine inspection in progress. Expected clearance within 2 hours.',
                  timeText: '04:00 PM',
                  iconData: HugeIcons.strokeRoundedAlert02,
                  color: context.theme.warning,
                ),
                TTimelineItem(
                  titleText: 'Delivered to Customer',
                  subtitleText: 'Estimated delivery: Tomorrow by 10:00 AM',
                  descriptionText: 'Recipient signature required upon handover at 742 Evergreen Terrace.',
                  timeText: 'Pending',
                  iconData: HugeIcons.strokeRoundedHome01,
                  color: context.theme.grey,
                ),
              ],
            ),
            code: '''TTimeline(
  lineStyle: TTimelineLineStyle.dashed,
  items: [
    TTimelineItem(
      titleText: 'Order Placed & Verified',
      subtitleText: 'Order #ORD-2026-8942',
      descriptionText: 'Customer confirmed payment. Order sent to dispatch.',
      timeText: '09:30 AM',
      iconData: HugeIcons.strokeRoundedTick01,
      color: context.theme.success,
      isCompleted: true,
    ),
    TTimelineItem(
      titleText: 'Dispatched with Courier',
      subtitleText: 'FedEx Express (Tracking #9400...)',
      descriptionText: 'Courier driver picked up shipment and is en route.',
      timeText: '02:15 PM',
      iconData: HugeIcons.strokeRoundedDeliveryTruck01,
      color: context.theme.primary,
      isActive: true,
    ),
    TTimelineItem(
      titleText: 'Customs & Clearance Delay',
      subtitleText: 'Border Checkpoint #3',
      descriptionText: 'Routine inspection in progress.',
      iconData: HugeIcons.strokeRoundedAlert02,
      color: context.theme.warning,
    ),
    TTimelineItem(
      titleText: 'Delivered to Customer',
      subtitleText: 'Estimated: Tomorrow by 10:00 AM',
      descriptionText: 'Recipient signature required.',
      iconData: HugeIcons.strokeRoundedHome01,
      color: context.theme.grey,
    ),
  ],
)''',
          ),

          const SizedBox(height: 32),

          // Section 2: Indicator Variants (Tonal, Solid, Outline, SoftOutline, Dot)
          WidgetDocCard(
            title: 'Indicator Ring Variants & TVariant Styles',
            description: 'Support for TVariant styles including tonal, solid, outline, softOutline, and dot indicator.',
            icon: HugeIcons.strokeRoundedPaintBoard,
            preview: TTimeline(
              lineStyle: TTimelineLineStyle.dashed,
              items: [
                TTimelineItem(
                  titleText: 'Tonal Variant (Default - Success)',
                  subtitleText: 'Soft tinted background with colored icon and ring',
                  descriptionText: 'Clean modern look with subtle container elevation.',
                  iconData: HugeIcons.strokeRoundedCheckmarkCircle01,
                  color: context.theme.success,
                  variant: TVariant.tonal,
                ),
                TTimelineItem(
                  titleText: 'Solid Variant (Primary)',
                  subtitleText: 'Filled color circle with white icon',
                  descriptionText: 'Bold, high-contrast indicator for prominent milestones.',
                  iconData: HugeIcons.strokeRoundedTickDouble01,
                  color: context.theme.primary,
                  variant: TVariant.solid,
                ),
                TTimelineItem(
                  titleText: 'Outline Variant (Info)',
                  subtitleText: 'Clean outline with surface background and colored icon',
                  descriptionText: 'Subtle and elegant appearance matching secondary status items.',
                  iconData: HugeIcons.strokeRoundedInformationCircle,
                  color: context.theme.info,
                  variant: TVariant.outline,
                ),
                TTimelineItem(
                  titleText: 'Soft Outline Variant (Danger / Alert)',
                  subtitleText: 'Soft outline styling with colored ring and icon',
                  descriptionText: 'Highlights warnings or errors with clean colored outline border.',
                  iconData: HugeIcons.strokeRoundedAlertCircle,
                  color: context.theme.danger,
                  variant: TVariant.softOutline,
                ),
                TTimelineItem(
                  titleText: 'Dot Indicator (Neutral)',
                  subtitleText: 'Minimalist center dot surrounded by ring',
                  descriptionText: 'Compact and modern styling for minor steps or checkpoints.',
                  indicator: const TTimelineIndicator.dot(),
                ),
              ],
            ),
            code: '''TTimeline(
  lineStyle: TTimelineLineStyle.dashed,
  items: [
    TTimelineItem(
      titleText: 'Tonal Variant (Default)',
      iconData: HugeIcons.strokeRoundedCheckmarkCircle01,
      color: context.theme.success,
      variant: TVariant.tonal,
    ),
    TTimelineItem(
      titleText: 'Solid Variant',
      iconData: HugeIcons.strokeRoundedTickDouble01,
      color: context.theme.primary,
      variant: TVariant.solid,
    ),
    TTimelineItem(
      titleText: 'Outline Variant',
      iconData: HugeIcons.strokeRoundedInformationCircle,
      color: context.theme.info,
      variant: TVariant.outline,
    ),
    TTimelineItem(
      titleText: 'Soft Outline Variant',
      iconData: HugeIcons.strokeRoundedAlertCircle,
      color: context.theme.danger,
      variant: TVariant.softOutline,
    ),
    TTimelineItem(
      titleText: 'Dot Indicator',
      indicator: const TTimelineIndicator.dot(),
    ),
  ],
)''',
          ),

          const SizedBox(height: 32),

          // Section 3: Horizontal Timeline Preview
          WidgetDocCard(
            title: 'Horizontal Timeline',
            description: 'Horizontal layout with dashed connectors for multi-phase progression and workflows.',
            icon: HugeIcons.strokeRoundedScale,
            preview: TTimeline(
              direction: Axis.horizontal,
              lineStyle: TTimelineLineStyle.dashed,
              items: [
                TTimelineItem(
                  titleText: 'Phase 1: Planning',
                  subtitleText: 'Requirements & Design',
                  descriptionText: 'User stories approved and mockups finalized.',
                  timeText: 'Jan 15',
                  iconData: HugeIcons.strokeRoundedWebDesign02,
                  color: context.theme.success,
                  isCompleted: true,
                ),
                TTimelineItem(
                  titleText: 'Phase 2: Development',
                  subtitleText: 'Sprint 1 - 4',
                  descriptionText: 'Core services built and integrated with API.',
                  timeText: 'Feb 20',
                  iconData: HugeIcons.strokeRoundedCodeSquare,
                  color: context.theme.primary,
                  isActive: true,
                ),
                TTimelineItem(
                  titleText: 'Phase 3: QA & Testing',
                  subtitleText: 'End-to-end tests',
                  descriptionText: 'Automated test suite and security audit.',
                  timeText: 'Mar 10',
                  iconData: HugeIcons.strokeRoundedBug02,
                  color: context.theme.warning,
                ),
                TTimelineItem(
                  titleText: 'Phase 4: Release',
                  subtitleText: 'Production Deploy',
                  descriptionText: 'Deploy to multi-region cloud cluster.',
                  timeText: 'Apr 01',
                  iconData: HugeIcons.strokeRoundedRocket,
                  color: context.theme.grey,
                ),
              ],
            ),
            code: '''TTimeline(
  direction: Axis.horizontal,
  lineStyle: TTimelineLineStyle.dashed,
  items: [
    TTimelineItem(
      titleText: 'Phase 1: Planning',
      subtitleText: 'Requirements & Design',
      descriptionText: 'User stories approved.',
      timeText: 'Jan 15',
      iconData: HugeIcons.strokeRoundedWebDesign02,
      color: context.theme.success,
      isCompleted: true,
    ),
    TTimelineItem(
      titleText: 'Phase 2: Development',
      subtitleText: 'Sprint 1 - 4',
      descriptionText: 'Core services built.',
      timeText: 'Feb 20',
      iconData: HugeIcons.strokeRoundedCodeSquare,
      color: context.theme.primary,
      isActive: true,
    ),
    TTimelineItem(
      titleText: 'Phase 3: QA & Testing',
      subtitleText: 'End-to-end tests',
      descriptionText: 'Automated test suite.',
      timeText: 'Mar 10',
      iconData: HugeIcons.strokeRoundedBug02,
      color: context.theme.warning,
    ),
    TTimelineItem(
      titleText: 'Phase 4: Release',
      subtitleText: 'Production Deploy',
      descriptionText: 'Deploy to cloud cluster.',
      timeText: 'Apr 01',
      iconData: HugeIcons.strokeRoundedRocket,
      color: context.theme.grey,
    ),
  ],
)''',
          ),
        ],
      ),
    );
  }
}
