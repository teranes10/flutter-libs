import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/mobile_device_frame.dart';
import 'package:my_app/widgets/map_pinning_widget.dart';

class DeliveryPage extends StatefulWidget {
  final int initialStep;
  const DeliveryPage({super.key, this.initialStep = 0});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  late int _currentStep;
  String _packageType = 'Parcel';
  String _deliveryType = 'Express';
  final TextEditingController _itemController = TextEditingController(text: 'Consumer goods');
  int weight = 30;
  int quantity = 1;
  bool _isFragile = true;

  // Sender Details (Pickup)
  final TextEditingController _senderNameController = TextEditingController(text: 'John Doe');
  final TextEditingController _senderPhoneController = TextEditingController(text: '077 123 4567');
  final TextEditingController _pickupAddressController = TextEditingController(text: '123 Main St, Colombo');
  String _pickupCoordinates = "6.9271, 79.8612";

  // Receiver Details (Drop-off)
  final TextEditingController _receiverNameController = TextEditingController(text: 'Jane Smith');
  final TextEditingController _receiverPhoneController = TextEditingController(text: '071 987 6543');
  final TextEditingController _dropoffAddressController = TextEditingController(text: '456 High St, Kandy');
  String _dropoffCoordinates = "7.2906, 80.6337";

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery App Samples',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: context.colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'High-fidelity mockups of the Delivery App screens implemented using te_widgets.',
            style: TextStyle(fontSize: 16, color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          Center(
            child: TMobileDeviceFrame(
              title: _currentStep == 0 ? 'Pickup & Drop-off' : (_currentStep == 1 ? 'Package Information' : 'Review & Confirm Order'),
              onBackPressed: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                }
              },
              bottomBarItems: [
                const TBottomBarItem(icon: Icons.home_outlined, label: 'Home'),
                const TBottomBarItem(icon: Icons.assignment_outlined, label: 'Orders'),
                const TBottomBarItem(icon: Icons.inventory_2, label: 'Create'),
                const TBottomBarItem(icon: Icons.person_outline, label: 'Profile'),
              ],
              currentBottomIndex: 2, // 'Create' is selected
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: TStepper(
                  type: TStepperType.horizontal,
                  currentStep: _currentStep,
                  titleBelowIndicator: true,
                  steps: [
                    TStep(title: const Text('Pickup & Drop'), content: _buildPickupDropStep(context)),
                    TStep(title: const Text('Package Details'), content: _buildPackageInfoStep(context)),
                    TStep(title: const Text('Review & Confirm'), content: _buildPackageSummaryStep(context)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupDropStep(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sender Details Card (Pickup)
        TCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sender Details (Pickup)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colors.onSurface),
              ),
              const SizedBox(height: 12),
              TGridRow(
                gapX: 8,
                gapY: 24,
                children: [
                  TGridCol(
                    sm: 6,
                    child: TTextField(
                      textController: _senderNameController,
                      label: 'Sender Name',
                      isRequired: true,
                      decorationType: TInputDecorationType.outline,
                      labelPosition: TLabelPosition.aboveField,
                    ),
                  ),
                  TGridCol(
                    sm: 6,
                    child: TTextField(
                      textController: _senderPhoneController,
                      label: 'Sender Phone',
                      isRequired: true,
                      decorationType: TInputDecorationType.outline,
                      labelPosition: TLabelPosition.aboveField,
                    ),
                  ),
                  TGridCol(
                    child: TTextField(
                      textController: _pickupAddressController,
                      label: 'Pickup Address',
                      isRequired: true,
                      decorationType: TInputDecorationType.outline,
                      labelPosition: TLabelPosition.aboveField,
                    ),
                  ),
                  TGridCol(
                    child: TMapPinningWidget(
                      label: 'Pickup Location Map',
                      addressController: _pickupAddressController,
                      initialCoordinates: _pickupCoordinates,
                      onCoordinatesChanged: (val) {
                        setState(() {
                          _pickupCoordinates = val;
                        });
                      },
                      onAddressChanged: (val) {
                        setState(() {
                          _pickupAddressController.text = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Receiver Details Card (Drop-off)
        TCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Receiver Details (Drop-off)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colors.onSurface),
              ),
              const SizedBox(height: 12),
              TGridRow(
                gapX: 8,
                gapY: 24,
                children: [
                  TGridCol(
                    sm: 6,
                    child: TTextField(
                      textController: _receiverNameController,
                      label: 'Receiver Name',
                      isRequired: true,
                      decorationType: TInputDecorationType.outline,
                      labelPosition: TLabelPosition.aboveField,
                    ),
                  ),
                  TGridCol(
                    sm: 6,
                    child: TTextField(
                      textController: _receiverPhoneController,
                      label: 'Receiver Phone',
                      isRequired: true,
                      decorationType: TInputDecorationType.outline,
                      labelPosition: TLabelPosition.aboveField,
                    ),
                  ),
                  TGridCol(
                    child: TTextField(
                      textController: _dropoffAddressController,
                      label: 'Drop-off Address',
                      isRequired: true,
                      decorationType: TInputDecorationType.outline,
                      labelPosition: TLabelPosition.aboveField,
                    ),
                  ),
                  TGridCol(
                    child: TMapPinningWidget(
                      label: 'Drop-off Location Map',
                      addressController: _dropoffAddressController,
                      initialCoordinates: _dropoffCoordinates,
                      onCoordinatesChanged: (val) {
                        setState(() {
                          _dropoffCoordinates = val;
                        });
                      },
                      onAddressChanged: (val) {
                        setState(() {
                          _dropoffAddressController.text = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Continue Button
        TButton(
          size: TButtonSize.block,
          text: 'Continue',
          onTap: () {
            setState(() {
              _currentStep = 1;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPackageInfoStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Package type
        TButtonGroup(
          label: 'Package type',
          isRequired: true,
          info: 'Choose the option that best fits your item shape',
          separated: true,
          expanded: true,
          showTick: true,
          theme: const TButtonGroupTheme(type: TButtonGroupType.softOutline, shape: TButtonShape.tile, borderRadius: 12),
          initialIndex: ['Parcel', 'Box', 'Bag'].indexOf(_packageType),
          onIndexChanged: (index) {
            setState(() {
              _packageType = ['Parcel', 'Box', 'Bag'][index];
            });
          },
          items: [
            TButtonGroupItem(icon: Icons.inventory_2_outlined, text: 'Parcel'),
            TButtonGroupItem(icon: Icons.all_inbox_outlined, text: 'Box'),
            TButtonGroupItem(icon: Icons.local_mall_outlined, text: 'Bag'),
          ],
        ),
        const SizedBox(height: 20),

        // Delivery type
        TButtonGroup(
          label: 'Delivery type',
          isRequired: true,
          info: 'Select how quickly you need your delivery to arrive',
          separated: true,
          expanded: true,
          showTick: true,
          theme: const TButtonGroupTheme(type: TButtonGroupType.softOutline, shape: TButtonShape.tile, borderRadius: 12),
          initialIndex: ['Express', 'Same Day', 'Standard'].indexOf(_deliveryType),
          onIndexChanged: (index) {
            setState(() {
              _deliveryType = ['Express', 'Same Day', 'Standard'][index];
            });
          },
          items: [
            TButtonGroupItem(icon: Icons.bolt, text: 'Express'),
            TButtonGroupItem(icon: Icons.calendar_today_outlined, text: 'Same Day'),
            TButtonGroupItem(icon: Icons.access_time, text: 'Standard'),
          ],
        ),
        const SizedBox(height: 20),

        const SizedBox(height: 8),
        TGridRow(
          gapX: 8,
          gapY: 24,
          children: [
            TGridCol(
              child: TTextField(
                textController: _itemController,
                label: 'Item & pricing',
                placeholder: 'Item Type',
                decorationType: TInputDecorationType.outline,
                labelPosition: TLabelPosition.aboveField,
              ),
            ),

            TGridCol(
              sm: 6,
              child: TNumberField(
                theme: context.theme.numberFieldTheme.copyWith(
                  decorationType: TInputDecorationType.outline,
                  splitStepper: true,
                  labelPosition: TLabelPosition.aboveField,
                ),
                label: 'Weight (Kg)',
                value: weight,
              ),
            ),
            TGridCol(
              sm: 6,
              child: TNumberField(
                theme: context.theme.numberFieldTheme.copyWith(
                  decorationType: TInputDecorationType.outline,
                  splitStepper: true,
                  labelPosition: TLabelPosition.aboveField,
                ),
                label: 'Quantity',
                value: quantity,
              ),
            ),
            TGridCol(
              sm: 3,
              child: TSwitch(
                theme: context.theme.inputFieldTheme.copyWith(labelPosition: TLabelPosition.aboveField),
                label: "Fragile",
                value: _isFragile,
                onValueChanged: (v) => setState(() => _isFragile = v ?? false),
              ),
            ),
            TGridCol(
              sm: 9,
              child: TTextField(
                theme: context.theme.textFieldTheme.copyWith(
                  decorationType: TInputDecorationType.outline,
                  labelPosition: TLabelPosition.aboveField,
                ),
                label: 'Dimensions (optional)',
                placeholder: '1 Ft * 1 Ft * 1 Ft',
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Bottom Actions
        Row(
          children: [
            TButton(
              text: 'Back',
              type: TButtonType.outline,
              onTap: () {
                setState(() {
                  _currentStep = 0;
                });
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TButton(text: 'Continue', onTap: () => setState(() => _currentStep = 2)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPackageSummaryStep(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pickup & Drop Summary Card
        TCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('📍', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'Pickup & Drop-off Details',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colors.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TKeyValueSection(
                forceKeyValue: true,
                valueAfterKey: true,
                values: [
                  TKeyValue(
                    'Pickup From',
                    value: '${_senderNameController.text} (${_senderPhoneController.text})',
                    icon: const Icon(Icons.person_pin_circle_outlined, size: 16),
                  ),
                  TKeyValue('Pickup Address', value: _pickupAddressController.text, icon: const Icon(Icons.my_location, size: 16)),
                  TKeyValue(
                    'Deliver To',
                    value: '${_receiverNameController.text} (${_receiverPhoneController.text})',
                    icon: const Icon(Icons.pin_drop_outlined, size: 16),
                  ),
                  TKeyValue('Drop-off Address', value: _dropoffAddressController.text, icon: const Icon(Icons.place_outlined, size: 16)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Package Summary Card
        TCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('📦', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'Package Summary',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colors.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TKeyValueSection(
                forceKeyValue: true,
                valueAfterKey: true,
                values: [
                  TKeyValue('Type', value: '$_packageType ($weight kg)', icon: const Icon(Icons.inventory_2_outlined, size: 16)),
                  TKeyValue(
                    'Description',
                    value: _itemController.text.isEmpty ? "None" : _itemController.text,
                    icon: const Icon(Icons.description_outlined, size: 16),
                  ),
                  TKeyValue('Quantity', value: '$quantity', icon: const Icon(Icons.unarchive_outlined, size: 16)),
                  TKeyValue('Dimensions', value: '15 x 10 x 5 cm', icon: const Icon(Icons.straighten_outlined, size: 16)),
                  TKeyValue('Fragile', value: _isFragile ? "Yes" : "No", icon: const Icon(Icons.gavel_outlined, size: 16)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Price Breakdown Card
        TCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock_outline, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Price Breakdown',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colors.onSurface),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Icon(Icons.verified_user_outlined, size: 14),
                      SizedBox(width: 4),
                      Text('Secure', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TKeyValueSection(
                forceKeyValue: true,
                values: [
                  TKeyValue('Base Charge:', value: 'LKR 250.00'),
                  TKeyValue('Distance Fee (30.5 km):', value: 'LKR 2850.00'),
                  TKeyValue('Service Tax:', value: 'LKR 310.00'),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(height: 1, color: context.colors.outlineVariant),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Total Delivery Charge:', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
                  Text('LKR 3410.00', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Bottom Actions
        Row(
          children: [
            TButton(
              text: 'Back',
              type: TButtonType.outline,
              onTap: () {
                setState(() {
                  _currentStep = 1;
                });
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TButton(
                text: 'Confirm & Pay LKR 3410.00',
                icon: Icons.lock,
                onTap: () {
                  // Action
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
