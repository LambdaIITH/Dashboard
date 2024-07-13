import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/screens/bus_timings_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/splash_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/utils/loading_widget.dart';
// import 'package:frontend/screens/mess_menu_screen.dart';
// import 'package:frontend/screens/login_screen.dart';
// import 'package:frontend/screens/splash_screen.dart';

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

  @override
  void initState() {
    super.initState();
    getAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoading
          ? SplashScreen(nextPage: Container())
          : isLoggedIn
              ? const SplashScreen(
                  nextPage: HomeScreen(user: "user"),
                  isLoading: false,
                )
              : const SplashScreen(
                  isLoading: false,
                  nextPage: LoginScreenWrapper(
                    timeDilationFactor: 4.0,
                  )),
      // home: SplashScreen(
      //     nextPage: LoginScreenWrapper(
      //   timeDilationFactor: 4.0,
      // )),
      //  home: HomeScreen(user: ''),
      //  home: BusTimingsScreen(),
      // home: MessMenuScreen(),
    );
  }
}
