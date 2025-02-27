import 'dart:convert';
import 'dart:io';

import 'package:dashbaord/main.dart';
import 'package:dashbaord/models/mess_menu_model.dart';
import 'package:dashbaord/models/time_table_model.dart';
import 'package:dashbaord/models/user_model.dart';
import 'package:dashbaord/services/analytics_service.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:dashbaord/services/event_notification_service.dart';
import 'package:dashbaord/services/shared_service.dart';
import 'package:dashbaord/utils/bus_schedule.dart';
import 'package:dashbaord/utils/loading_widget.dart';
import 'package:dashbaord/widgets/homeScreenCardSmall.dart';
import 'package:dashbaord/widgets/home_screen_appbar.dart';
import 'package:dashbaord/widgets/home_screen_bus_timings.dart';
import 'package:dashbaord/widgets/home_screen_calendar.dart';
import 'package:dashbaord/widgets/home_screen_mess_menu.dart';
import 'package:dashbaord/widgets/timetable/manage_courses_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_widget/home_widget.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatefulWidget {
  final bool isGuest;
  final ValueChanged<int> onThemeChanged;
  final String? code;
  const HomeScreen(
      {super.key,
      required this.isGuest,
      required this.onThemeChanged,
      this.code});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

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
  int mainGateStatus = -1;
  Timetable? timetable;

  void sendTokenToServer(String token, String deviceType) async {
    final response =
        await ApiServices().updateFCMToken(context, token, deviceType);
    if (response) {
      debugPrint("FCM Token updated successfully");
      await SharedService().storeToken(token);
    } else {
      debugPrint("Failed to update FCM Token");
    }
  }

  Future<void> setUpFirebaseMessaging() async {
    String? oldToken = await SharedService().getStoredToken();
    if (kIsWeb) {
      final fcmToken = await FirebaseMessaging.instance
          .getToken(vapidKey: dotenv.env["VAPID_KEY"] ?? "VAPID_KEY_NOT_FOUND");
      if (fcmToken != null && fcmToken != oldToken) {
        sendTokenToServer(fcmToken, "web");
      }
      return;
    }

    String? newToken = await _firebaseMessaging.getToken();

    if (newToken == null) {
      debugPrint("No FCM token available");
      return;
    }
    if (newToken == oldToken) {
      debugPrint("FCM token unchanged, no need to update server");
    } else {
      sendTokenToServer(newToken, Platform.isAndroid ? "android" : "ios");
    }

    _firebaseMessaging.onTokenRefresh.listen((refreshedToken) async {
      String? storedToken = await SharedService().getStoredToken();
      if (refreshedToken != storedToken) {
        sendTokenToServer(
            refreshedToken, Platform.isAndroid ? "android" : "ios");
      }
    });
  }

  int? week;
  Future<void> fetchWeekNumber() async {
    final response = await ApiServices().getWeekNumber(context);
    if (response != null) {
      setState(() {
        week = response['week'];
        week = week != null ? week! + 1 : week;
      });
    }
  }

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

    await fetchWeekNumber();
    setState(() {
      messMenu = response;
      changeState();
    });

    //save mess menu
    await SharedService().saveMessMenu(response);
    updateAndroidWidget(response);
  }

  void updateAndroidWidget(MessMenuModel messMenu) {
    HomeWidget.saveWidgetData(
        "widget_mess_menu", jsonEncode(messMenu.toJson()));
    HomeWidget.updateWidget(
      androidName: "MessMenuWidget",
    );
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

  Future<void> fetchTimetable() async {
    Timetable? localTimetable = await SharedService().getTimetable();
    Timetable? response;
    if (!widget.isGuest) {
      response = await ApiServices().getTimetable(context);
    }

    if (response == null) {
      if (localTimetable == null) {
        showError(msg: "Timetable not found. Please add courses.");
        setState(() {
          timetable = Timetable(courses: {}, slots: []);
          changeState();
        });
        return;
      } else {
        showError(msg: "Timetable Server refresh failed...");
        localTimetable.cleanUp();
        setState(() {
          timetable = localTimetable;
          changeState();
        });
        return;
      }
    } else {
      response.cleanUp();
      setState(() {
        timetable = response;
        changeState();
      });

      await SharedService().saveTimetable(response);
    }
  }

  Future<void> fetchUser() async {
    final response = await ApiServices().getUserDetails(context);
    if (response == null) {
      setState(() {
        changeState();
      });
      var u = await SharedService().getUserDetails();
      if (u['name'] == null) {
        saveUserData('User', 'user@iith.ac.in');
      }
      return;
    }
    setState(() {
      userModel = response;
      changeState();
    });
    saveUserData(response.name, response.email);
  }

  void fetchUserProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        image = user.photoURL ??
            'https://media.istockphoto.com/id/519078727/photo/male-silhouette-as-avatar-profile-picture.jpg?s=2048x2048&w=is&k=20&c=craUhUZK7FB8wYiGDHF0Az0T9BY1bmRHasCHoQbNLlg=';
        changeState();
      });

      SharedService().saveUserImage(
          image: user.photoURL ??
              'https://media.istockphoto.com/id/519078727/photo/male-silhouette-as-avatar-profile-picture.jpg?s=2048x2048&w=is&k=20&c=craUhUZK7FB8wYiGDHF0Az0T9BY1bmRHasCHoQbNLlg=');
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

  saveUserData(String name, String email) async {
    final ss = SharedService();
    await ss.saveUserDetails(name: name, email: email);
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

  String eventText = "";
  getEventText() async {
    String text = await ApiServices().getEventText();
    setState(() {
      eventText = text;
      changeState();
    });
  }

  final analyticsService = FirebaseAnalyticsService();

  @override
  void initState() {
    super.initState();
    checkForUpdates();
    getMainGateStatus();
    if (!widget.isGuest) {
      totalOperation = totalOperation + 3;
      fetchUser();
      fetchUserProfile();
    }
    fetchMessMenu();
    fetchBus();
    fetchTimetable();
    setUpFirebaseMessaging();
    analyticsService.logScreenView(screenName: "HomeScreen");
    // Initialize the controller properly
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
    getMainGateStatus();
  }

  checkForUpdates() async {
    await Future.delayed(const Duration(seconds: 3));
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

  Future<void> getMainGateStatus() async {
    int status = await ApiServices().getMainGateStatus();
    setState(() {
      mainGateStatus = status;
    });
  }

  void showTimeTableConfirmationDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Theme.of(context).cardColor,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20, // Larger font size for main text
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text:
                          'Are you sure you want to accept the timetable with code: ',
                    ),
                    TextSpan(
                      text: code,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        color: Colors.greenAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Note: This will replace your current timetable, and this action cannot be undone.',
                style: TextStyle(
                  color: const Color.fromARGB(
                      255, 255, 210, 100), // Softer warning color
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Show a friendly cancellation message
                showError(
                    msg:
                        "You have chosen not to change your timetable. No worries!");
                Navigator.of(context).pop();
              },
              child: Text(
                'No',
                style: TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final response =
                    await ApiServices().getSharedTimetable(context, code);
                Timetable? sharedTimetable = response[0] as Timetable?;
                int status =
                    response[1] as int; // Assuming status is in response[1]
                String message = response[2] as String;
                if (status == 200) {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return ManageCoursesBottomSheet(
                        timetable: timetable,
                        onEditTimetable: (editedTimetable) async {
                          setState(() {
                            timetable = editedTimetable;
                          });
                          final res =
                              await ApiServices().postTimetable(timetable!);
                          if (res['status'] != 200) {
                            showError(msg: "Failed to save timetable.");
                          } else {
                            showError(msg: "Timetable saved successfully!");
                            await SharedService().saveTimetable(timetable!);
                          }
                        },
                        isAddCourses: true,
                      );
                    },
                    isScrollControlled: true,
                  );
                  setState(() {
                    timetable = sharedTimetable;
                  });
                  showError(msg: "Timetable accepted successfully!");
                } else {
                  showError(
                      msg: message.isNotEmpty
                          ? message
                          : "Oops! Something went wrong while fetching the timetable.");
                }
              },
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.greenAccent, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  bool isDialogShown = false;

  @override
  Widget build(BuildContext context) {
    timeDilation = 1;
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0.0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Theme.of(context).brightness,
            // Status bar color
            statusBarColor: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        // ),
        key: _scaffoldKey,
        body: Builder(builder: (BuildContext bc) {
          if (widget.code != null && !isDialogShown) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showTimeTableConfirmationDialog(context, widget.code!);
            });
            isDialogShown = true;
          }
          return isLoading
              ? const CustomLoadingScreen()
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: RefreshIndicator(
                      onRefresh: () {
                        return Future.delayed(
                            const Duration(seconds: 1), _refresh);
                      },
                      child: ListView(
                        children: [
                          const SizedBox(height: 24),
                          HomeScreenAppBar(
                              status: mainGateStatus,
                              onThemeChanged: widget.onThemeChanged,
                              image: image,
                              user: userModel,
                              isGuest: widget.isGuest),
                          if (eventText.isNotEmpty) const SizedBox(height: 28),
                          if (eventText.isNotEmpty)
                            TextScroll(
                              eventText,
                              velocity: const Velocity(
                                  pixelsPerSecond: Offset(50, 0)),
                              delayBefore: const Duration(milliseconds: 900),
                              pauseBetween: const Duration(milliseconds: 100),
                              style: const TextStyle(color: Colors.purple),
                              textAlign: TextAlign.center,
                              selectable: true,
                            ),
                          const SizedBox(height: 28),
                          HomeScreenSchedule(
                            timetable: timetable,
                            onEditTimetable: (editedTimetable) async {
                              setState(
                                () {
                                  timetable = editedTimetable;
                                },
                              );
                              final res =
                                  await ApiServices().postTimetable(timetable!);
                              if (res['status'] != 200) {
                                showError(msg: "Failed to save timetable.");
                              } else {
                                showError(msg: "Timetable saved successfully!");
                                await SharedService().saveTimetable(timetable!);
                                clearAllNotifications();
                                EventNotificationService
                                    .scheduleWeeklyNotifications(
                                        timetable: timetable!);
                              }
                            },
                            onLectureAdded: (courseCode, courseName, lectures,
                                String? classRoom, String? slot) async {
                              if (timetable != null) {
                                setState(
                                  () {
                                    timetable = timetable!.addCourse(
                                        courseCode, courseName, lectures,
                                        classRoom: classRoom, slot: slot);
                                  },
                                );
                                final res = await ApiServices()
                                    .postTimetable(timetable!);
                                if (res['status'] != 200) {
                                  showError(msg: "Failed to save timetable.");
                                } else {
                                  showError(
                                      msg: "Timetable saved successfully!");
                                  await SharedService()
                                      .saveTimetable(timetable!);
                                  clearAllNotifications();
                                  EventNotificationService
                                      .scheduleWeeklyNotifications(
                                          timetable: timetable!);
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 15),
                          HomeScreenBusTimings(
                            busSchedule: busSchedule,
                          ),
                          const SizedBox(height: 15),
                          HomeScreenMessMenu(messMenu: messMenu, week: week),
                          const SizedBox(height: 15),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[900] // Dark mode background
                                  : Colors.grey[200], // Light mode background
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.fromLTRB(12.0, 8.0, 1.0, 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Services',
                                  style: GoogleFonts.inter(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Wrap(
                                  spacing:
                                      10.0, // Horizontal spacing between cards
                                  runSpacing:
                                      10.0, // Vertical spacing between rows
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width >
                                              450
                                          ? 200
                                          : MediaQuery.of(context).size.width /
                                                  3 -
                                              28, // Half of the screen width minus spacing
                                      child: HomeScreenCardSmall(
                                        width:
                                            MediaQuery.of(context).size.width >
                                                    450
                                                ? 200
                                                : MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2 -
                                                    25,
                                        isComingSoon: false,
                                        title: 'Cab Sharing',
                                        child:
                                            'assets/icons/cab-sharing-icon.svg',
                                        onTap: () {
                                          widget.isGuest
                                              ? showError()
                                              : context
                                                  .push('/cabsharing', extra: {
                                                  'user': userModel ??
                                                      UserModel(
                                                          email:
                                                              "user@iith.ac.in",
                                                          name: "User"),
                                                  'image': image,
                                                });
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width >
                                              450
                                          ? 200
                                          : MediaQuery.of(context).size.width /
                                                  3 -
                                              28,
                                      child: HomeScreenCardSmall(
                                        width:
                                            MediaQuery.of(context).size.width >
                                                    450
                                                ? 200
                                                : MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2 -
                                                    25,
                                        isComingSoon: false,
                                        reduceImageSize: true,
                                        title: 'Lost & Found',
                                        child:
                                            'assets/icons/magnifying-icon.svg',
                                        onTap: widget.isGuest
                                            ? showError
                                            : () => context.push('/lnf',
                                                    extra: {
                                                      'currentUserEmail':
                                                          userModel?.email ??
                                                              'user@iith.ac.in'
                                                    }),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width >
                                              450
                                          ? 200
                                          : MediaQuery.of(context).size.width /
                                                  3 -
                                              28,
                                      child: HomeScreenCardSmall(
                                        width:
                                            MediaQuery.of(context).size.width >
                                                    450
                                                ? 200
                                                : MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2 -
                                                    25,
                                        isComingSoon: false,
                                        reduceImageSize: true,
                                        title: 'Bus Shuttle',
                                        child: 'assets/icons/bus-svg.svg',
                                        onTap: () {
                                          // widget.isGuest
                                          //     ? showError()
                                          context.push('/city_bus');
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width >
                                              450
                                          ? 200
                                          : MediaQuery.of(context).size.width /
                                                  3 -
                                              28,
                                      child: HomeScreenCardSmall(
                                        width:
                                            MediaQuery.of(context).size.width >
                                                    450
                                                ? 200
                                                : MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2 -
                                                    25,
                                        isComingSoon: false,
                                        reduceImageSize: true,
                                        title: 'Face',
                                        child: 'assets/icons/bus-svg.svg',
                                        onTap: () {
                                          // widget.isGuest
                                          //     ? showError()
                                          context.push('/face_upload');
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width >
                                              450
                                          ? 200
                                          : MediaQuery.of(context).size.width /
                                                  3 -
                                              28,
                                      child: HomeScreenCardSmall(
                                        width:
                                            MediaQuery.of(context).size.width >
                                                    450
                                                ? 200
                                                : MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2 -
                                                    25,
                                        isComingSoon: false,
                                        reduceImageSize: true,
                                        title: 'Merch',
                                        child: 'assets/icons/bus-svg.svg',
                                        onTap: () {
                                          // widget.isGuest
                                          //     ? showError()
                                          context.push('/');
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width >
                                              450
                                          ? 200
                                          : MediaQuery.of(context).size.width /
                                                  3 -
                                              28,
                                      child: HomeScreenCardSmall(
                                        width:
                                            MediaQuery.of(context).size.width >
                                                    450
                                                ? 200
                                                : MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2 -
                                                    25,
                                        isComingSoon: false,
                                        reduceImageSize: true,
                                        title: 'IITH Community',
                                        child: 'assets/icons/bus-svg.svg',
                                        onTap: () {
                                          // widget.isGuest
                                          //     ? showError()
                                          context.push("/community");
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
        }));
  }
}
