import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/models/user_model.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  String backendUrl = "http://localhost:8000"; //TODO: put it in .env

  Future<UserModel?> authUser(String idToken) async {
    try {
      final response = await http.post(Uri.parse("$backendUrl/auth/login"), body: jsonEncode({"id_token": idToken}));
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        print(jsonResponse["access_token"]);
        print(jsonResponse["refresh_token"]);

        return UserModel(email: jsonResponse["email"], id: jsonResponse["id"]);
      }
    } catch (e) {
      debugPrint("ERR[authUser]: ${e.toString()}");
    }
    return null;
  }
}
