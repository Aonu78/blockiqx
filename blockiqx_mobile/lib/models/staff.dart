class Staff {
  final int id;
  final String name;
  final String email;
  final int? organizationId;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String createdAt;
  final String updatedAt;

  Staff({
    required this.id,
    required this.name,
    required this.email,
    this.organizationId,
    this.location,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      organizationId: json['organization_id'],
      location: json['location'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
