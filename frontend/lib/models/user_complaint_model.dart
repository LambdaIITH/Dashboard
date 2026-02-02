class UserComplaintModel {
  final int id;
  final int? userId;
  final String complaintDescription;
  final Map<String, dynamic> complaintData;
  final String complaintStatus;
  final String createdAt;
  final String? resolvedAt;
  final String? userName;
  final String? userEmail;
  final List<String> images;
  final String hostel;
  final String roomNumber;

  UserComplaintModel({
    required this.id,
    this.userId,
    required this.complaintDescription,
    required this.complaintData,
    required this.complaintStatus,
    required this.createdAt,
    this.resolvedAt,
    this.userName,
    this.userEmail,
    required this.images,
    this.hostel = '',
    this.roomNumber = '',
  });

  factory UserComplaintModel.fromJson(Map<String, dynamic> json) {
    return UserComplaintModel(
      id: json['id'] as int,
      userId: json['user_id'] as int?,
      complaintDescription: json['complaint_description'] as String? ?? '',
      complaintData: json['complaint_data'] != null
          ? Map<String, dynamic>.from(json['complaint_data'] as Map)
          : {},
      complaintStatus: json['complaint_status'] as String? ?? 'Pending',
      createdAt: json['created_at'] as String,
      resolvedAt: json['resolved_at'] as String?,
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      hostel: json['hostel'] as String? ?? '',
      roomNumber: json['room_number'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'user_id': userId,
      'complaint_description': complaintDescription,
      'complaint_data': complaintData,
      'complaint_status': complaintStatus,
      'created_at': createdAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (userName != null) 'user_name': userName,
      if (userEmail != null) 'user_email': userEmail,
      'images': images,
      'hostel': hostel,
      'room_number': roomNumber,
    };
  }

  String getComplaintType() {
    return complaintData['complaint_type'] as String? ?? 'Unknown';
  }

  String getFormattedDate() {
    try {
      final dateTime = DateTime.parse(createdAt);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return createdAt;
    }
  }

  bool isResolved() {
    return complaintStatus.toLowerCase() == 'resolved' || resolvedAt != null;
  }

  bool isPending() {
    return complaintStatus.toLowerCase() == 'pending';
  }

  bool isInProgress() {
    return complaintStatus.toLowerCase() == 'in_progress' ||
        complaintStatus.toLowerCase() == 'in progress' ||
        complaintStatus.toLowerCase() == 'on going';
  }

  @override
  String toString() {
    return 'UserComplaintModel(id: $id, type: ${getComplaintType()}, status: $complaintStatus, date: $createdAt, hostel: $hostel, room: $roomNumber)';
  }
}
