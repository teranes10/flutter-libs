import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/widgets/modal/modal_config.dart';

class TModal extends StatelessWidget {
  final Widget child;
  final TModalConfig config;
  final VoidCallback onClose;

  const TModal(
    this.child, {
    super.key,
    required this.config,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final modalWidth = config.width > screenWidth ? screenWidth - 25 : config.width;

    return GestureDetector(
      onTap: () {
        if (!config.persistent) {
          onClose();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Align(
              alignment: const FractionalOffset(0.5, 0.2),
              child: GestureDetector(
                onTap: () {}, // Prevent tap propagation
                child: Container(
                  width: modalWidth,
                  constraints: const BoxConstraints(
                    minWidth: 450,
                    minHeight: 250,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.grey.shade600.withAlpha(25),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (config.title != null || config.headerWidget != null) _buildHeader(config, onClose),
                      Flexible(child: child),
                      if (config.footerWidget != null) _buildFooter(config),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TModalConfig config, VoidCallback onClose) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: config.headerWidget ??
                Text(
                  config.title ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: AppColors.grey.shade600,
                  ),
                ),
          ),
          if (config.showCloseButton == true) CloseIconButton(onClose: onClose),
        ],
      ),
    );
  }

  Widget _buildFooter(TModalConfig config) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 13.6, 20, 13.6),
      child: config.footerWidget!,
    );
  }
}

class CloseIconButton extends StatefulWidget {
  final VoidCallback onClose;

  const CloseIconButton({super.key, required this.onClose});

  @override
  State<CloseIconButton> createState() => CloseIconButtonState();
}

class CloseIconButtonState extends State<CloseIconButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onClose,
        child: Icon(
          Icons.cancel_outlined,
          color: _isHovering ? AppColors.danger.shade400 : AppColors.grey.shade300,
          size: 20,
        ),
      ),
    );
  }
}
