import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/report.dart';

class ReportCard extends StatefulWidget {
  final Report report;
  final VoidCallback? onTap;
  final int index;

  const ReportCard({
    super.key,
    required this.report,
    this.onTap,
    this.index = 0,
  });

  @override
  State<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(_pressCtrl);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF57C00);
      case 'in progress':
      case 'work started':
        return const Color(0xFF1565C0);
      case 'arrived at location':
        return const Color(0xFF6A1B9A);
      case 'completed':
        return const Color(0xFF2E7D32);
      default:
        return Colors.grey;
    }
  }

  Color _concernColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return const Color(0xFF2E7D32);
    }
  }

  IconData _incidentIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('fire')) return Icons.local_fire_department;
    if (t.contains('medical') || t.contains('health'))
      return Icons.medical_services;
    if (t.contains('crime') || t.contains('theft') || t.contains('assault'))
      return Icons.security;
    if (t.contains('flood') || t.contains('water')) return Icons.water;
    if (t.contains('accident') || t.contains('road')) return Icons.car_crash;
    if (t.contains('noise')) return Icons.volume_up;
    if (t.contains('drug')) return Icons.medication;
    if (t.contains('suspicious')) return Icons.visibility;
    if (t.contains('vandalism')) return Icons.format_paint;
    return Icons.report_problem;
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      return DateFormat('MMM d, y').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final statusColor = _statusColor(report.status);
    final concernColor = _concernColor(report.concernLevel);
    final icon = _incidentIcon(report.incidentType);

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: statusColor.withAlpha(20),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              const BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                // Coloured top accent bar
                Container(height: 3, color: statusColor),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon container
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  statusColor.withAlpha(38),
                                  statusColor.withAlpha(20),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: statusColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          // Title + date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  report.incidentType,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Color(0xFF1A237E),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Text(
                                      '#${report.id}',
                                      style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 11),
                                    ),
                                    Text(
                                      ' · ',
                                      style: TextStyle(
                                          color: Colors.grey[300],
                                          fontSize: 11),
                                    ),
                                    Text(
                                      _formatDate(report.createdAt),
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: statusColor.withAlpha(51)),
                            ),
                            child: Text(
                              report.status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        report.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 13, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              report.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]),
                            ),
                          ),
                          // Concern badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: concernColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.circle,
                                    color: concernColor, size: 6),
                                const SizedBox(width: 4),
                                Text(
                                  report.concernLevel,
                                  style: TextStyle(
                                    color: concernColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
