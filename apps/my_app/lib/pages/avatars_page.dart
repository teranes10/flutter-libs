import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

/// Documentation page for Avatar widgets.
class AvatarsPage extends StatelessWidget {
  const AvatarsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Text(
            'Avatars',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Visual representations of users or entities, supporting images, initials, and icons.',
            style: TextStyle(
              fontSize: 16,
              color: context.colors.onSurface.withAlpha(179),
            ),
          ),
          const SizedBox(height: 32),

          // Basic Avatars
          WidgetDocCard(
            title: 'Image Avatars',
            description: 'Avatars using remote image URLs',
            icon: Icons.face,
            preview: Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TAvatar(
                  url: 'https://i.pravatar.cc/150?u=1',
                  size: TInputSize.xs,
                ),
                TAvatar(
                  url: 'https://i.pravatar.cc/150?u=2',
                  size: TInputSize.sm,
                ),
                TAvatar(
                  url: 'https://i.pravatar.cc/150?u=3',
                  size: TInputSize.md,
                ),
                TAvatar(
                  url: 'https://i.pravatar.cc/150?u=4',
                  size: TInputSize.lg,
                ),
              ],
            ),
            code: '''TAvatar(
  url: 'https://i.pravatar.cc/150',
  size: TInputSize.md,
)''',
            properties: const [
              PropertyDoc(name: 'url', type: 'String?', description: 'The URL of the avatar image'),
              PropertyDoc(name: 'size', type: 'TInputSize', defaultValue: 'TInputSize.md', description: 'Standardized size of the avatar'),
            ],
          ),

          // Initials Avatars
          WidgetDocCard(
            title: 'Initials Avatars',
            description: 'Automatically generates initials from a name',
            icon: Icons.text_fields,
            preview: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                TAvatar(name: 'John Doe', backgroundColor: Colors.blue.shade100, foregroundColor: Colors.blue.shade900),
                TAvatar(name: 'Jane Smith', backgroundColor: Colors.green.shade100, foregroundColor: Colors.green.shade900),
                TAvatar(name: 'Bob', backgroundColor: Colors.orange.shade100, foregroundColor: Colors.orange.shade900),
                TAvatar(name: 'Alice Wonder', backgroundColor: Colors.purple.shade100, foregroundColor: Colors.purple.shade900),
              ],
            ),
            code: '''TAvatar(
  name: 'John Doe',
  backgroundColor: Colors.blue.shade100,
  foregroundColor: Colors.blue.shade900,
)''',
            properties: const [
              PropertyDoc(name: 'name', type: 'String?', description: 'Name used to generate initials (e.g., "John Doe" -> "JD")'),
              PropertyDoc(name: 'backgroundColor', type: 'Color?', description: 'Background color for initials'),
              PropertyDoc(name: 'foregroundColor', type: 'Color?', description: 'Text color for initials'),
            ],
          ),

          // Shapes
          WidgetDocCard(
            title: 'Shapes',
            description: 'Circular and square (rounded) variants',
            icon: Icons.shape_line,
            preview: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                TAvatar(name: 'Circle', shape: BoxShape.circle),
                TAvatar.square(name: 'Square', borderRadius: BorderRadius.circular(8)),
                TAvatar.square(name: 'Rounded', borderRadius: BorderRadius.circular(16)),
              ],
            ),
            code: '''// Default Circle
TAvatar(name: 'JD')

// Square/Rounded
TAvatar.square(
  name: 'JD',
  borderRadius: BorderRadius.circular(8),
)''',
            properties: const [
              PropertyDoc(name: 'shape', type: 'BoxShape', defaultValue: 'BoxShape.circle', description: 'The shape of the avatar'),
              PropertyDoc(name: 'borderRadius', type: 'BorderRadius?', description: 'Border radius for square shape'),
            ],
          ),

          // Fallback Icon
          WidgetDocCard(
            title: 'Fallback Icon',
            description: 'Displays a generic icon when no image or name is provided',
            icon: Icons.person_outline,
            preview: const Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                TAvatar(size: TInputSize.sm),
                TAvatar(size: TInputSize.md),
                TAvatar(size: TInputSize.lg),
              ],
            ),
            code: '''TAvatar(size: TInputSize.md)''',
          ),

          // Profile Style
          WidgetDocCard(
            title: 'Profile Style',
            description: 'Avatar combined with title and subtitle (e.g., name and role)',
            icon: Icons.account_box,
            preview: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TAvatar(
                  url: 'https://i.pravatar.cc/150?u=5',
                  title: 'Teranes Ranjith',
                  subTitle: 'Super Admin',
                  size: TInputSize.md,
                ),
                SizedBox(height: 16),
                TAvatar(
                  name: 'Jane Smith',
                  title: 'Jane Smith',
                  subTitle: 'Product Designer',
                  size: TInputSize.sm,
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                SizedBox(height: 16),
                TAvatar.square(
                  name: 'Company Inc',
                  title: 'Company Inc',
                  subTitle: 'Premium Workspace',
                  size: TInputSize.lg,
                ),
              ],
            ),
            code: '''TAvatar(
  url: 'https://i.pravatar.cc/150',
  title: 'Teranes Ranjith',
  subTitle: 'Super Admin',
  size: TInputSize.md,
)

// With Initials
TAvatar(
  name: 'Jane Smith',
  title: 'Jane Smith',
  subTitle: 'Product Designer',
  size: TInputSize.sm,
)''',
            properties: const [
              PropertyDoc(name: 'title', type: 'String?', description: 'Title text displayed next to the avatar'),
              PropertyDoc(name: 'subTitle', type: 'String?', description: 'Subtitle text displayed below the title'),
              PropertyDoc(name: 'spacing', type: 'double', defaultValue: '8', description: 'Spacing between avatar and text'),
            ],
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
