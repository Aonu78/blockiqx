import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'login_screen.dart';
import 'staff_login_screen.dart';
import '../admin/admin_login_screen.dart';
import '../community/submit_report_screen.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _entranceCtrl;
  late List<Animation<Offset>> _slideAnims;
  late List<Animation<double>> _fadeAnims;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);

    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    // 5 items: logo block, 3 role cards, guest button
    _slideAnims = List.generate(5, (i) {
      final start = i * 0.12;
      final end = (start + 0.5).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.6),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });

    _fadeAnims = List.generate(5, (i) {
      final start = i * 0.12;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, end),
      );
    });

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  Widget _animated(int i, Widget child) => SlideTransition(
        position: _slideAnims[i],
        child: FadeTransition(opacity: _fadeAnims[i], child: child),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgCtrl,
        builder: (_, __) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(const Color(0xFF060D17), const Color(0xFF0A1628),
                    _bgCtrl.value)!,
                Color.lerp(const Color(0xFF0A1628), const Color(0xFF0D1B2A),
                    _bgCtrl.value)!,
                Color.lerp(const Color(0xFF0D1B2A), const Color(0xFF060D17),
                    _bgCtrl.value)!,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background decorative arcs
              Positioned.fill(
                child: CustomPaint(painter: _ArcsPainter(_bgCtrl.value)),
              ),
              // Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 26, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),

                      // Logo block
                      _animated(
                        0,
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF42A5F5),
                                      Color(0xFF0D47A1)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromRGBO(30, 136, 229, 0.5),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.shield_outlined,
                                    size: 40, color: Colors.white),
                              ),
                              const SizedBox(height: 14),
                              ShaderMask(
                                shaderCallback: (b) =>
                                    const LinearGradient(colors: [
                                  Color(0xFF42A5F5),
                                  Colors.white,
                                ]).createShader(b),
                                child: const Text(
                                  'BLOCKIQx',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Choose how you\'re accessing the platform',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: const Color.fromRGBO(255, 255, 255, 0.4),
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Role cards
                      _animated(
                        1,
                        _RoleCard(
                          icon: Icons.people_alt_outlined,
                          title: 'Community Member',
                          subtitle: 'Submit and track incident reports',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                          ),
                          glowColor: const Color(0xFF1E88E5),
                          onTap: () => Navigator.push(
                            context,
                            _slideRoute(const LoginScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _animated(
                        2,
                        _RoleCard(
                          icon: Icons.badge_outlined,
                          title: 'Staff / Outreach',
                          subtitle: 'Manage assigned reports in the field',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                          ),
                          glowColor: const Color(0xFF43A047),
                          onTap: () => Navigator.push(
                            context,
                            _slideRoute(const StaffLoginScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _animated(
                        3,
                        _RoleCard(
                          icon: Icons.admin_panel_settings_outlined,
                          title: 'Admin',
                          subtitle:
                              'Analytics map, reports overview & staff tracking',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
                          ),
                          glowColor: const Color(0xFF7B1FA2),
                          onTap: () => Navigator.push(
                            context,
                            _slideRoute(const AdminLoginScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Guest button
                      _animated(
                        4,
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            _slideRoute(
                                const SubmitReportScreen(isGuest: true)),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color.fromRGBO(255, 255, 255, 0.12)),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_outline,
                                    color: const Color.fromRGBO(255, 255, 255, 0.5),
                                    size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Continue as Guest',
                                  style: TextStyle(
                                      color: const Color.fromRGBO(255, 255, 255, 0.5),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PageRouteBuilder _slideRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 380),
      );
}

// ── Role card with press scale ─────────────────────────────────────────────────

class _RoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final Color glowColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.glowColor,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scaleAnim =
        Tween<double>(begin: 1.0, end: 0.96).animate(_pressCtrl);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradient.colors
                  .map((c) => c.withAlpha(38))
                  .toList(),
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: widget.glowColor.withAlpha(76), width: 1),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withAlpha(30),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: widget.gradient,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: widget.glowColor.withAlpha(102),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child:
                    Icon(widget.icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    const SizedBox(height: 3),
                    Text(widget.subtitle,
                        style: TextStyle(
                            color: const Color.fromRGBO(255, 255, 255, 0.45),
                            fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.glowColor.withAlpha(38),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.arrow_forward_ios,
                    color: widget.glowColor, size: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Background arcs painter ────────────────────────────────────────────────────

class _ArcsPainter extends CustomPainter {
  final double t;
  _ArcsPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromRGBO(30, 136, 229, 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final r = 120.0 + i * 80 + math.sin(t * math.pi + i) * 10;
      canvas.drawCircle(
          Offset(size.width * 0.85, size.height * 0.1), r, paint);
    }
    for (var i = 0; i < 3; i++) {
      final r = 100.0 + i * 70 + math.cos(t * math.pi + i) * 8;
      canvas.drawCircle(
          Offset(size.width * 0.1, size.height * 0.9), r, paint);
    }
  }

  @override
  bool shouldRepaint(_ArcsPainter old) => old.t != t;
}
