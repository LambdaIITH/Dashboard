import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

class DioConfig {
  Dio getClient() {
    return Dio()..httpClientAdapter = BrowserHttpClientAdapter(withCredentials: true);
  }
}
