import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _addingNote = false;
  String? _updateError;
  String? _updateSuccess;

  bool _showMap = false;

  final TextEditingController _noteController = TextEditingController();

  final List<String> _statusOptions = [
    'Pending',
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
      });
    } catch (e) {
      setState(() => _loadError = _friendlyError(e));
    } finally {
      if (mounted) {
        setState(() => _loadingDetail = false);
      }
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() {
      _updatingStatus = true;
      _updateError = null;
      _updateSuccess = null;
    });

    final token = context.read<AuthProvider>().token ?? '';

    try {
      final result = await ApiService.updateReportStatus(
        token: token,
        reportId: _report.id,
        status: newStatus,
      );

      final reportJson =
          result.containsKey('report') ? result['report'] : result;

      setState(() {
        _report = Report.fromJson(reportJson);
        _updateSuccess = 'Updated to "$newStatus"';
      });
    } catch (e) {
      setState(() => _updateError = _friendlyError(e));
    } finally {
      if (mounted) {
        setState(() => _updatingStatus = false);
      }
    }
  }

  Future<void> _addNote() async {
    if (_noteController.text.trim().isEmpty || _addingNote) return;

    setState(() {
      _addingNote = true;
      _updateError = null;
      _updateSuccess = null;
    });

    final token = context.read<AuthProvider>().token ?? '';

    try {
      await ApiService.addReportNote(
        token: token,
        reportId: _report.id,
        note: _noteController.text.trim(),
      );

      _noteController.clear();
      await _fetchDetail();

      if (!mounted) return;
      setState(() => _updateSuccess = 'Note added successfully');
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Note added')),
        );
    } catch (e) {
      final message = _friendlyError(e);
      if (!mounted) return;
      setState(() => _updateError = message);
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(message)),
        );
    } finally {
      if (mounted) {
        setState(() => _addingNote = false);
      }
    }
  }

  String _friendlyError(Object error) {
    final raw = error.toString();
    if (raw.toLowerCase().contains('404')) {
      return 'Server route was not found. Please verify the mobile API deployment.';
    }
    if (raw.toLowerCase().contains('session expired')) {
      return 'Your session expired. Please sign in again.';
    }
    return raw;
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch dialer for $phoneNumber')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        title: Text('Report #${_report.id}',
            style: const TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: StatusBadge(status: _report.status),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _updatingStatus
            ? null
            : () async {
          final selected = await showModalBottomSheet<String>(
            context: context,
            builder: (_) => Column(
              mainAxisSize: MainAxisSize.min,
              children: _statusOptions
                  .map((s) => ListTile(
                        title: Text(s),
                        onTap: () => Navigator.pop(context, s),
                      ))
                  .toList(),
            ),
          );

          if (selected != null) _updateStatus(selected);
        },
        label: Text(_updatingStatus ? "Updating..." : "Update Status"),
        icon: _updatingStatus
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.edit),
      ),
      body: _loadingDetail
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_updateError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.redAccent),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_updateError!)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (_updateSuccess != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_updateSuccess!)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (_loadError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: Colors.orange),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_loadError!)),
                            ],
                          ),
                        ),
                      ),
                    ),

                  /// INCIDENT
                  _card("Incident", [
                    _row("Type", _report.incidentType),
                    _row("Status", _report.status),
                    if (_report.phoneNumber != null && _report.phoneNumber!.isNotEmpty)
                      _phoneRow("Phone", _report.phoneNumber!),
                  ]),

                  /// DESCRIPTION
                  _card("Description", [
                    Text(_report.description),
                  ]),

                  /// LOCATION
                  _card("Location", [
                    _row("Address", _report.location),

                    const SizedBox(height: 10),

                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _showMap = !_showMap);
                      },
                      icon: const Icon(Icons.directions),
                      label: Text(
                          _showMap ? "Hide Directions" : "Get Directions"),
                    ),
                  ]),

                  /// MAP
                  if (_showMap && _report.latitude != null)
                    Container(
                      height: 220,
                      margin: const EdgeInsets.only(top: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                                _report.latitude!, _report.longitude!),
                            zoom: 14,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId("incident"),
                              position: LatLng(
                                  _report.latitude!, _report.longitude!),
                            )
                          },
                        ),
                      ),
                    ),

                  /// NOTES
                  if (_report.notes != null)
                    _card(
                      "Notes",
                      _report.notes!.isEmpty
                          ? const [
                              Text(
                                'No notes yet.',
                                style: TextStyle(color: Colors.grey),
                              )
                            ]
                          : _report.notes!.map((n) {
                              final author =
                                  (n['user']?['name'] ?? 'System').toString();
                              final createdAt =
                                  (n['created_at'] ?? n['timestamp'] ?? '')
                                      .toString();
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (n['note'] ?? '').toString(),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      createdAt.isEmpty
                                          ? author
                                          : '$author • $createdAt',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                    ),

                  /// ADD NOTE
                  _card("Add Note", [
                    TextField(
                      controller: _noteController,
                      onChanged: (_) => setState(() {}),
                      decoration:
                          const InputDecoration(hintText: "Write note..."),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        onPressed:
                            _addingNote || _noteController.text.trim().isEmpty
                                ? null
                                : _addNote,
                        child: Text(_addingNote ? "Saving..." : "Submit"))
                  ]),
                ],
              ),
            ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),
            ...children
          ]),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text("$k: ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }

  Widget _phoneRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text("$k: ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: GestureDetector(
              onTap: () => _launchPhone(v),
              child: Text(
                v,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
