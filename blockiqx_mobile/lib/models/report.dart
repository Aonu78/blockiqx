class Report {
  final int id;
  final String? email;
  final String? phoneNumber;
  final String incidentType;
  final String description;
  final String location;
  final double? latitude;
  final double? longitude;
  final String? category;
  final String concernLevel;
  final List<String>? mediaPaths;
  final String status;
  final int? userId;
  final int? organizationId;
  final int? assignedTo;
  final double? resolvedAtLatitude;
  final double? resolvedAtLongitude;
  final bool isAnonymous;
  final List<Map<String, dynamic>>? notes;
  final String createdAt;
  final String updatedAt;

  Report({
    required this.id,
    this.email,
    this.phoneNumber,
    required this.incidentType,
    required this.description,
    required this.location,
    this.latitude,
    this.longitude,
    this.category,
    required this.concernLevel,
    this.mediaPaths,
    required this.status,
    this.userId,
    this.organizationId,
    this.assignedTo,
    this.resolvedAtLatitude,
    this.resolvedAtLongitude,
    required this.isAnonymous,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    List<String>? mediaPaths;
    if (json['media_paths'] != null) {
      if (json['media_paths'] is List) {
        mediaPaths = List<String>.from(json['media_paths']);
      }
    }

    List<Map<String, dynamic>>? notes;
    if (json['notes'] != null && json['notes'] is List) {
      notes = List<Map<String, dynamic>>.from(json['notes']);
    }

    return Report(
      id: json['id'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      incidentType: json['incident_type'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      category: json['category'],
      concernLevel: json['concern_level'] ?? 'Low',
      mediaPaths: mediaPaths,
      status: json['status'] ?? 'Pending',
      userId: json['user_id'],
      organizationId: json['organization_id'],
      assignedTo: json['assigned_to'],
      resolvedAtLatitude: json['resolved_at_latitude'] != null
          ? double.tryParse(json['resolved_at_latitude'].toString())
          : null,
      resolvedAtLongitude: json['resolved_at_longitude'] != null
          ? double.tryParse(json['resolved_at_longitude'].toString())
          : null,
      isAnonymous: json['is_anonymous'] == true || json['is_anonymous'] == 1,
      notes: notes,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  String get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'orange';
      case 'in progress':
        return 'blue';
      case 'completed':
        return 'green';
      case 'arrived at location':
        return 'purple';
      case 'work started':
        return 'teal';
      default:
        return 'grey';
    }
  }
}
