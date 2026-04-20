import 'package:blockiqx/screens/community/edit_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blockiqx/models/report.dart';
import 'package:blockiqx/providers/auth_provider.dart';
import 'package:blockiqx/services/api_service.dart';
import 'package:blockiqx/widgets/report_card.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({Key? key}) : super(key: key);

  @override
  _MyReportsScreenState createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  late Future<List<Report>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  void _fetchReports() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _reportsFuture = ApiService.getUserReports(authProvider.token!).then(
        (data) => data.map((item) => Report.fromJson(item)).toList(),
      );
    });
  }

  void _navigateToEditScreen(Report report) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReportScreen(report: report),
      ),
    );

    if (result == true) {
      _fetchReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
      ),
      body: FutureBuilder<List<Report>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No reports found.'));
          }

          final reports = snapshot.data!;
          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return ReportCard(
                report: report,
                onTap: () {
                  if (report.status == 'Pending') {
                    _navigateToEditScreen(report);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('This report can no longer be edited.'),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
