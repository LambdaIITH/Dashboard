// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/mess_menu_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  //======================================================================
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ["email"]);

  Future<void> googleLogout() async {
    await _googleSignIn.signOut();
  }

  void showError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Session Expired Please Login again!'),
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    await googleLogout();
    showError(context);
  }

  Future<Map<String, dynamic>> login(String idToken) async {
    try {
      debugPrint("Making request to: ${dio.options.baseUrl}/auth/login");
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

  Future<MessMenuModel?> getMessMenu(BuildContext context) async {
    try {
      debugPrint("Making request to: ${dio.options.baseUrl}/mess_menu");
      final response = await dio.get('/mess_menu');

      if (response.statusCode == 401) {
        await logout(context);
        return null;
      }

      final data = response.data;
      return MessMenuModel.fromJson(data);
    } catch (e) {
      debugPrint("Failed to fetch mess menu: $e");
      return null;
    }
  }
}
