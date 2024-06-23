class BusSchedule {
  final Map<String, List<String>> fromIITH;
  final Map<String, List<String>> toIITH;

  BusSchedule({required this.fromIITH, required this.toIITH});

  factory BusSchedule.fromJson(Map<String, dynamic> json) {
    return BusSchedule(
      fromIITH: Map<String, List<String>>.from(
        json['FROMIITH'].map((key, value) => MapEntry(key, List<String>.from(value))),
      ),
      toIITH: Map<String, List<String>>.from(
        json['TOIITH'].map((key, value) => MapEntry(key, List<String>.from(value))),
      ),
    );
  }
}
