// lib/features/auth/presentation/pages/email_verification_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/tb_text_field.dart';
import '../controllers/auth_controller.dart';
import '../../../home/presentation/pages/home_page.dart';

// ─────────────────────────────────────────────────────────────
// EMAIL VERIFICATION PAGE
// ─────────────────────────────────────────────────────────────
class EmailVerificationPage extends StatefulWidget {
  final String email;
  const EmailVerificationPage({super.key, required this.email});
  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes  = List.generate(6, (_) => FocusNode());
  int  _timer     = 60;
  bool _canResend = false;
  Timer? _countdown;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNodes[0].requestFocus());
  }

  void _startTimer() {
    _timer = 60; _canResend = false;
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timer == 0) { t.cancel(); setState(() => _canResend = true); }
      else             { setState(() => _timer--); }
    });
  }

  @override
  void dispose() {
    _countdown?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes)  f.dispose();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otp.length != 6) {
      _snack('Enter the complete 6-digit code', AppColors.warning);
      return;
    }
    final auth = context.read<AuthController>();
    final ok   = await auth.verifyEmail(widget.email, _otp);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()), (_) => false);
    } else {
      _snack(auth.error ?? 'Invalid code', AppColors.error);
    }
  }

  Future<void> _resend() async {
    await context.read<AuthController>().resendOtp(widget.email);
    if (!mounted) return;
    _startTimer();
    _snack('New code sent to your email', AppColors.success);
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        foregroundColor: isDark ? AppColors.white : AppColors.grey900,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.mark_email_unread_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(height: 24),
          Text('Check your email',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.white : AppColors.grey900)),
          const SizedBox(height: 10),
          Text.rich(TextSpan(
            text: "We sent a 6-digit code to\n",
            style: const TextStyle(
                color: AppColors.grey500, fontSize: 15,
                height: 1.6, fontFamily: 'Inter'),
            children: [
              TextSpan(text: widget.email,
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w600))
            ],
          )),
          const SizedBox(height: 36),
          LayoutBuilder(builder: (ctx, box) {
            final w = (box.maxWidth - 5 * 8) / 6;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) => _OtpCell(
                controller: _controllers[i],
                focusNode:  _focusNodes[i],
                width: w, isDark: isDark,
                onChange: (v) {
                  if (v.isNotEmpty && i < 5) _focusNodes[i + 1].requestFocus();
                  if (v.isEmpty   && i > 0) _focusNodes[i - 1].requestFocus();
                  setState(() {});
                },
              )),
            );
          }),
          const SizedBox(height: 36),
          Consumer<AuthController>(
            builder: (_, auth, __) => GradientButton(
              text: 'Verify Email',
              isLoading: auth.isLoading,
              onPressed: _otp.length == 6 ? _verify : null,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: _canResend
                ? TextButton.icon(
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Resend code'),
                    onPressed: _resend)
                : Text('Resend in ${_timer}s',
                    style: const TextStyle(
                        color: AppColors.grey400,
                        fontSize: 14, fontFamily: 'Inter')),
          ),
        ]),
      ),
    );
  }
}

// ─── OTP cell ─────────────────────────────────────────────────
class _OtpCell extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final double width;
  final bool isDark;
  final ValueChanged<String> onChange;

  const _OtpCell({
    required this.controller, required this.focusNode,
    required this.width,      required this.isDark,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final filled  = controller.text.isNotEmpty;
    final focused = focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: width, height: width * 1.18,
      decoration: BoxDecoration(
        color: isDark
            ? (filled ? AppColors.primary.withAlpha(40) : AppColors.darkCard)
            : (filled ? AppColors.primaryLight : AppColors.grey50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focused ? AppColors.primary
              : (filled ? AppColors.primary.withAlpha(100) : AppColors.grey200),
          width: focused ? 2 : 1.5,
        ),
      ),
      child: TextFormField(
        controller: controller,
        focusNode:  focusNode,
        onChanged:  onChange,
        textAlign:  TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Inter',
          color: isDark ? AppColors.white : AppColors.grey900,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────
// FORGOT PASSWORD PAGE
// ─────────────────────────────────────────────────────────────
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _form      = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final ok   = await auth.forgotPassword(_emailCtrl.text.trim());
    if (!mounted) return;
    if (ok) {
      Navigator.push(context, MaterialPageRoute(
          builder: (_) => ResetPasswordPage(email: _emailCtrl.text.trim())));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Failed'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        foregroundColor: isDark ? AppColors.white : AppColors.grey900,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Form(
          key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.lock_reset_rounded,
                  color: Colors.white, size: 32),
            ),
            const SizedBox(height: 24),
            Text('Forgot Password?',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.white : AppColors.grey900)),
            const SizedBox(height: 10),
            const Text(
              "Enter your email and we'll send a reset code.",
              style: TextStyle(
                  color: AppColors.grey500, fontSize: 15,
                  height: 1.6, fontFamily: 'Inter'),
            ),
            const SizedBox(height: 32),
            TbTextField(
              controller:   _emailCtrl,
              label:        'Email address',
              prefixIcon:   Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator:    Validators.email,
            ),
            const SizedBox(height: 28),
            Consumer<AuthController>(
              builder: (_, auth, __) => GradientButton(
                text:      'Send Reset Code',
                isLoading: auth.isLoading,
                onPressed: _submit,
                icon:      Icons.send_rounded,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────
// RESET PASSWORD PAGE
// ─────────────────────────────────────────────────────────────
class ResetPasswordPage extends StatefulWidget {
  final String email;
  const ResetPasswordPage({super.key, required this.email});
  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _form        = GlobalKey<FormState>();
  final _otpCtrl     = TextEditingController();
  final _pwCtrl      = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showPw = false;

  @override
  void dispose() {
    _otpCtrl.dispose();
    _pwCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final ok   = await auth.resetPassword(
        widget.email, _otpCtrl.text.trim(), _pwCtrl.text);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password reset! Please sign in.'),
        backgroundColor: AppColors.success,
      ));
      Navigator.of(context).popUntil((r) => r.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Reset failed'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? AppColors.white : AppColors.grey900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        child: Form(
          key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Code sent to ${widget.email}',
                      style: const TextStyle(
                          color: AppColors.primary, fontSize: 13,
                          fontWeight: FontWeight.w500, fontFamily: 'Inter')),
                ),
              ]),
            ),
            const SizedBox(height: 28),
            TbTextField(
              controller:   _otpCtrl,
              label:        '6-digit reset code',
              prefixIcon:   Icons.pin_outlined,
              keyboardType: TextInputType.number,
              validator:    Validators.otp,
            ),
            const SizedBox(height: 16),
            TbTextField(
              controller: _pwCtrl,
              label:      'New password',
              prefixIcon: Icons.lock_outline_rounded,
              obscure:    !_showPw,
              validator:  Validators.password,
              suffix: IconButton(
                icon: Icon(
                  _showPw
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                ),
                onPressed: () => setState(() => _showPw = !_showPw),
              ),
            ),
            const SizedBox(height: 16),
            TbTextField(
              controller:      _confirmCtrl,
              label:           'Confirm new password',
              prefixIcon:      Icons.lock_outline_rounded,
              obscure:         true,
              textInputAction: TextInputAction.done,
              onSubmitted:     (_) => _submit(),
              validator:       (v) => Validators.confirmPassword(v, _pwCtrl.text),
            ),
            const SizedBox(height: 32),
            Consumer<AuthController>(
              builder: (_, auth, __) => GradientButton(
                text:      'Reset Password',
                isLoading: auth.isLoading,
                onPressed: _submit,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
