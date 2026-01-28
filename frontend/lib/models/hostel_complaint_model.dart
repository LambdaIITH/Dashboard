class HostelComplaintModel {
  final String complaintType;
  final String description;
  final List<String> photosPaths;
  final Map<String, dynamic> complaintData;
  final String hostel;
  final String roomNumber;

  HostelComplaintModel({
    required this.complaintType,
    required this.description,
    required this.photosPaths,
    required this.complaintData,
    this.hostel = '',
    this.roomNumber = '',
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'complaint_type': complaintType,
      'description': description,
      'hostel': hostel,
      'room_number': roomNumber,
    };

    json.addAll(complaintData);

    return json;
  }

  factory HostelComplaintModel.fromJson(Map<String, dynamic> json) {
    final complaintType = json['complaint_type'] as String;
    final description = json['description'] as String;
    final hostel = json['hostel'] as String? ?? '';
    final roomNumber = json['room_number'] as String? ?? '';

    final complaintData = Map<String, dynamic>.from(json);
    complaintData.remove('complaint_type');
    complaintData.remove('description');
    complaintData.remove('hostel');
    complaintData.remove('room_number');

    return HostelComplaintModel(
      complaintType: complaintType,
      description: description,
      photosPaths: [],
      complaintData: complaintData,
      hostel: hostel,
      roomNumber: roomNumber,
    );
  }

  HostelComplaintModel copyWith({
    String? complaintType,
    String? description,
    List<String>? photosPaths,
    Map<String, dynamic>? complaintData,
    String? hostel,
    String? roomNumber,
  }) {
    return HostelComplaintModel(
      complaintType: complaintType ?? this.complaintType,
      description: description ?? this.description,
      photosPaths: photosPaths ?? this.photosPaths,
      complaintData: complaintData ?? this.complaintData,
      hostel: hostel ?? this.hostel,
      roomNumber: roomNumber ?? this.roomNumber,
    );
  }

  @override
  String toString() {
    return 'HostelComplaintModel(complaintType: $complaintType, description: $description, hostel: $hostel, roomNumber: $roomNumber, photos: ${photosPaths.length} photos, complaintData: $complaintData)';
  }
}
