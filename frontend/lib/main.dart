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
import 'package:shared_preferences/shared_preferences.dart';

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

GlobalKey<NavigatorState> navigatorKey = GlobalKey();

class _MyAppState extends State<MyApp> {
  bool isLoading = true;
  bool isLoggedIn = false;

  int status = 0;
  int totalOperation = 1;
  void changeState() {
    setState(() {
      status++;
      if (status >= totalOperation) {
        isLoading = false;
      }
    });
  }

  getAuthStatus() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    setState(() {
      if (user != null) {
        isLoggedIn = true;
      }
    });
    changeState();
  }

  final FirebaseAnalyticsService _analyticsService = FirebaseAnalyticsService();

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    getAuthStatus();
    getThemeMode();
  }

  getThemeMode() async {
    const String themeKey = 'is_dark';
    final prefs = await SharedPreferences.getInstance();
    int? mode = prefs.getInt(themeKey);
    setState(() {
      _mode = mode;
    });
    changeState();
  }

  setThemeMode(int val) async {
    const String themeKey = 'is_dark';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(themeKey, val);
  }

  int? _mode;

  void handleThemeChange(int theme) {
    setState(() {
      if (theme == 1) {
        _mode = 1;
      } else if (theme == 2) {
        _mode = 2;
      } else {
        _mode = 0;
      }
    });

    setThemeMode(theme);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Dashboard',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _mode == null || _mode == 0
          ? ThemeMode.system
          : _mode == 1
              ? ThemeMode.light
              : ThemeMode.dark,
      navigatorObservers: [_analyticsService.getAnalyticsObserver()],
      home: isLoading
          ? SplashScreen(nextPage: Container())
          : isLoggedIn
              ? SplashScreen(
                  nextPage: HomeScreen(
                    onThemeChanged: handleThemeChange,
                    isGuest: false,
                  ),
                  isLoading: false,
                )
              : SplashScreen(
                  isLoading: false,
                  nextPage: LoginScreenWrapper(
                    onThemeChanged: handleThemeChange,
                    timeDilationFactor: 4.0,
                  )),
    );
  }
}
