import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class SubmitReportScreen extends StatefulWidget {
  final bool isGuest;
  const SubmitReportScreen({super.key, this.isGuest = false});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  String? _selectedType;
  bool _isAnonymous = false;
  bool _isLoading = false;
  bool _locating = false;
  double? _lat, _lng;
  final List<File> _mediaFiles = [];
  String? _successMessage;
  String? _errorMessage;

  final List<String> _incidentTypes = [
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
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
                'This app needs location access to submit a report. Please grant location permission in the app settings.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Open Settings'),
                onPressed: () {
                  Geolocator.openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _locationCtrl.text = '${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}';
      });
    } catch (e) {
      _showSnack('Could not get location: $e');
    } finally {
      setState(() => _locating = false);
    }
  }

  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final files = await picker.pickMultiImage();
    for (final f in files) {
      if (_mediaFiles.length < 5) _mediaFiles.add(File(f.path));
    }
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final auth = context.read<AuthProvider>();

    try {
      final result = await ApiService.submitReport(
        token: auth.token,
        email: widget.isGuest ? _emailCtrl.text.trim() : null,
        phoneNumber: widget.isGuest ? _phoneCtrl.text.trim() : null,
        incidentType: _selectedType!,
        description: _descCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        latitude: _lat,
        longitude: _lng,
        isAnonymous: _isAnonymous,
        mediaFiles: _mediaFiles.isNotEmpty ? _mediaFiles : null,
      );

      setState(() {
        _successMessage =
            'Report #${result['report_id']} submitted successfully!';
      });
      _formKey.currentState!.reset();
      _mediaFiles.clear();
      _lat = null;
      _lng = null;
      _selectedType = null;
      _isAnonymous = false;
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Submit Report',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_successMessage != null)
                _StatusBanner(message: _successMessage!, isSuccess: true),
              if (_errorMessage != null)
                _StatusBanner(message: _errorMessage!, isSuccess: false),
              if (widget.isGuest) ...[
                const _SectionTitle('Contact Info'),
                _buildField(
                  controller: _emailCtrl,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Email is required' : null,
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _phoneCtrl,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Phone is required' : null,
                ),
                const SizedBox(height: 22),
              ],
              const _SectionTitle('Incident Details'),
              DropdownButtonFormField<String>(
                value: _selectedType,
                hint: const Text('Select Incident Type'),
                items: _incidentTypes
                    .map((t) =>
                        DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedType = v),
                validator: (v) => v == null ? 'Select an incident type' : null,
                decoration: _inputDecoration('Incident Type', Icons.warning_amber_outlined),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Description is required' : null,
                decoration: _inputDecoration(
                    'Describe the incident in detail...', Icons.description_outlined),
              ),
              const SizedBox(height: 22),
              const _SectionTitle('Location'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationCtrl,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Location is required' : null,
                      decoration: _inputDecoration(
                          'Enter location or use GPS', Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _locating ? null : _getLocation,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF1E88E5).withOpacity(0.4)),
                      ),
                      child: _locating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location,
                              color: Color(0xFF1E88E5)),
                    ),
                  ),
                ],
              ),
              if (_lat != null) ...[
                const SizedBox(height: 8),
                Text(
                  'GPS: ${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}',
                  style: TextStyle(fontSize: 12, color: Colors.green[700]),
                ),
              ],
              const SizedBox(height: 22),
              const _SectionTitle('Media (Optional)'),
              InkWell(
                onTap: _pickMedia,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.grey.shade300, style: BorderStyle.solid),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 30, color: Colors.grey),
                      SizedBox(height: 6),
                      Text('Tap to add photos/videos',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              if (_mediaFiles.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _mediaFiles.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_mediaFiles[i],
                              width: 80, height: 80, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _mediaFiles.removeAt(i)),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SwitchListTile(
                value: _isAnonymous,
                onChanged: (v) => setState(() => _isAnonymous = v),
                title: const Text('Submit Anonymously',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text(
                    'Your identity will not be shared',
                    style: TextStyle(fontSize: 12)),
                activeColor: const Color(0xFF1E88E5),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(
                  _isLoading ? 'Submitting...' : 'Submit Report',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF1E88E5)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E88E5)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(label, icon),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: Color(0xFF0D1B2A)),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String message;
  final bool isSuccess;
  const _StatusBanner({required this.message, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(message,
                  style: TextStyle(
                      color: isSuccess ? Colors.green[800] : Colors.red[800]))),
        ],
      ),
    );
  }
}
