import 'package:dashbaord/models/user_model.dart';
import 'package:dashbaord/services/shared_service.dart';
import 'package:dashbaord/utils/loading_widget.dart';
import 'package:dashbaord/widgets/custom_appbar.dart';
import 'package:dashbaord/widgets/custom_search_bar.dart';
import 'package:dashbaord/widgets/notif_perm.dart';
import 'package:dashbaord/widgets/buy_sell_add_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:dashbaord/models/buy_and_sell_model.dart';
import 'package:dashbaord/services/analytics_service.dart';
import 'package:dashbaord/widgets/buy_sell_item.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class BuyAndSellScreen extends StatefulWidget {
  const BuyAndSellScreen({super.key, required this.currentUserEmail});
  final String? currentUserEmail;

  @override
  State<BuyAndSellScreen> createState() => _BuyAndSellScreenState();
}

class _BuyAndSellScreenState extends State<BuyAndSellScreen> {
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
        shouldAsk = true;
      }
    } else {
      shouldAsk = true;
    }

    if (shouldAsk) {
      _showNotificationPermissionSheet(context);
      SharedService().saveLastPermsRequestDate(date: DateFormat("dd-MM-yyyy").format(now).trim());
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
      data = await ApiServices().getMarketplaceItems(context);
    } else {
      data = await ApiServices().searchMarketplaceItems(_search, context);
    }

    List<Widget> finalItems = [];
    if (data['status'] == 200) {
      final items = data['items'] as List<dynamic>;
      finalItems.addAll(items.map((item) {
        return BuySellItem(
          currentUserEmail: user.email,
          item: BuyAndSellModel.fromJson(item),
        ) as Widget;
      }));
      return finalItems;
    } else {
      return finalItems;
    }
  }

  @override
  void initState() {
    analyticsService.logScreenView(screenName: "Buy And Sell Screen");
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
      return false;
    }
    return true;
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
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => BuySellAddBottomSheet(
                      currentUserEmail: user.email,
                    ),
                  );
                },
              ),
              appBar: CustomAppBar(
                title: 'Marketplace',
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
                              const SizedBox(
                                height: 20,
                              ),
                              Expanded(
                                child: items.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No items found',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      )
                                    : GridView.count(
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
