import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import 'auth/role_select_screen.dart';
import 'community/home_screen.dart';
import 'staff/staff_dashboard_screen.dart';
import 'admin/admin_map_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final AuthProvider authProvider;
  const OnboardingScreen({super.key, required this.authProvider});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.report_problem_outlined,
      iconColor: Color(0xFF1E88E5),
      gradientColors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
      title: 'Report Incidents\nInstantly',
      subtitle:
          'Submit incident reports from anywhere in seconds. Attach photos, share your GPS location, and stay anonymous if needed.',
      highlights: [
        _Highlight(icon: Icons.camera_alt_outlined, text: 'Photo & video evidence'),
        _Highlight(icon: Icons.location_on_outlined, text: 'Automatic GPS tagging'),
        _Highlight(icon: Icons.visibility_off_outlined, text: 'Anonymous submissions'),
      ],
    ),
    _OnboardingPage(
      icon: Icons.track_changes_outlined,
      iconColor: Color(0xFF43A047),
      gradientColors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
      title: 'Track Progress\nin Real Time',
      subtitle:
          'Follow your report from submission to resolution. Get status updates as staff respond and see resources available near you.',
      highlights: [
        _Highlight(icon: Icons.update_outlined, text: 'Live status updates'),
        _Highlight(icon: Icons.people_outline, text: 'Staff response tracking'),
        _Highlight(icon: Icons.place_outlined, text: 'Nearby resources map'),
      ],
    ),
    _OnboardingPage(
      icon: Icons.shield_outlined,
      iconColor: Color(0xFF6A1B9A),
      gradientColors: [Color(0xFF4A148C), Color(0xFF6A1B9A)],
      title: 'Safer Communities,\nTogether',
      subtitle:
          'Community members, outreach staff, and administrators all working on one platform to make every neighbourhood safer.',
      highlights: [
        _Highlight(icon: Icons.people_alt_outlined, text: 'Community reporting'),
        _Highlight(icon: Icons.badge_outlined, text: 'Staff field management'),
        _Highlight(icon: Icons.admin_panel_settings_outlined, text: 'Admin analytics & oversight'),
      ],
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _skip() => _finish();

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    _pushHomeScreen();
  }

  void _pushHomeScreen() {
    final auth = widget.authProvider;
    Widget home;
    if (!auth.isAuthenticated) {
      home = const RoleSelectScreen();
    } else {
      switch (auth.mode) {
        case AuthMode.staff:
          home = const StaffDashboardScreen();
        case AuthMode.admin:
          home = const AdminMapScreen();
        default:
          home = const CommunityHomeScreen();
      }
    }
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => home,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (_) => false,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              page.gradientColors[0],
              page.gradientColors[1],
              const Color(0xFF0D1B2A),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _DotIndicator(
                        count: _pages.length, current: _currentPage),
                    if (!isLast)
                      TextButton(
                        onPressed: _skip,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14),
                        ),
                      )
                    else
                      const SizedBox(width: 56),
                  ],
                ),
              ),

              // ── Page content ────────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (_, i) => _PageContent(page: _pages[i]),
                ),
              ),

              // ── Bottom controls ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: page.gradientColors[1],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLast ? 'Get Started' : 'Next',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isLast
                                  ? Icons.rocket_launch_outlined
                                  : Icons.arrow_forward_rounded,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Page content widget ──────────────────────────────────────────────────────

class _PageContent extends StatelessWidget {
  final _OnboardingPage page;
  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Icon illustration
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.15), width: 1.5),
            ),
            child: Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: page.iconColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(page.icon, size: 46, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),
          // Subtitle
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          // Highlights
          ...page.highlights.map((h) => _HighlightRow(highlight: h)),
        ],
      ),
    );
  }
}

class _HighlightRow extends StatelessWidget {
  final _Highlight highlight;
  const _HighlightRow({required this.highlight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(highlight.icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            highlight.text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dot indicator ─────────────────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  final int count;
  final int current;
  const _DotIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: active ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.only(right: 5),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ─── Data classes ─────────────────────────────────────────────────────────────

class _OnboardingPage {
  final IconData icon;
  final Color iconColor;
  final List<Color> gradientColors;
  final String title;
  final String subtitle;
  final List<_Highlight> highlights;

  const _OnboardingPage({
    required this.icon,
    required this.iconColor,
    required this.gradientColors,
    required this.title,
    required this.subtitle,
    required this.highlights,
  });
}

class _Highlight {
  final IconData icon;
  final String text;
  const _Highlight({required this.icon, required this.text});
}
