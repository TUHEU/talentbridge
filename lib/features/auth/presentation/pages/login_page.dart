// lib/features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/tb_text_field.dart';
import '../controllers/auth_controller.dart';
import '../../../home/presentation/pages/home_page.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'email_verification_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _form     = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _passwordVisible = false;
  bool _remember        = false;

  late AnimationController _animCtrl;
  late Animation<Offset>   _slideAnim;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final ok   = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()), (_) => false);
    } else if (auth.status == AuthStatus.emailUnverified) {
      Navigator.push(context, MaterialPageRoute(
          builder: (_) => EmailVerificationPage(email: _emailCtrl.text.trim())));
    } else {
      _showError(auth.error ?? 'Login failed');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final size    = MediaQuery.of(context).size;
    final bgColor = isDark ? AppColors.darkBg : AppColors.bg;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(children: [
        // ── Gradient header ─────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: size.height * 0.40,
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.brandVertical,
            ),
            child: Stack(children: [
              Positioned(top: -60, right: -50, child: _Circle(200, 0.08)),
              Positioned(top: 60,  left:  -30, child: _Circle(140, 0.06)),
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 76, height: 76,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(
                          color: Colors.black.withAlpha(40),
                          blurRadius: 24, offset: const Offset(0, 8))],
                      ),
                      child: const Icon(Icons.hub_rounded,
                          size: 40, color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    const Text('Talent Bridge',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800,
                            color: Colors.white, fontFamily: 'Inter')),
                    const SizedBox(height: 4),
                    Text('Connect Talent. Build Futures.',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withAlpha(200),
                            fontFamily: 'Inter')),
                  ],
                ),
              ),
            ]),
          ),
        ),

        // ── White card ───────────────────────────────────────
        Positioned(
          top: size.height * 0.34,
          left: 0, right: 0, bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBg : AppColors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 20, offset: const Offset(0, -4))],
            ),
          ),
        ),

        // ── Form content ─────────────────────────────────────
        SafeArea(
          child: Column(
            children: [
              SizedBox(height: size.height * 0.34),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                      child: Form(
                        key: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome back! 👋',
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    color: isDark ? AppColors.white : AppColors.grey900,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            Text('Sign in to your account',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.grey500)),
                            const SizedBox(height: 28),

                            TbTextField(
                              controller: _emailCtrl,
                              label:     'Email address',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                            ),
                            const SizedBox(height: 16),

                            TbTextField(
                              controller: _passwordCtrl,
                              label:     'Password',
                              prefixIcon: Icons.lock_outline_rounded,
                              obscure:   !_passwordVisible,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _login(),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Enter your password'
                                  : null,
                              suffix: IconButton(
                                icon: Icon(_passwordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                    size: 20),
                                onPressed: () => setState(
                                    () => _passwordVisible = !_passwordVisible),
                              ),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  SizedBox(
                                    width: 20, height: 20,
                                    child: Checkbox(
                                      value: _remember,
                                      onChanged: (v) =>
                                          setState(() => _remember = v!),
                                      activeColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Remember me',
                                      style: Theme.of(context)
                                          .textTheme.bodySmall
                                          ?.copyWith(color: AppColors.grey500)),
                                ]),
                                TextButton(
                                  onPressed: () => Navigator.push(context,
                                      MaterialPageRoute(
                                          builder: (_) => const ForgotPasswordPage())),
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                  child: const Text('Forgot password?',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            Consumer<AuthController>(
                              builder: (_, auth, __) => GradientButton(
                                text: 'Sign In',
                                isLoading: auth.isLoading,
                                onPressed: _login,
                                icon: Icons.login_rounded,
                              ),
                            ),
                            const SizedBox(height: 28),

                            Row(children: const [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text('or',
                                    style: TextStyle(
                                        color: AppColors.grey400, fontSize: 13)),
                              ),
                              Expanded(child: Divider()),
                            ]),
                            const SizedBox(height: 24),

                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (_) => const RegisterPage())),
                                child: RichText(
                                  text: TextSpan(
                                    text: "Don't have an account? ",
                                    style: TextStyle(
                                        color: isDark
                                            ? AppColors.grey400
                                            : AppColors.grey600,
                                        fontSize: 14,
                                        fontFamily: 'Inter'),
                                    children: const [
                                      TextSpan(
                                        text: 'Create account',
                                        style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final double opacity;
  const _Circle(this.size, this.opacity);
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withAlpha((opacity * 255).round()),
    ),
  );
}
