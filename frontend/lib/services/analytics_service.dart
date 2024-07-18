import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver getAnalyticsObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  Future<void> logEvent({required String name,Map<String, Object>? parameters}) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  Future<void> logLogin({required String loginMethod}) async {
    await _analytics.logLogin(loginMethod: loginMethod);
  }

  Future<void> logScreenView({required String screenName}) async {
    await _analytics.logScreenView(screenName: screenName);
  }
}
