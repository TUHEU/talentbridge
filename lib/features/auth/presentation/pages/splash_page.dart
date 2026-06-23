// lib/features/auth/presentation/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/auth_controller.dart';
import 'login_page.dart';
import '../../../home/presentation/pages/home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late Animation<double>   _logoScale, _logoFade;
  late Animation<double>   _textFade;
  late Animation<Offset>   _textSlide;
  late Animation<double>   _dotFade;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _logoFade  = CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOut))
        .drive(Tween(begin: 0.0, end: 1.0));
    _logoScale = CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.5, end: 1.0));
    _textFade  = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _textSlide = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic)
        .drive(Tween(begin: const Offset(0, 0.25), end: Offset.zero));
    _dotFade   = CurvedAnimation(parent: _textCtrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut))
        .drive(Tween(begin: 0.0, end: 1.0));

    _logoCtrl.forward().then((_) => _textCtrl.forward());
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    final auth = context.read<AuthController>();
    if (auth.isAuthenticated) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()));
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()));
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.brandVertical),
        child: Stack(children: [
          // decorative circles
          Positioned(top: -100, right: -80, child: _circle(260, 0.06)),
          Positioned(bottom: -80, left: -60, child: _circle(300, 0.05)),
          Positioned(top: 200, left: -40, child: _circle(160, 0.04)),

          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Container(
                      width: 110, height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(46),
                            blurRadius: 40, offset: const Offset(0, 16))
                        ],
                      ),
                      child: const Icon(Icons.hub_rounded,
                          size: 58, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // text
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(children: [
                      const Text('Talent Bridge',
                          style: TextStyle(
                              fontSize: 34, fontWeight: FontWeight.w800,
                              color: Colors.white, letterSpacing: -0.6,
                              fontFamily: 'Inter')),
                      const SizedBox(height: 8),
                      Text('Connect Talent. Build Futures.',
                          style: TextStyle(
                              fontSize: 15, color: Colors.white.withAlpha(215),
                              fontFamily: 'Inter')),
                    ]),
                  ),
                ),
                const SizedBox(height: 80),
                FadeTransition(
                  opacity: _dotFade,
                  child: const _PulseDots(),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _circle(double size, double opacity) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withAlpha((opacity * 255).round()),
    ),
  );
}

class _PulseDots extends StatefulWidget {
  const _PulseDots();
  @override
  State<_PulseDots> createState() => _PulseDotsState();
}

class _PulseDotsState extends State<_PulseDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final delay = i * 0.25;
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final val = (((_ctrl.value - delay) * 3).clamp(0.0, 1.0));
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 8 + val * 4,
              height: 8 + val * 4,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((100 + (val * 155)).round()),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
