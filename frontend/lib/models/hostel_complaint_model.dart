class HostelComplaintModel {
  final String complaintType;
  final String description;
  final List<String> photosPaths;
  final Map<String, dynamic> complaintData;

  HostelComplaintModel({
    required this.complaintType,
    required this.description,
    required this.photosPaths,
    required this.complaintData,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'complaint_type': complaintType,
      'description': description,
    };

    json.addAll(complaintData);

    return json;
  }

  factory HostelComplaintModel.fromJson(Map<String, dynamic> json) {
    final complaintType = json['complaint_type'] as String;
    final description = json['description'] as String;

    final complaintData = Map<String, dynamic>.from(json);
    complaintData.remove('complaint_type');
    complaintData.remove('description');

    return HostelComplaintModel(
      complaintType: complaintType,
      description: description,
      photosPaths: [],
      complaintData: complaintData,
    );
  }

  HostelComplaintModel copyWith({
    String? complaintType,
    String? description,
    List<String>? photosPaths,
    Map<String, dynamic>? complaintData,
  }) {
    return HostelComplaintModel(
      complaintType: complaintType ?? this.complaintType,
      description: description ?? this.description,
      photosPaths: photosPaths ?? this.photosPaths,
      complaintData: complaintData ?? this.complaintData,
    );
  }

  @override
  String toString() {
    return 'HostelComplaintModel(complaintType: $complaintType, description: $description, photos: ${photosPaths.length} photos, complaintData: $complaintData)';
  }
}
