class EmergencyContact {
  final String category;
  final String name;
  final String? contact;
  final String? mobile;

  const EmergencyContact({
    required this.category,
    required this.name,
    this.contact,
    this.mobile,
  });
}
