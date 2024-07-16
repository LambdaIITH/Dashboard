import 'package:frontend/models/travellers.dart';

class BookingModel {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final String fromLoc;
  final String toLoc;
  final String ownerEmail;
  final List<TravellersModel> requests;
  final List<TravellersModel> travellers;

  BookingModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.fromLoc,
    required this.toLoc,
    required this.ownerEmail,
    required this.travellers,
    this.requests = const [],
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    var travellersfromJson =
        json['travellers'] is List ? json['travellers'] as List : [];
    var requestsfromJson =
        json['requests'] is List ? json['requests'] as List : [];

    List<TravellersModel> travellers =
        travellersfromJson.map((e) => TravellersModel.fromJson(e)).toList();
    List<TravellersModel> requests =
        requestsfromJson.map((e) => TravellersModel.fromJson(e)).toList();

    return BookingModel(
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      capacity: json['capacity'],
      fromLoc: json['from_'],
      toLoc: json['to'],
      requests: requests,
      travellers: travellers,
      ownerEmail: json["owner_email"],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'capacity': capacity,
      'from_loc': fromLoc,
      'to_loc': toLoc,
      'comments': travellers[0].comments,
      // 'requests': requests,
      // 'travellers': travellers,
      // 'owner_email': ownerEmail
    };
  }
}
