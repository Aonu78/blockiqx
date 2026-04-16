import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import '../providers/auth_provider.dart';
import 'auth/role_select_screen.dart';
import 'community/home_screen.dart';
import 'staff/staff_dashboard_screen.dart';
import 'admin/admin_map_screen.dart';

class SplashScreen extends StatefulWidget {
  final AuthProvider authProvider;
  const SplashScreen({super.key, required this.authProvider});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _orbCtrl;
  late AnimationController _shimmerCtrl;
  late AnimationController _textCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _orbCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat(reverse: true);
    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn);

    _taglineFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn);
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    _logoCtrl.forward().then((_) => _textCtrl.forward());
    Future.delayed(const Duration(milliseconds: 3000), _navigate);
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _orbCtrl.dispose();
    _shimmerCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_complete') ?? false;
    if (!mounted) return;

    Widget next;
    if (!onboardingDone) {
      next = OnboardingScreen(authProvider: widget.authProvider);
    } else {
      final auth = widget.authProvider;
      if (!auth.isAuthenticated) {
        next = const RoleSelectScreen();
      } else {
        switch (auth.mode) {
          case AuthMode.staff:
            next = const StaffDashboardScreen();
          case AuthMode.admin:
            next = const AdminMapScreen();
          default:
            next = const CommunityHomeScreen();
        }
      }
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060D17),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Animated background orbs ────────────────────────────────
          AnimatedBuilder(
            animation: _orbCtrl,
            builder: (_, __) {
              final t = _orbCtrl.value;
              return CustomPaint(
                painter: _OrbPainter(t),
              );
            },
          ),

          // ── Shimmer ring around logo ────────────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _shimmerCtrl,
              builder: (_, __) => CustomPaint(
                size: const Size(220, 220),
                painter: _ShimmerRingPainter(_shimmerCtrl.value),
              ),
            ),
          ),

          // ── Logo ────────────────────────────────────────────────────
          Center(
            child: FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF42A5F5), Color(0xFF0D47A1)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E88E5).withOpacity(0.6),
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.shield_outlined,
                          size: 52, color: Colors.white),
                    ),
                    const SizedBox(height: 26),
                    SlideTransition(
                      position: _taglineSlide,
                      child: FadeTransition(
                        opacity: _taglineFade,
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  const LinearGradient(
                                colors: [
                                  Color(0xFF42A5F5),
                                  Color(0xFFFFFFFF),
                                  Color(0xFF42A5F5),
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'BLOCKIQx',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Incident Reporting & Management',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 12,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom pulse bar ────────────────────────────────────────
          Positioned(
            bottom: 52,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _taglineFade,
              child: const _ProgressBar(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Orb background painter ────────────────────────────────────────────────────

class _OrbPainter extends CustomPainter {
  final double t;
  _OrbPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    _drawOrb(canvas, cx - 80 + math.sin(t * math.pi) * 30,
        cy - 120 + math.cos(t * math.pi) * 40, 160,
        const Color(0xFF1565C0).withOpacity(0.18));

    _drawOrb(canvas, cx + 90 + math.cos(t * math.pi) * 20,
        cy + 100 + math.sin(t * math.pi) * 30, 140,
        const Color(0xFF0D47A1).withOpacity(0.14));

    _drawOrb(canvas, cx - 60 + math.sin(t * math.pi * 1.5) * 25,
        cy + 180, 100, const Color(0xFF42A5F5).withOpacity(0.08));
  }

  void _drawOrb(
      Canvas canvas, double x, double y, double r, Color color) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: r));
    canvas.drawCircle(Offset(x, y), r, paint);
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.t != t;
}

// ── Shimmer ring painter ───────────────────────────────────────────────────────

class _ShimmerRingPainter extends CustomPainter {
  final double t;
  _ShimmerRingPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    for (var ring = 0; ring < 3; ring++) {
      final radius = 70.0 + ring * 22.0;
      final opacity = (0.12 - ring * 0.03) *
          (0.5 + 0.5 * math.sin((t - ring * 0.15) * 2 * math.pi));
      final paint = Paint()
        ..color = const Color(0xFF42A5F5).withOpacity(opacity.clamp(0.0, 1.0))
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ShimmerRingPainter old) => old.t != t;
}

// ── Animated progress bar ──────────────────────────────────────────────────────

class _ProgressBar extends StatefulWidget {
  const _ProgressBar();

  @override
  State<_ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<_ProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400));
    _anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _anim.value,
                backgroundColor: Colors.white.withOpacity(0.06),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF42A5F5)),
                minHeight: 3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Loading…',
          style: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 11,
              letterSpacing: 1),
        ),
      ],
    );
  }
}
