class BusSchedule {
  final List<String> fromIITH;
  final List<String> toIITH;

  BusSchedule({required this.fromIITH, required this.toIITH});

  factory BusSchedule.fromJson(Map<String, dynamic> json) {
    return BusSchedule(
      fromIITH: List<String>.from(json['Maingate-Hospital-Hostel Circle']),
      toIITH: List<String>.from(json['Hostel Circle-Hospital-Maingate']),
    );
  }
}
