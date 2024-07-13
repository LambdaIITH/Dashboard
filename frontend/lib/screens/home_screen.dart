import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:frontend/models/mess_menu_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/screens/cab_sharing_screen.dart';
import 'package:frontend/screens/lost_and_found_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/utils/bus_schedule.dart';
import 'package:frontend/utils/loading_widget.dart';
import 'package:frontend/widgets/home_card_no_options.dart';
import 'package:frontend/widgets/home_screen_appbar.dart';
import 'package:frontend/widgets/home_screen_bus_timings.dart';
import 'package:frontend/widgets/home_screen_mess_menu.dart';

class HomeScreen extends StatefulWidget {
  final bool isGuest;
  const HomeScreen({
    super.key,
    required this.isGuest,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  void showError({String? msg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg ?? 'Please login to use this feature'),
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  MessMenuModel? messMenu;
  BusSchedule? busSchedule;
  UserModel? userModel;
  bool isLoading = true;
  String image = '';

  void fetchMessMenu() async {
    final response = await ApiServices().getMessMenu(context);
    if (response == null) {
      showError(msg: "Failed To Fetch Mess Menu");
      setState(() {
        changeState();
      });
      return;
    }
    setState(() {
      messMenu = response;
      changeState();
    });
  }

  void fetchBus() async {
    final response = await ApiServices().getBusSchedule(context);
    if (response == null) {
      showError(msg: "Failed To Fetch Bus Schedule");
      setState(() {
        changeState();
      });
      return;
    }
    setState(() {
      busSchedule = response;
      changeState();
    });
  }

  void fetchUser() async {
    final response = await ApiServices().getUserDetails(context);
    if (response == null) {
      setState(() {
        changeState();
      });
      return;
    }
    setState(() {
      userModel = response;
      changeState();
    });
  }

  void fetchUserProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        image = user.photoURL ?? '';
        changeState();
      });
    } else {
      showError(msg: "User not logged in");
      setState(() {
        changeState();
      });
    }
  }

  int status = 0;
  int totalOperation = 2;

  void changeState() {
    setState(() {
      status++;
      if (status >= totalOperation) {
        isLoading = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (!widget.isGuest) {
      totalOperation = totalOperation + 2;
      fetchUser();
      fetchUserProfile();
    }
    fetchMessMenu();
    fetchBus();
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xfffcfcfc),
      body: isLoading
          ? const CustomLoadingScreen()
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  children: [
                    const SizedBox(height: 24),
                    HomeScreenAppBar(
                      image: image,
                      user: userModel,
                      isGuest: widget.isGuest
                    ),
                    const SizedBox(height: 28),
                    // HomeCardNoOptions(
                    //   title: 'Time Table',
                    //   child: 'assets/icons/calendar.svg',
                    //   onTap: () {
                    //     widget.user == 'guest'
                    //         ? showError()
                    //         : Navigator.of(context).push(MaterialPageRoute(
                    //             builder: (context) => const TimeTableScreen(),
                    //           ));
                    //   },
                    // ),
                    // const SizedBox(height: 20),
                    HomeScreenBusTimings(
                      busSchedule: busSchedule,
                    ),
                    const SizedBox(height: 20),
                    HomeScreenMessMenu(messMenu: messMenu),
                    const SizedBox(height: 20),
                    HomeCardNoOptions(
                      title: 'Cab Sharing',
                      child: 'assets/icons/cab-sharing-icon.svg',
                      onTap: () {
                        widget.isGuest
                            ? showError()
                            : Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const CabSharingScreen(),
                              ));
                      },
                    ),
                    const SizedBox(height: 20),
                    HomeCardNoOptions(
                      title: 'Lost & Found',
                      child: 'assets/icons/magnifying-icon.svg',
                      onTap: widget.isGuest
                          ? showError
                          : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const LostAndFoundScreen(),
                                ),
                              ),
                    ),
                    const SizedBox(
                      height: 50,
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
