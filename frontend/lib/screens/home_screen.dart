import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:dashbaord/models/mess_menu_model.dart';
import 'package:dashbaord/models/user_model.dart';
import 'package:dashbaord/screens/cab_sharing_screen.dart';
import 'package:dashbaord/screens/lost_and_found_screen.dart';
import 'package:dashbaord/services/analytics_service.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:dashbaord/services/shared_service.dart';
import 'package:dashbaord/utils/bus_schedule.dart';
import 'package:dashbaord/utils/loading_widget.dart';
import 'package:dashbaord/widgets/home_card_no_options.dart';
import 'package:dashbaord/widgets/home_screen_appbar.dart';
import 'package:dashbaord/widgets/home_screen_bus_timings.dart';
import 'package:dashbaord/widgets/home_screen_mess_menu.dart';
import 'package:in_app_update/in_app_update.dart';

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
        duration: const Duration(milliseconds: 1500),
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
      showError(msg: "Server Refresh Failed...");
      final res = await SharedService().getMessMenu();
      setState(() {
        messMenu = res;
        changeState();
      });
      return;
    }
    setState(() {
      messMenu = response;
      changeState();
    });

    //save mess menu
    await SharedService().saveMessMenu(response);
  }

  Future<void> fetchBus() async {
    final response = await ApiServices().getBusSchedule(context);
    if (response == null) {
      showError(msg: "Server Refresh Failed...");
      final res = await SharedService().getBusSchedule();
      setState(() {
        busSchedule = res;
        changeState();
      });
      return;
    }
    setState(() {
      busSchedule = response;
      changeState();
    });

    //save bus schedule
    await SharedService().saveBusSchedule(response);
  }

  Future<void> fetchUser() async {
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
        image = user.photoURL ?? 'https://media.istockphoto.com/id/519078727/photo/male-silhouette-as-avatar-profile-picture.jpg?s=2048x2048&w=is&k=20&c=craUhUZK7FB8wYiGDHF0Az0T9BY1bmRHasCHoQbNLlg=';
        changeState();
      });
    } else {
      showError(msg: "User not logged in");
      setState(() {
        changeState();
      });
    }
  }

  getUserData() async {
    final user = await SharedService().getUserDetails();
    if (user['name'] == null || user['email'] == null) {
      await fetchUser();
      fetchUserProfile();
    } else {
      UserModel userM = UserModel(
          email: user['email'] ?? 'user@iith.ac.in',
          name: user['name'] ?? 'User');
      setState(() {
        userModel = userM;
        image = user['image'] ?? image;
        changeState();
        changeState();
      });
    }
  }

  saveUserData(String name, String email, String image) async {
    final ss = SharedService();
    await ss.saveUserDetails(name: name, email: email, imageUrl: image);
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

  final analyticsService = FirebaseAnalyticsService();

  @override
  void initState() {
    super.initState();
    checkForUpdates();
    if (!widget.isGuest) {
      totalOperation = totalOperation + 2;
      fetchUser();
      fetchUserProfile();
    }
    fetchMessMenu();
    fetchBus();
    analyticsService.logScreenView(screenName: "HomeScreen");
    if (status >= totalOperation) {
      saveUserData(userModel?.name ?? 'User',
          userModel?.email ?? 'user@iith.ac.in', image);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      isLoading = true;
      status = 0;
    });
    if (!widget.isGuest) {
      fetchUser();
      fetchUserProfile();
    }
    fetchMessMenu();
    fetchBus();
  }

   checkForUpdates() async {
    await Future.delayed(const Duration(seconds: 30));
    try {
      var updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          InAppUpdate.performImmediateUpdate().then((appUpdateResult) {
            if (appUpdateResult == AppUpdateResult.success) {}
          });
        } else if (updateInfo.flexibleUpdateAllowed) {
          InAppUpdate.startFlexibleUpdate().then((appUpdateResult) {
            if (appUpdateResult == AppUpdateResult.success) {
              InAppUpdate.completeFlexibleUpdate();
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error in checking for update: $e");
    }
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
                child: RefreshIndicator(
                  onRefresh: () {
                    return Future.delayed(const Duration(seconds: 1), _refresh);
                  },
                  child: ListView(
                    children: [
                      const SizedBox(height: 24),
                      HomeScreenAppBar(
                          image: image,
                          user: userModel,
                          isGuest: widget.isGuest),
                      const SizedBox(height: 28),
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
                                  builder: (context) => CabSharingScreen(
                                    usersEmail: userModel?.email ?? '',
                                  ),
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
            ),
    );
  }
}
