import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  bool _showMap = false;

  final TextEditingController _noteController = TextEditingController();

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
      });
    } catch (e) {
      setState(() => _loadError = e.toString());
    } finally {
      setState(() => _loadingDetail = false);
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
      setState(() => _updateError = e.toString());
    } finally {
      setState(() => _updatingStatus = false);
    }
  }

  Future<void> _addNote() async {
    if (_noteController.text.isEmpty) return;

    final token = context.read<AuthProvider>().token ?? '';

    try {
      await ApiService.addReportNote(
        token: token,
        reportId: _report.id,
        note: _noteController.text,
      );

      _noteController.clear();
      _fetchDetail();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note added')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
        onPressed: () async {
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
        label: const Text("Update Status"),
        icon: const Icon(Icons.edit),
      ),
      body: _loadingDetail
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  /// INCIDENT
                  _card("Incident", [
                    _row("Type", _report.incidentType),
                    _row("Status", _report.status),
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
                    _card("Notes", _report.notes!
                        .map((n) => Text(n['note']))
                        .toList()),

                  /// ADD NOTE
                  _card("Add Note", [
                    TextField(
                      controller: _noteController,
                      decoration:
                          const InputDecoration(hintText: "Write note..."),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        onPressed: _addNote,
                        child: const Text("Submit"))
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
}
