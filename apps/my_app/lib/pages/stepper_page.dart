import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

class StepperPage extends StatefulWidget {
  const StepperPage({super.key});

  @override
  State<StepperPage> createState() => _StepperPageState();
}

class _StepperPageState extends State<StepperPage> {
  int _verticalStep = 0;
  int _horizontalStep = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stepper',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: context.colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'A stepper displays progress through a sequence of logical and numbered steps.',
            style: TextStyle(fontSize: 16, color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),

          WidgetDocCard(
            title: 'Vertical Stepper',
            description: 'A vertical layout for multi-step processes.',
            icon: Icons.list,
            preview: TStepper(
              currentStep: _verticalStep,
              onStepTapped: (step) => setState(() => _verticalStep = step),
              steps: [
                TStep(
                  title: const Text('Account Information'),
                  subtitle: const Text('Enter your email and password'),
                  content: Column(
                    children: [
                      const TTextField(label: 'Email', placeholder: 'Enter your email'),
                      const SizedBox(height: 12),
                      const TTextField(label: 'Password', placeholder: 'Enter your password', obscureText: true),
                      const SizedBox(height: 16),
                      TButton(text: 'Continue', onTap: () => setState(() => _verticalStep = 1)),
                    ],
                  ),
                ),
                TStep(
                  title: const Text('Personal Details'),
                  subtitle: const Text('Enter your name and address'),
                  content: Column(
                    children: [
                      const TTextField(label: 'Full Name', placeholder: 'John Doe'),
                      const SizedBox(height: 12),
                      const TTextField(label: 'Address', placeholder: '123 Main St'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          TButton(text: 'Continue', onTap: () => setState(() => _verticalStep = 2)),
                          const SizedBox(width: 8),
                          TButton(text: 'Back', type: TButtonType.outline, onTap: () => setState(() => _verticalStep = 0)),
                        ],
                      ),
                    ],
                  ),
                ),
                TStep(
                  title: const Text('Confirm'),
                  content: Column(
                    children: [
                      const Text('Please review your information before submitting.'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          TButton(text: 'Submit', onTap: () {}),
                          const SizedBox(width: 8),
                          TButton(text: 'Back', type: TButtonType.outline, onTap: () => setState(() => _verticalStep = 1)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            code: '''TStepper(
  currentStep: _currentStep,
  type: TStepperType.vertical,
  onStepTapped: (step) => setState(() => _currentStep = step),
  steps: [
    TStep(
      title: Text('Account'),
      content: Text('Account content'),
    ),
    TStep(
      title: Text('Profile'),
      content: Text('Profile content'),
    ),
  ],
)''',
          ),

          const SizedBox(height: 32),

          WidgetDocCard(
            title: 'Horizontal Stepper',
            description: 'A horizontal layout for linear processes.',
            icon: Icons.linear_scale,
            preview: TStepper(
              type: TStepperType.horizontal,
              currentStep: _horizontalStep,
              onStepTapped: (step) => setState(() => _horizontalStep = step),
              steps: [
                TStep(
                  title: const Text('Step 1'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('First Step Content'),
                      const SizedBox(height: 16),
                      TButton(text: 'Next', onTap: () => setState(() => _horizontalStep = 1)),
                    ],
                  ),
                ),
                TStep(
                  title: const Text('Step 2'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Second Step Content'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          TButton(text: 'Next', onTap: () => setState(() => _horizontalStep = 2)),
                          const SizedBox(width: 8),
                          TButton(text: 'Back', type: TButtonType.outline, onTap: () => setState(() => _horizontalStep = 0)),
                        ],
                      ),
                    ],
                  ),
                ),
                TStep(
                  title: const Text('Step 3'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Final Step Content'),
                      const SizedBox(height: 16),
                      TButton(text: 'Finish', onTap: () {}),
                    ],
                  ),
                ),
              ],
            ),
            code: '''TStepper(
  currentStep: _currentStep,
  type: TStepperType.horizontal,
  onStepTapped: (step) => setState(() => _currentStep = step),
  steps: [
    TStep(title: Text('Step 1'), content: Text('Content 1')),
    TStep(title: Text('Step 2'), content: Text('Content 2')),
    TStep(title: Text('Step 3'), content: Text('Content 3')),
  ],
)''',
          ),
        ],
      ),
    );
  }
}
