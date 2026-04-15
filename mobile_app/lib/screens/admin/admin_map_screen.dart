import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../auth/role_select_screen.dart';

class AdminMapScreen extends StatefulWidget {
  const AdminMapScreen({super.key});

  @override
  State<AdminMapScreen> createState() => _AdminMapScreenState();
}

class _AdminMapScreenState extends State<AdminMapScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<dynamic> _reports = [];
  List<dynamic> _staff = [];
  bool _loading = true;
  String? _error;

  // ── Active filters ─────────────────────────────────────────────────────────
  String? _filterStatus;
  String? _filterType;
  String? _filterDateFrom;
  String? _filterDateTo;

  final List<String> _statusOptions = [
    'Pending',
    'In Progress',
    'Arrived at location',
    'Work started',
    'Completed',
  ];

  final List<String> _typeOptions = [
    'Assault',
    'Theft',
    'Vandalism',
    'Fire',
    'Medical Emergency',
    'Road Accident',
    'Flooding',
    'Noise Complaint',
    'Drug Activity',
    'Suspicious Activity',
    'Infrastructure Damage',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final token = context.read<AuthProvider>().token ?? '';
    try {
      final data = await ApiService.getAdminMapView(
        token,
        status: _filterStatus,
        incidentType: _filterType,
        dateFrom: _filterDateFrom,
        dateTo: _filterDateTo,
      );
      setState(() {
        _reports = data['reports'] ?? [];
        _staff = data['staff'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _openFilterSheet() {
    String? tmpStatus = _filterStatus;
    String? tmpType = _filterType;
    String? tmpFrom = _filterDateFrom;
    String? tmpTo = _filterDateTo;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          builder: (_, sc) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: ListView(
              controller: sc,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Filter Reports',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('Status',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D1B2A))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: tmpStatus == null,
                      onSelected: (_) =>
                          setModal(() => tmpStatus = null),
                    ),
                    ..._statusOptions.map((s) => FilterChip(
                          label: Text(s),
                          selected: tmpStatus == s,
                          onSelected: (_) =>
                              setModal(() => tmpStatus = s),
                        )),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Incident Type',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D1B2A))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: tmpType == null,
                      onSelected: (_) =>
                          setModal(() => tmpType = null),
                    ),
                    ..._typeOptions.map((t) => FilterChip(
                          label: Text(t),
                          selected: tmpType == t,
                          onSelected: (_) =>
                              setModal(() => tmpType = t),
                        )),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Date Range',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D1B2A))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now()
                                .subtract(const Duration(days: 30)),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (d != null) {
                            setModal(() => tmpFrom =
                                DateFormat('yyyy-MM-dd').format(d));
                          }
                        },
                        icon: const Icon(Icons.calendar_today,
                            size: 14),
                        label: Text(
                          tmpFrom ?? 'From',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (d != null) {
                            setModal(() => tmpTo =
                                DateFormat('yyyy-MM-dd').format(d));
                          }
                        },
                        icon: const Icon(Icons.calendar_today,
                            size: 14),
                        label: Text(
                          tmpTo ?? 'To',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                if (tmpFrom != null || tmpTo != null)
                  TextButton(
                    onPressed: () =>
                        setModal(() { tmpFrom = null; tmpTo = null; }),
                    child: const Text('Clear dates'),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filterStatus = tmpStatus;
                      _filterType = tmpType;
                      _filterDateFrom = tmpFrom;
                      _filterDateTo = tmpTo;
                    });
                    Navigator.pop(ctx);
                    _loadData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Apply Filters',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                if (_filterStatus != null ||
                    _filterType != null ||
                    _filterDateFrom != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _filterStatus = null;
                        _filterType = null;
                        _filterDateFrom = null;
                        _filterDateTo = null;
                      });
                      Navigator.pop(ctx);
                      _loadData();
                    },
                    child: const Text('Clear All Filters',
                        style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int get _activeFilterCount {
    int c = 0;
    if (_filterStatus != null) c++;
    if (_filterType != null) c++;
    if (_filterDateFrom != null || _filterDateTo != null) c++;
    return c;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final adminName = auth.user?.name ?? 'Admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin Analytics',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            Text(adminName,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6), fontSize: 12)),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune, color: Colors.white70),
                onPressed: _openFilterSheet,
              ),
              if (_activeFilterCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$_activeFilterCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () async {
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
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6A1B9A),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.map_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text('Map View (${_reports.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.list_alt_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text('List View (${_reports.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                      color: Color(0xFF6A1B9A)),
                  SizedBox(height: 12),
                  Text('Loading analytics…',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : _error != null
              ? _ErrorView(error: _error!, onRetry: _loadData)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _MapTab(reports: _reports, staff: _staff),
                    _ListTab(reports: _reports, staff: _staff),
                  ],
                ),
    );
  }
}

// ─── Map Tab ─────────────────────────────────────────────────────────────────

class _MapTab extends StatelessWidget {
  final List<dynamic> reports;
  final List<dynamic> staff;
  const _MapTab({required this.reports, required this.staff});

  Color _markerColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
      case 'work started':
        return Colors.blue;
      case 'arrived at location':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportMarkers = <Marker>[];
    final staffMarkers = <Marker>[];

    for (final r in reports) {
      final lat = double.tryParse(r['latitude']?.toString() ?? '');
      final lng = double.tryParse(r['longitude']?.toString() ?? '');
      if (lat != null && lng != null) {
        final color = _markerColor(r['status']?.toString() ?? '');
        reportMarkers.add(Marker(
          point: LatLng(lat, lng),
          width: 36,
          height: 36,
          child: Tooltip(
            message:
                '#${r['id']} · ${r['incident_type']} · ${r['status']}',
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 6,
                  )
                ],
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ));
      }
      // Resolution marker
      final rLat = double.tryParse(
          r['resolved_at_latitude']?.toString() ?? '');
      final rLng = double.tryParse(
          r['resolved_at_longitude']?.toString() ?? '');
      if (rLat != null && rLng != null) {
        reportMarkers.add(Marker(
          point: LatLng(rLat, rLng),
          width: 30,
          height: 30,
          child: Tooltip(
            message: '#${r['id']} · Resolved here',
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 14),
            ),
          ),
        ));
      }
    }

    for (final s in staff) {
      final lat = double.tryParse(s['latitude']?.toString() ?? '');
      final lng = double.tryParse(s['longitude']?.toString() ?? '');
      if (lat != null && lng != null) {
        staffMarkers.add(Marker(
          point: LatLng(lat, lng),
          width: 36,
          height: 36,
          child: Tooltip(
            message: s['name']?.toString() ?? 'Staff',
            child: Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.5),
                    blurRadius: 6,
                  )
                ],
              ),
              child: const Icon(Icons.person_pin_circle,
                  color: Colors.white, size: 18),
            ),
          ),
        ));
      }
    }

    final allMarkers = [...reportMarkers, ...staffMarkers];
    final hasCoords = allMarkers.isNotEmpty;

    LatLng center = const LatLng(0, 0);
    double zoom = 2;
    if (hasCoords) {
      center = allMarkers.first.point;
      zoom = 10;
    }

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(initialCenter: center, initialZoom: zoom),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.blockiqx.app',
            ),
            MarkerLayer(markers: allMarkers),
          ],
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1), blurRadius: 8)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Legend',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                _LegendRow(color: Colors.orange, label: 'Pending'),
                _LegendRow(color: Colors.blue, label: 'In Progress'),
                _LegendRow(color: Colors.purple, label: 'Arrived'),
                _LegendRow(color: Colors.green, label: 'Completed'),
                _LegendRow(
                    color: Colors.deepPurple, label: 'Staff Location'),
              ],
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B2A).withOpacity(0.85),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${reportMarkers.length} reports · ${staffMarkers.length} staff',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

// ─── List Tab ─────────────────────────────────────────────────────────────────

class _ListTab extends StatelessWidget {
  final List<dynamic> reports;
  final List<dynamic> staff;
  const _ListTab({required this.reports, required this.staff});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (staff.isNotEmpty) ...[
          _SectionHeader(
              icon: Icons.person_pin_circle_outlined,
              title: 'Staff Locations (${staff.length})',
              color: Colors.deepPurple),
          ...staff.map((s) => _StaffTile(s: s)),
          const SizedBox(height: 16),
        ],
        _SectionHeader(
            icon: Icons.report_problem_outlined,
            title: 'Reports (${reports.length})',
            color: const Color(0xFF6A1B9A)),
        if (reports.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No reports match the current filters.',
                  style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ...reports.map((r) => _ReportListTile(r: r)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  const _SectionHeader(
      {required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: color)),
        ],
      ),
    );
  }
}

class _StaffTile extends StatelessWidget {
  final dynamic s;
  const _StaffTile({required this.s});

  @override
  Widget build(BuildContext context) {
    final hasLocation = s['latitude'] != null && s['longitude'] != null;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: Colors.deepPurple),
        ),
        title: Text(s['name']?.toString() ?? 'Staff',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(s['email']?.toString() ?? ''),
        trailing: hasLocation
            ? const Icon(Icons.location_on, color: Colors.green, size: 18)
            : const Icon(Icons.location_off, color: Colors.grey, size: 18),
      ),
    );
  }
}

class _ReportListTile extends StatelessWidget {
  final dynamic r;
  const _ReportListTile({required this.r});

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
      case 'work started':
        return Colors.blue;
      case 'arrived at location':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = r['status']?.toString() ?? 'Unknown';
    final color = _statusColor(status);
    final hasCoords =
        r['latitude'] != null && r['longitude'] != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.report_problem, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('#${r['id']}',
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 11)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(status,
                            style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r['incident_type']?.toString() ?? 'Unknown',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    r['location']?.toString() ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 12),
                  ),
                  if (hasCoords) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 3),
                        Text(
                          '${double.parse(r['latitude'].toString()).toStringAsFixed(4)}, '
                          '${double.parse(r['longitude'].toString()).toStringAsFixed(4)}',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[400]),
                        ),
                        if (r['resolved_at_latitude'] != null) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.check_circle,
                              size: 12, color: Colors.green[400]),
                          const SizedBox(width: 3),
                          Text('Resolved',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green[400])),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

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
            const Icon(Icons.error_outline, size: 56, color: Colors.red),
            const SizedBox(height: 12),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
