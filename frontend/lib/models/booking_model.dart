import 'package:frontend/models/travellers.dart';

class BookingModel {
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final String fromLoc;
  final String toLoc;
  final String ownerEmail;
  List<TravellersModel>? requests = [];
  final List<TravellersModel> travellers;

  BookingModel(
      {required this.startTime,
      required this.endTime,
      required this.capacity,
      required this.fromLoc,
      required this.toLoc,
      required this.ownerEmail,
      required this.travellers,
      this.requests});

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
        startTime: DateTime.parse(json['start_time']),
        endTime: DateTime.parse(json['end_time']),
        capacity: json['capacity'],
        fromLoc: json['from_loc'],
        toLoc: json['to_loc'],
        requests: json["requests"],
        travellers: json["travellers"],
        ownerEmail: json["owner_email"]);
  }

  Map<String, dynamic> toJson() {
    return {
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'capacity': capacity,
      'from_loc': fromLoc,
      'to_loc': toLoc,
      'requests': requests,
      'travellers': travellers,
      'owner_email': ownerEmail
    };
  }
}
