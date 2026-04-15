import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/report.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/status_badge.dart';

class ReportDetailScreen extends StatefulWidget {
  final Report report;
  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late Report _report;
  bool _loadingDetail = false;
  String? _loadError;
  bool _updatingStatus = false;
  String? _updateError;
  String? _updateSuccess;

  final List<String> _statusOptions = [
    'In Progress',
    'Arrived at location',
    'Work started',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
    _report = widget.report;
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchDetail());
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _loadingDetail = true;
      _loadError = null;
    });
    final token = context.read<AuthProvider>().token ?? '';
    try {
      final data =
          await ApiService.getStaffReportDetail(token, _report.id);
      setState(() {
        _report = Report.fromJson(data);
        _loadingDetail = false;
      });
    } catch (e) {
      setState(() {
        _loadError = e.toString();
        _loadingDetail = false;
      });
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() {
      _updatingStatus = true;
      _updateError = null;
      _updateSuccess = null;
    });

    final token = context.read<AuthProvider>().token ?? '';
    double? lat, lng;

    if (newStatus == 'Completed' || newStatus == 'Arrived at location') {
      try {
        final perm = await Geolocator.checkPermission();
        if (perm != LocationPermission.denied &&
            perm != LocationPermission.deniedForever) {
          final pos = await Geolocator.getCurrentPosition();
          lat = pos.latitude;
          lng = pos.longitude;
        }
      } catch (_) {}
    }

    try {
      final result = await ApiService.updateReportStatus(
        token: token,
        reportId: _report.id,
        status: newStatus,
        latitude: lat,
        longitude: lng,
      );
      final reportJson =
          result.containsKey('report') ? result['report'] : result;
      setState(() {
        _report = Report.fromJson(reportJson);
        _updateSuccess = 'Status updated to "$newStatus"';
      });
    } catch (e) {
      setState(() => _updateError = e.toString());
    } finally {
      setState(() => _updatingStatus = false);
    }
  }

  Future<void> _showStatusPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Text(
                'Update Report Status',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const Divider(),
            ..._statusOptions.map(
              (s) => ListTile(
                title: Text(s),
                leading: StatusBadge(status: s),
                onTap: () => Navigator.pop(context, s),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null) await _updateStatus(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Report #${_report.id}',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: StatusBadge(status: _report.status),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _updatingStatus ? null : _showStatusPicker,
        backgroundColor: const Color(0xFF43A047),
        icon: _updatingStatus
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.edit_note_outlined, color: Colors.white),
        label: Text(
          _updatingStatus ? 'Updating...' : 'Update Status',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: _loadingDetail
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Loading report details…',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : _loadError != null && _report.description.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(_loadError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchDetail,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_loadError != null)
              _Banner(message: 'Showing cached data. ${_loadError!}', isSuccess: false),
            if (_updateSuccess != null)
              _Banner(message: _updateSuccess!, isSuccess: true),
            if (_updateError != null)
              _Banner(message: _updateError!, isSuccess: false),
            _DetailCard(
              title: 'Incident Information',
              children: [
                _DetailRow(
                    label: 'Type', value: _report.incidentType),
                _DetailRow(
                    label: 'Category',
                    value: _report.category ?? 'N/A'),
                _DetailRow(
                    label: 'Concern',
                    value: _report.concernLevel,
                    valueColor: _concernColor(_report.concernLevel)),
                _DetailRow(
                    label: 'Anonymous',
                    value: _report.isAnonymous ? 'Yes' : 'No'),
                _DetailRow(
                    label: 'Submitted',
                    value: _formatDate(_report.createdAt)),
              ],
            ),
            const SizedBox(height: 14),
            _DetailCard(
              title: 'Description',
              children: [
                Text(
                  _report.description,
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _DetailCard(
              title: 'Location',
              children: [
                _DetailRow(label: 'Address', value: _report.location),
                if (_report.latitude != null) ...[
                  _DetailRow(
                      label: 'Latitude',
                      value: _report.latitude!.toStringAsFixed(6)),
                  _DetailRow(
                      label: 'Longitude',
                      value: _report.longitude!.toStringAsFixed(6)),
                ],
                if (_report.resolvedAtLatitude != null) ...[
                  const Divider(),
                  const Text('Resolution Coordinates',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 12)),
                  _DetailRow(
                      label: 'Lat',
                      value: _report.resolvedAtLatitude!
                          .toStringAsFixed(6)),
                  _DetailRow(
                      label: 'Lng',
                      value: _report.resolvedAtLongitude!
                          .toStringAsFixed(6)),
                ],
              ],
            ),
            if (_report.email != null || _report.phoneNumber != null) ...[
              const SizedBox(height: 14),
              _DetailCard(
                title: 'Reporter Contact',
                children: [
                  if (_report.email != null)
                    _DetailRow(label: 'Email', value: _report.email!),
                  if (_report.phoneNumber != null)
                    _DetailRow(
                        label: 'Phone', value: _report.phoneNumber!),
                ],
              ),
            ],
            if (_report.notes != null && _report.notes!.isNotEmpty) ...[
              const SizedBox(height: 14),
              _DetailCard(
                title: 'Notes (${_report.notes!.length})',
                children: _report.notes!
                    .map((n) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n['note']?.toString() ?? '',
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                n['timestamp']?.toString() ?? '',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _concernColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'N/A';
    try {
      return DateFormat('MMM d, y · h:mm a').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _DetailCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Color(0xFFF0F0F0))),
            ),
            child: Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF0D1B2A)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _DetailRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final String message;
  final bool isSuccess;
  const _Banner({required this.message, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isSuccess ? Colors.green.shade300 : Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.error_outline,
            color: isSuccess ? Colors.green : Colors.red,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
              child: Text(
            message,
            style: TextStyle(
                color: isSuccess ? Colors.green[800] : Colors.red[800],
                fontSize: 13),
          )),
        ],
      ),
    );
  }
}
