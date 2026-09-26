import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class PinFieldPage extends StatefulWidget {
  const PinFieldPage({super.key});

  @override
  State<PinFieldPage> createState() => _PinFieldPageState();
}

class _PinFieldPageState extends State<PinFieldPage> {
  String _currentOtp = '';
  String _completedOtp = 'None';
  bool _obscurePin = true;
  String? _simulatedError;
  bool _isLoading = false;

  void _verifyPin(String pin) async {
    setState(() {
      _isLoading = true;
      _simulatedError = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      _isLoading = false;
      if (pin != '123456') {
        _simulatedError = 'Incorrect verification code. Please try again.';
      } else {
        _simulatedError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'PIN & OTP Field',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            'Segmented verification input for 2FA, OTP codes, and security PINs with auto-advance, backspace handling, and clipboard paste support.',
            style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          // Feedback Banner
          TBanner.info(
            variant: TVariant.tonal,
            title: 'PIN Input State',
            message: 'Current buffer: "${_currentOtp.isEmpty ? 'Empty' : _currentOtp}" | Last completed: "$_completedOtp"',
          ),
          const SizedBox(height: 24),

          // Section 1: 6-Digit 2FA Verification Field
          TCard(
            title: '6-Digit 2FA Verification (Try pasting "123456")',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Enter the 6-digit code sent to your registered authenticator app or email.',
                  style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TPinField(
                  length: 6,
                  boxWidth: 50,
                  boxHeight: 56,
                  spacing: 12,
                  autoFocus: false,
                  errorText: _simulatedError,
                  onChanged: (val) => setState(() => _currentOtp = val),
                  onCompleted: (val) {
                    setState(() => _completedOtp = val);
                    _verifyPin(val);
                  },
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 10),
                      Text('Verifying code...', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Didn\'t receive code? ', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                    TButton(
                      text: 'Resend SMS',
                      type: TButtonType.softText,
                      size: TButtonSize.xs,
                      onTap: () {
                        setState(() {
                          _simulatedError = null;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 2: 4-Digit Obscured PIN Field
          TCard(
            title: '4-Digit Security PIN (Masked / Password Mode)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Four-digit masked lock PIN for POS terminal auth or sensitive transactions.',
                  style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TPinField(
                  length: 4,
                  boxWidth: 56,
                  boxHeight: 60,
                  spacing: 16,
                  obscureText: _obscurePin,
                  obscureCharacter: '●',
                  onChanged: (val) {},
                  onCompleted: (val) {},
                ),
                const SizedBox(height: 16),
                TButton(
                  text: _obscurePin ? 'Reveal PIN' : 'Hide PIN',
                  icon: _obscurePin ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  type: TButtonType.tonal,
                  size: TButtonSize.xs,
                  onTap: () => setState(() => _obscurePin = !_obscurePin),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
