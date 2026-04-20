import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/report.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/report_card.dart';
import '../auth/role_select_screen.dart';
import '../notifications_screen.dart';
import 'report_detail_screen.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen>
    with TickerProviderStateMixin {
  List<Report> _reports = [];
  bool _loading = true;
  String? _error;
  String _filter = 'All';

  late AnimationController _bgCtrl;
  late AnimationController _statsCtrl;
  late AnimationController _listCtrl;

  final _filters = ['All', 'Pending', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
    _statsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _listCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _loadReports();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _statsCtrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    _statsCtrl.reset();
    _listCtrl.reset();

    final token = context.read<AuthProvider>().token ?? '';
    try {
      final data = await ApiService.getStaffReports(token);
      setState(() {
        _reports = data.map((j) => Report.fromJson(j)).toList();
        _loading = false;
      });
      _statsCtrl.forward();
      await Future.delayed(const Duration(milliseconds: 200));
      _listCtrl.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Report> get _filteredReports {
    if (_filter == 'All') return _reports;
    return _reports
        .where((r) => r.status.toLowerCase() == _filter.toLowerCase())
        .toList();
  }

  Map<String, int> get _stats => {
        'total': _reports.length,
        'pending': _reports
            .where((r) => r.status.toLowerCase() == 'pending')
            .length,
        'in_progress': _reports
            .where((r) => r.status.toLowerCase() == 'in progress')
            .length,
        'completed': _reports
            .where((r) => r.status.toLowerCase() == 'completed')
            .length,
      };

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final staffName = auth.staff?.name ?? 'Staff';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          // ── Animated header ──────────────────────────────────────
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => _DashboardHeader(
              name: staffName,
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
              onRefresh: _loadReports,
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

          Expanded(
            child: _loading
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                            color: Color(0xFF43A047)),
                        SizedBox(height: 12),
                        Text('Loading reports…',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : _error != null
                    ? _ErrorView(error: _error!, onRetry: _loadReports)
                    : RefreshIndicator(
                        color: const Color(0xFF43A047),
                        onRefresh: _loadReports,
                        child: CustomScrollView(
                          slivers: [
                            // Stats row
                            SliverToBoxAdapter(
                              child: _AnimatedStatsRow(
                                stats: _stats,
                                ctrl: _statsCtrl,
                              ),
                            ),
                            // Filter tabs
                            SliverToBoxAdapter(
                              child: _FilterTabs(
                                selected: _filter,
                                filters: _filters,
                                onSelected: (f) =>
                                    setState(() => _filter = f),
                              ),
                            ),
                            // Report list
                            _filteredReports.isEmpty
                                ? const SliverFillRemaining(
                                    child: _EmptyState())
                                : SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (_, i) => _AnimatedListItem(
                                        index: i,
                                        ctrl: _listCtrl,
                                        child: ReportCard(
                                          report: _filteredReports[i],
                                          index: i,
                                          onTap: () async {
                                            await Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (_, __, ___) =>
                                                    ReportDetailScreen(
                                                  report:
                                                      _filteredReports[i],
                                                ),
                                                transitionsBuilder:
                                                    (_, anim, __, child) =>
                                                        SlideTransition(
                                                  position: Tween<Offset>(
                                                    begin: const Offset(1, 0),
                                                    end: Offset.zero,
                                                  ).animate(
                                                    CurvedAnimation(
                                                        parent: anim,
                                                        curve: Curves
                                                            .easeOutCubic),
                                                  ),
                                                  child: child,
                                                ),
                                                transitionDuration:
                                                    const Duration(
                                                        milliseconds: 350),
                                              ),
                                            );
                                            _loadReports();
                                          },
                                        ),
                                      ),
                                      childCount: _filteredReports.length,
                                    ),
                                  ),
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 24)),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Dashboard header ───────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  final String name;
  final double bgAnim;
  final VoidCallback onRefresh;
  final VoidCallback onLogout;
  final VoidCallback onOpenNotifications;
  final int unreadCount;

  const _DashboardHeader({
    required this.name,
    required this.bgAnim,
    required this.onRefresh,
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
            Color.lerp(const Color(0xFF1B5E20), const Color(0xFF2E7D32),
                bgAnim)!,
            Color.lerp(const Color(0xFF2E7D32), const Color(0xFF43A047),
                bgAnim)!,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _HeaderArcsPainter(bgAnim)),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            child: const Icon(Icons.badge_outlined,
                                color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Staff Dashboard',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: onRefresh,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(255, 255, 255, 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.refresh,
                                  color: Colors.white70, size: 18),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: onOpenNotifications,
                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
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
                          const SizedBox(width: 8),
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
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome back,',
                    style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.6), fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
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
      ..color = const Color.fromRGBO(255, 255, 255, 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final r = 50.0 + i * 40 + math.sin(t * math.pi + i) * 6;
      canvas.drawCircle(Offset(size.width + 10, -10), r, paint);
    }
  }

  @override
  bool shouldRepaint(_HeaderArcsPainter old) => old.t != t;
}

// ── Animated stats row ─────────────────────────────────────────────────────────

class _AnimatedStatsRow extends StatelessWidget {
  final Map<String, int> stats;
  final AnimationController ctrl;
  const _AnimatedStatsRow(
      {required this.stats, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          _AnimatedStatCard(
              count: stats['total']!,
              label: 'Total',
              icon: Icons.assignment_outlined,
              color: const Color(0xFF1565C0),
              ctrl: ctrl,
              delay: 0.0),
          const SizedBox(width: 10),
          _AnimatedStatCard(
              count: stats['pending']!,
              label: 'Pending',
              icon: Icons.hourglass_empty,
              color: const Color(0xFFF57C00),
              ctrl: ctrl,
              delay: 0.1),
          const SizedBox(width: 10),
          _AnimatedStatCard(
              count: stats['in_progress']!,
              label: 'Active',
              icon: Icons.directions_run,
              color: const Color(0xFF1E88E5),
              ctrl: ctrl,
              delay: 0.2),
          const SizedBox(width: 10),
          _AnimatedStatCard(
              count: stats['completed']!,
              label: 'Done',
              icon: Icons.check_circle_outline,
              color: const Color(0xFF2E7D32),
              ctrl: ctrl,
              delay: 0.3),
        ],
      ),
    );
  }
}

class _AnimatedStatCard extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color color;
  final AnimationController ctrl;
  final double delay;

  const _AnimatedStatCard({
    required this.count,
    required this.label,
    required this.icon,
    required this.color,
    required this.ctrl,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final end = (delay + 0.5).clamp(0.0, 1.0);
    final entrance = CurvedAnimation(
      parent: ctrl,
      curve: Interval(delay, end, curve: Curves.easeOutBack),
    );
    final countAnim = Tween<double>(begin: 0, end: count.toDouble()).animate(
      CurvedAnimation(
          parent: ctrl,
          curve: Interval(delay, end, curve: Curves.easeOut)),
    );

    return Expanded(
      child: AnimatedBuilder(
        animation: ctrl,
        builder: (_, __) => Transform.scale(
          scale: entrance.value,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(38),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(height: 5),
                Text(
                  countAnim.value.toInt().toString(),
                  style: TextStyle(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  label,
                  style: TextStyle(
                      color: color.withAlpha(178), fontSize: 9),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Filter tabs ────────────────────────────────────────────────────────────────

class _FilterTabs extends StatelessWidget {
  final String selected;
  final List<String> filters;
  final ValueChanged<String> onSelected;

  const _FilterTabs({
    required this.selected,
    required this.filters,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters
              .map((f) => _FilterTab(
                    label: f,
                    isSelected: selected == f,
                    onTap: () => onSelected(f),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _FilterTab extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_FilterTab> createState() => _FilterTabState();
}

class _FilterTabState extends State<_FilterTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const _active = Color(0xFF43A047);

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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 8),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected ? _active : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? _active.withAlpha(76)
                    : const Color.fromRGBO(0, 0, 0, 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isSelected ? Colors.white : Colors.grey[600],
              fontWeight: widget.isSelected
                  ? FontWeight.w700
                  : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Animated list item ─────────────────────────────────────────────────────────

class _AnimatedListItem extends StatelessWidget {
  final int index;
  final AnimationController ctrl;
  final Widget child;

  const _AnimatedListItem({
    required this.index,
    required this.ctrl,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final delay = (index * 0.06).clamp(0.0, 0.8);
    final end = (delay + 0.4).clamp(0.0, 1.0);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: ctrl,
      curve: Interval(delay, end, curve: Curves.easeOutCubic),
    ));
    final fade = CurvedAnimation(
      parent: ctrl,
      curve: Interval(delay, end),
    );
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => SlideTransition(
        position: slide,
        child: FadeTransition(opacity: fade, child: child),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(67, 160, 71, 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.assignment_outlined,
                size: 48, color: Color(0xFF43A047)),
          ),
          const SizedBox(height: 16),
          const Text('No reports found',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF1A237E))),
          const SizedBox(height: 6),
          Text('Try a different filter',
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Error view ─────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 0, 0, 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline,
                  size: 44, color: Colors.redAccent),
            ),
            const SizedBox(height: 16),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF43A047),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
