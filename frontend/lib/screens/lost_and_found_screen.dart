import 'package:dashbaord/models/user_model.dart';
import 'package:dashbaord/services/shared_service.dart';
import 'package:dashbaord/utils/loading_widget.dart';
import 'package:dashbaord/widgets/custom_appbar.dart';
import 'package:dashbaord/widgets/custom_search_bar.dart';
import 'package:dashbaord/widgets/notif_perm.dart';
import 'package:flutter/material.dart';
import 'package:dashbaord/models/lost_and_found_model.dart';
import 'package:dashbaord/services/analytics_service.dart';
import 'package:dashbaord/widgets/lost_found_item.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class LostAndFoundScreen extends StatefulWidget {
  const LostAndFoundScreen({super.key, required this.currentUserEmail});
  final String? currentUserEmail;

  @override
  State<LostAndFoundScreen> createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen> {
  String _search = '';
  late final TextEditingController _searchController;
  final analyticsService = FirebaseAnalyticsService();

  void requestNotifPerms(BuildContext bc) async {
    PermissionStatus status = await Permission.notification.status;
    if (status.isGranted) {
      return;
    }

    DateTime now = DateTime.now();
    String? lastDate = await SharedService().getLastPermsRequestDate();

    bool shouldAsk = false;

    if (lastDate != null) {
      DateTime lastDateParsed = DateFormat('dd-MM-yyyy').parse(lastDate.trim());
      Duration difference = now.difference(lastDateParsed);
      if (difference.inDays >= 1) {
        //TODO: change if it is annoying
        shouldAsk = true;
      }
    } else {
      shouldAsk = true;
    }

    if (shouldAsk) {
      _showNotificationPermissionSheet(context);
      SharedService().saveLastPermsRequestDate(
          date: DateFormat("dd-MM-yyyy").format(now).trim());
    }
  }

  void _showNotificationPermissionSheet(BuildContext context) {
    showModalBottomSheet(
      isDismissible: false,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const NotificationPermissionRequestBottomSheet();
      },
    );
  }

  double getAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 450) {
      return 0.85;
    } else if (screenWidth > 400) {
      return 0.75;
    } else if (screenWidth <= 400 && screenWidth > 370) {
      return 0.65;
    } else if (screenWidth > 350) {
      return 0.6;
    } else {
      return 0.6;
    }
  }

  void onRefresh() {
    getItems();
  }

  bool isLoading = true;
  late UserModel user;

  Future<void> fetchUser() async {
    final response = await ApiServices().getUserDetails(context);
    if (response == null) {
      context.go('/login');
      return;
    }
    setState(() {
      user = response;
      isLoading = false;
    });
  }

  Future<List<Widget>> getItems() async {
    final Map<String, dynamic> data;
    if (_search.isEmpty) {
      if (onlyLost) {
        data = await ApiServices().getLostItems(context);
      } else if (onlyFound) {
        data = await ApiServices().getFoundItems(context);
      } else {
        data = await ApiServices().getLostAndFoundItems(context);
      }
    } else {
      data = await ApiServices().searchLostAndFoundItems(_search, context);
    }
    List<Widget> finalItems = [];
    if (data['status'] == 200) {
      final items = data['items'] as List<dynamic>;
      finalItems.addAll(items.map((item) {
        return LostFoundItem(
          currentUserEmail: user.email,
          item: LostAndFoundModel.fromJson(item),
        ) as Widget;
      }));
      return finalItems;
    } else {
      return finalItems;
    }
  }

  @override
  void initState() {
    analyticsService.logScreenView(screenName: "Lost And Found Screen");
    _searchController = TextEditingController();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestNotifPerms(context);
    });

    if (widget.currentUserEmail != null) {
      user = UserModel(email: widget.currentUserEmail!, name: 'User');
      isLoading = false;
    } else {
      fetchUser();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_search.isNotEmpty) {
      setState(() {
        _search = '';
        _searchController.clear();
      });
      return false; // Don't pop the route
    }
    return true; // Pop the route
  }

  bool onlyLost = false;
  bool onlyFound = false;

  void getOnlyLostItems() {
    setState(() {
      onlyLost = !onlyLost;
      if (onlyLost) {
        onlyFound = false;
      }
    });
    getItems();
  }

  void getOnlyFoundItems() {
    setState(() {
      onlyFound = !onlyFound;
      if (onlyFound) {
        onlyLost = false;
      }
    });
    getItems();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CustomLoadingScreen()
        : WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floatingActionButton: FloatingActionButton(
                backgroundColor: const Color.fromARGB(204, 254, 115, 76),
                child: const Icon(
                  Icons.add,
                  size: 30.0,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Alert'),
                        content: const Text(
                          'Please delete the item once everything is sorted. If not, it will be removed automatically after 28 days.',
                        ),
                        actions: [
                          SizedBox(
                            width: 100,
                            height: 40,
                            child: TextButton(
                              onPressed: () {
                                // Navigator.of(context)
                                //     .pop();
                                context.pop();
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            height: 40,
                            child: TextButton(
                              onPressed: () {
                                // Navigator.of(context).pop();
                                // Navigator.push(
                                //   context,
                                //   CustomPageRoute(
                                //     startPos: const Offset(0, 1),
                                //     child: LostAndFoundAddItemScreen(
                                //       currentUserEmail: widget.currentUserEmail,
                                //     ),
                                //   ),
                                // );
                                context.pop();
                                context.push('/lnf/add', extra: {
                                  'currentUserEmail': user.email,
                                });
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text(
                                'Agree',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              appBar: CustomAppBar(
                title: 'Lost and Found',
                actions: [
                  PopupMenuButton<int>(
                    onSelected: (value) {
                      if (value == 1) {
                        getOnlyLostItems();
                      } else if (value == 2) {
                        getOnlyFoundItems();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            Checkbox(
                              value: onlyLost,
                              onChanged: (value) {
                                // Navigator.pop(context);
                                context.pop();
                                getOnlyLostItems();
                              },
                            ),
                            const Text('Only Lost Items'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Row(
                          children: [
                            Checkbox(
                              value: onlyFound,
                              onChanged: (value) {
                                // Navigator.pop(context);
                                context.pop();
                                getOnlyFoundItems();
                              },
                            ),
                            const Text('Only Found Items'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: () {
                  return Future.delayed(
                    const Duration(seconds: 1),
                    () {
                      getItems();
                    },
                  );
                },
                child: FutureBuilder(
                  future: getItems(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.done:
                        final items = snapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomSearchBar(),
                              // SearchBar(
                              //   hintText: 'Search...',
                              //   controller: _searchController,
                              //   onSubmitted: (value) {
                              //     setState(() {
                              //       _search = _searchController.text;
                              //     });
                              //   },
                              //   trailing: [
                              //     IconButton(
                              //       onPressed: () {
                              //         setState(() {
                              //           _search = _searchController.text;
                              //         });
                              //       },
                              //       icon: const Icon(Icons.search),
                              //     )
                              //   ],
                              // ),
                              const SizedBox(
                                height: 20,
                              ),
                              Expanded(
                                child: GridView.count(
                                  shrinkWrap: true,
                                  crossAxisCount: 2,
                                  childAspectRatio: getAspectRatio(context),
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  children: items,
                                ),
                              ),
                            ],
                          ),
                        );
                      default:
                        return const Center(child: CustomLoadingScreen());
                    }
                  },
                ),
              ),
            ),
          );
  }
}
