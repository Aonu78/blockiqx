import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blockiqx_mobile/models/report.dart';
import 'package:blockiqx_mobile/providers/auth_provider.dart';
import 'package:blockiqx_mobile/services/api_service.dart';

class EditReportScreen extends StatefulWidget {
  final Report report;

  const EditReportScreen({Key? key, required this.report}) : super(key: key);

  @override
  _EditReportScreenState createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _incidentTypeController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _incidentTypeController = TextEditingController(text: widget.report.incidentType);
    _descriptionController = TextEditingController(text: widget.report.description);
    _locationController = TextEditingController(text: widget.report.location);
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await ApiService.updateUserReport(
          authProvider.token!,
          widget.report.id,
          incidentType: _incidentTypeController.text,
          description: _descriptionController.text,
          location: _locationController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report updated successfully')),
        );
        Navigator.pop(context, true); // Pop with a result to indicate success
      } on ApiException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _incidentTypeController,
                decoration: const InputDecoration(labelText: 'Incident Type'),
                validator: (value) => value!.isEmpty ? 'Please enter an incident type' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) => value!.isEmpty ? 'Please enter a location' : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Update Report'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
