import 'package:dashbaord/constants/enums/lost_and_found.dart';
import 'package:dashbaord/error.dart';
import 'package:dashbaord/models/mess_menu_model.dart';
import 'package:dashbaord/models/user_model.dart';
import 'package:dashbaord/screens/announcement_screen.dart';
import 'package:dashbaord/screens/city_bus_screen.dart';
import 'package:dashbaord/screens/bus_timings_screen.dart';
import 'package:dashbaord/screens/cab_add_screen.dart';
import 'package:dashbaord/screens/cab_add_success.dart';
import 'package:dashbaord/screens/cab_sharing_screen.dart';
import 'package:dashbaord/screens/community_screen.dart';
import 'package:dashbaord/screens/face_upload_screen.dart';
import 'package:dashbaord/screens/home_screen.dart';
import 'package:dashbaord/screens/igh_room_booking.dart';
import 'package:dashbaord/screens/login_screen.dart';
import 'package:dashbaord/screens/lost_and_found_add_item_screen.dart';
import 'package:dashbaord/screens/lost_and_found_item_screen.dart';
import 'package:dashbaord/screens/lost_and_found_screen.dart';
import 'package:dashbaord/screens/mess_menu_screen.dart';
import 'package:dashbaord/screens/profile_screen.dart';
import 'package:dashbaord/services/analytics_service.dart';
import 'package:dashbaord/utils/bus_schedule.dart';
import 'package:dashbaord/utils/loading_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static AppRouter? _instance;

  factory AppRouter({required Function(int) onThemeChanged}) {
    _instance ??= AppRouter._internal(onThemeChanged: onThemeChanged);
    return _instance!;
  }

  AppRouter._internal({required this.onThemeChanged});

  final FirebaseAnalyticsService _analyticsService = FirebaseAnalyticsService();
  final Function(int) onThemeChanged;

  bool getAuthStatus() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    return user != null;
  }

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    observers: [_analyticsService.getAnalyticsObserver()],
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) {
          final isLoggedIn = getAuthStatus();

          if (state.fullPath == '/') {
            return isLoggedIn ? '/home' : '/login';
          }

          return null;
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          final isLoggedIn = getAuthStatus();

          final data = state.extra as Map<String, dynamic>? ?? {};
          bool isGuest = data['isGuest'] as bool? ?? true;
          final code = data['code'] as String?;

          if (isLoggedIn) {
            isGuest = false;
          }

          return HomeScreen(
            isGuest: isGuest,
            onThemeChanged: onThemeChanged,
            code: code,
          );
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          final timeDilationFactor =
              data['timeDilationFactor'] as double? ?? 1.0;
          final timetableCode = data['timetableCode'];

          return LoginScreenWrapper(
            timeDilationFactor: timeDilationFactor,
            onThemeChanged: onThemeChanged,
            code: timetableCode,
          );
        },
      ),
      GoRoute(
        path: '/me',
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          final user = data['user'] as UserModel?;
          final image = data['image'] as String?;

          return CustomTransitionPage(
            key: state.pageKey,
            child: ProfileScreen(
              user: user,
              image: image,
              onThemeChanged: onThemeChanged,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/city_bus',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: CityBusScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/face_upload',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: FaceUploadScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/igh_booking',
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          final user = data['user'] as UserModel?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: RoomBookingForm(
              user: user,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/cabsharing',
        pageBuilder: (context, state) {
          final isMeStr = state.uri.queryParameters['me'];
          final startTimeString = state.uri.queryParameters['startTime'];
          final endTimeString = state.uri.queryParameters['endTime'];
          final from = state.uri.queryParameters['from'];
          final to = state.uri.queryParameters['to'];

          bool? isMe;

          if (isMeStr == 'true') {
            isMe = true;
          } else if (isMeStr == 'false') {
            isMe = false;
          }

          final startTime =
              startTimeString != null ? DateTime.parse(startTimeString) : null;
          final endTime =
              endTimeString != null ? DateTime.parse(endTimeString) : null;

          final data = state.extra as Map<String, dynamic>? ?? {};
          final user = data['user'] as UserModel?;
          final isMyRide = data['isMyRide'] as bool? ?? false;

          return CustomTransitionPage(
            key: state.pageKey,
            child: CabSharingScreen(
              user: user,
              isMyRide: isMe ?? isMyRide,
              startTime: startTime,
              endTime: endTime,
              from: from,
              to: to,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/cabsharing/add',
        pageBuilder: (context, state) {
          final fromLocation = state.uri.queryParameters['from'];
          final toLocation = state.uri.queryParameters['to'];
          final start = state.uri.queryParameters['start'];
          final end = state.uri.queryParameters['end'];
          final seats = state.uri.queryParameters['seats'];
          final comments = state.uri.queryParameters['comments'];

          return CustomTransitionPage(
            key: state.pageKey,
            child: CabAddScreen(
              from: fromLocation,
              to: toLocation,
              startTime: start,
              endTime: end,
              seats: seats,
              comments: comments,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/cabsharing/add/success',
        builder: (context, state) {
          return CabAddSuccess();
        },
      ),
      GoRoute(
        path: '/lnf',
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          final currentUserEmail = data['currentUserEmail'] as String?;

          return CustomTransitionPage(
            key: state.pageKey,
            child: LostAndFoundScreen(
              currentUserEmail: currentUserEmail,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/lnf/add',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: LostAndFoundAddItemScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/lnf/:item/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'];
          final item = state.pathParameters['item'];

          if (id == null) {
            return CustomTransitionPage(
              child: const ErrorScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            );
          }

          LostOrFound lrf;
          if (item == 'lost') {
            lrf = LostOrFound.lost;
          } else if (item == 'found') {
            lrf = LostOrFound.found;
          } else {
            return CustomTransitionPage(
              child: const ErrorScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            );
          }

          final data = state.extra as Map<String, dynamic>? ?? {};
          final currentUserEmail = data['currentUserEmail'] as String?;

          return CustomTransitionPage(
            key: state.pageKey,
            child: LostAndFoundItemScreen(
              currentUserEmail: currentUserEmail,
              id: id,
              lostOrFound: lrf,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/mess',
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          final messMenu = data['messMenu'] as MessMenuModel?;
          final week = data['week'] as int?;

          return CustomTransitionPage(
            key: state.pageKey,
            child: MessMenuScreen(
              messMenu: messMenu,
              week: week,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/bus',
        pageBuilder: (context, state) {
          final fullStr = state.uri.queryParameters['full'];
          bool? full;
          if (fullStr == 'true') {
            full = true;
          } else if (fullStr == 'false') {
            full = false;
          }

          final data = state.extra as Map<String, dynamic>? ?? {};
          final busSchedule = data['busSchedule'] as BusSchedule?;

          return CustomTransitionPage(
            key: state.pageKey,
            child: BusTimingsScreen(
              busSchedule: busSchedule,
              full: full,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/share/timetable/:code',
        builder: (context, state) {
          final code = state.pathParameters['code'];

          if (code == null) {
            context.go('/');
            return Container();
          }

          final isLoggedIn = getAuthStatus();
          if (!isLoggedIn) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/login', extra: {'timetableCode': code});
            });
            return CustomLoadingScreen();
          }

          return HomeScreen(
            isGuest: false,
            onThemeChanged: onThemeChanged,
            code: code,
          );
        },
      ),
      GoRoute(
        path: '/community',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const CommunityScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/announcements',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const AnnouncementScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      )
    ],
    errorBuilder: (context, state) => const ErrorScreen(),
  );
}
