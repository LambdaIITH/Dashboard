import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:dashbaord/constants/app_theme.dart';
import 'package:dashbaord/firebase_options.dart';
import 'package:dashbaord/screens/home_screen.dart';
import 'package:dashbaord/screens/login_screen.dart';
import 'package:dashbaord/screens/splash_screen.dart';
import 'package:dashbaord/services/analytics_service.dart';
import 'package:dashbaord/services/api_service.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final apiServices = ApiServices();
  await apiServices.configureDio();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoading = true;
  bool isLoggedIn = false;

  getAuthStatus() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    setState(() {
      if (user == null) {
        isLoading = false;
      } else {
        isLoggedIn = true;
      }
      isLoading = false;
    });
  }

  final FirebaseAnalyticsService _analyticsService = FirebaseAnalyticsService();

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    getAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      navigatorObservers: [_analyticsService.getAnalyticsObserver()],
      home: isLoading
          ? SplashScreen(nextPage: Container())
          : isLoggedIn
              ? const SplashScreen(
                  nextPage: HomeScreen(
                    isGuest: false,
                  ),
                  isLoading: false,
                )
              : const SplashScreen(
                  isLoading: false,
                  nextPage: LoginScreenWrapper(
                    timeDilationFactor: 4.0,
                  )),
    );
  }
}
