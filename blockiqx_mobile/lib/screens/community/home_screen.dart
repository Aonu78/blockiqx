import 'dart:math' as math;
import 'package:blockiqx_mobile/screens/community/my_reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../auth/role_select_screen.dart';
import '../notifications_screen.dart';
import 'submit_report_screen.dart';
import 'nearby_resources_screen.dart';

class CommunityHomeScreen extends StatefulWidget {
  const CommunityHomeScreen({super.key});

  @override
  State<CommunityHomeScreen> createState() => _CommunityHomeScreenState();
}

class _CommunityHomeScreenState extends State<CommunityHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _entranceCtrl;
  late List<Animation<Offset>> _slideAnims;
  late List<Animation<double>> _fadeAnims;

  @override
  void initState() {
    super.initState();
    _bgCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat(reverse: true);

    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));

    // 4 sections: header, section label, action cards, info card
    _slideAnims = List.generate(4, (i) {
      final start = i * 0.15;
      final end = (start + 0.5).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.4),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });

    _fadeAnims = List.generate(4, (i) {
      final start = i * 0.15;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return CurvedAnimation(
          parent: _entranceCtrl, curve: Interval(start, end));
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
    final auth = context.watch<AuthProvider>();
    final name = auth.user?.name ?? 'Community Member';
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          // ── Animated header ───────────────────────────────────────
          _animated(
            0,
            AnimatedBuilder(
              animation: _bgCtrl,
              builder: (_, __) => _HomeHeader(
                name: name,
                greeting: greeting,
                bgAnim: _bgCtrl.value,
                unreadCount: context.watch<NotificationProvider>().unreadCount,
                onOpenNotifications: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
                onLogout: () async {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RoleSelectScreen()),
                      (_) => false,
                    );
                  }
                },
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Section label ────────────────────────────────
                  _animated(
                    1,
                    const _SectionLabel(text: 'Quick Actions'),
                  ),
                  const SizedBox(height: 12),

                  // ── Action cards ─────────────────────────────────
                  _animated(
                    2,
                    LayoutBuilder(builder: (context, constraints) {
                      final width = (constraints.maxWidth - 14) / 2;
                      return Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          SizedBox(
                            width: width,
                            child: _ActionCard(
                              icon: Icons.add_alert_outlined,
                              label: 'Submit Report',
                              subtitle: 'Report an incident',
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF1565C0),
                                  Color(0xFF1E88E5)
                                ],
                              ),
                              onTap: () => Navigator.push(
                                context,
                                _slideRoute(const SubmitReportScreen()),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: _ActionCard(
                              icon: Icons.place_outlined,
                              label: 'Nearby Help',
                              subtitle: 'Find resources near you',
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF1B5E20),
                                  Color(0xFF43A047)
                                ],
                              ),
                              onTap: () => Navigator.push(
                                context,
                                _slideRoute(const NearbyResourcesScreen()),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: _ActionCard(
                              icon: Icons.history_outlined,
                              label: 'My Reports',
                              subtitle: 'View your submissions',
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF6A1B9A),
                                  Color(0xFF8E24AA)
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  _slideRoute(const MyReportsScreen()),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // ── Info card ────────────────────────────────────
                  _animated(
                    3,
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SectionLabel(text: 'About BLOCKIQx'),
                        SizedBox(height: 12),
                        Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18)),
                          ),
                          child: Column(
                            children: [
                              _InfoTile(
                                icon: Icons.report_problem_outlined,
                                iconColor: Color(0xFF1E88E5),
                                text:
                                    'Submit anonymous or identified incident reports',
                                isFirst: true,
                              ),
                              _InfoTile(
                                icon: Icons.location_on_outlined,
                                iconColor: Color(0xFF43A047),
                                text:
                                    'Include your location for faster response',
                              ),
                              _InfoTile(
                                icon: Icons.attach_file_outlined,
                                iconColor: Color(0xFF7B1FA2),
                                text: 'Attach photos and videos as evidence',
                              ),
                              _InfoTile(
                                icon: Icons.notifications_outlined,
                                iconColor: Color(0xFFE65100),
                                text: 'Track your report status in real time',
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PageRouteBuilder _slideRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      );
}

// ── Animated header ────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final String name;
  final String greeting;
  final double bgAnim;
  final VoidCallback onLogout;
  final VoidCallback onOpenNotifications;
  final int unreadCount;

  const _HomeHeader({
    required this.name,
    required this.greeting,
    required this.bgAnim,
    required this.onLogout,
    required this.onOpenNotifications,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(
                const Color(0xFF0D47A1), const Color(0xFF1565C0), bgAnim)!,
            Color.lerp(
                const Color(0xFF1565C0), const Color(0xFF1E88E5), bgAnim)!,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative arcs
          Positioned.fill(
            child: CustomPaint(painter: _HeaderArcsPainter(bgAnim)),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App bar row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(255, 255, 255, 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.shield_outlined,
                                color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'BLOCKIQx',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: onOpenNotifications,
                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(255, 255, 255, 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.notifications,
                                      color: Colors.white70, size: 18),
                                ),
                                if (unreadCount > 0)
                                  Positioned(
                                    right: 2,
                                    top: 2,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: onLogout,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(255, 255, 255, 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.logout,
                                  color: Colors.white70, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Greeting
                  Text(
                    greeting,
                    style: const TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.6),
                        fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Color(0xFF69F0AE), size: 7),
                        SizedBox(width: 6),
                        Text(
                          'Reporting platform is active',
                          style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 0.7),
                              fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderArcsPainter extends CustomPainter {
  final double t;
  const _HeaderArcsPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromRGBO(255, 255, 255, 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final r = 60.0 + i * 45 + math.sin(t * math.pi + i * 0.8) * 8;
      canvas.drawCircle(Offset(size.width + 10, -10), r, paint);
    }
  }

  @override
  bool shouldRepaint(_HeaderArcsPainter old) => old.t != t;
}

// ── Action card ────────────────────────────────────────────────────────────────

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.last.withAlpha(89),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.15),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 14),
              Text(widget.label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const SizedBox(height: 3),
              Text(widget.subtitle,
                  style: const TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 0.65),
                      fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Info tile ──────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final bool isFirst;
  final bool isLast;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.text,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(text,
                    style: const TextStyle(
                        fontSize: 13, height: 1.4, color: Color(0xFF2D3748))),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
              height: 1,
              indent: 18,
              endIndent: 18,
              color: Colors.grey.withAlpha(30)),
      ],
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A237E),
        letterSpacing: 0.3,
      ),
    );
  }
}
