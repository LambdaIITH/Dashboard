import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/user_model.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

class ApiServices {
  static final ApiServices _instance = ApiServices._internal();
  factory ApiServices() => _instance;

  ApiServices._internal();

  final dio = Dio();
  PersistCookieJar? cookieJar;
  String backendUrl = dotenv.env["BACKEND_URL"] ?? "";

  Future<void> configureDio() async {
    dio.options.baseUrl = backendUrl;

    // initialize cookie jar
    var appDocDir = await getApplicationDocumentsDirectory();
    var cookiePath = "${appDocDir.path}/.cookies/";
    cookieJar = PersistCookieJar(storage: FileStorage(cookiePath));

    // add cookie manager to Dio
    dio.interceptors.add(CookieManager(cookieJar!));

    debugPrint("Dio configured with base URL: ${dio.options.baseUrl}");
  }

  Future<Map<String, dynamic>> login(String idToken) async {
    try {
      debugPrint("Making login request to: ${dio.options.baseUrl}/auth/login");
      final response = await dio.post('/auth/login', data: {'id_token': idToken});
      final data = response.data;
      final userModel = UserModel(
        id: data['id'],
        email: data['email'],
      );
      return {'user': userModel, 'status': response.statusCode};
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode == 401) {
        return {'error': e.response?.data['detail']['error'], 'status': 401};
      }
      debugPrint("Login failed: $e");
      return {'error': 'Login failed', 'status': e.response?.statusCode};
    }
  }
}

  // Future<void> testCookie() async {
  //   try {
  //     debugPrint("Making login request to: ${dio.options.baseUrl}/mess_menu");
  //     final response = await dio.get('/mess_menu');
  //     print(response.statusCode);
  //   } catch (e) {
  //     debugPrint("Login failed: $e");
  //   }
  // }
