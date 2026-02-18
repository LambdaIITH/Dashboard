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
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

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
  bool isTabOneSelected = true; // true = All Items, false = My Listings
  Timer? _debounce;

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
    if (isTabOneSelected) {
      getItems();
    } else {
      getMyItems();
    }
  }

  bool isLoading = true;
  late UserModel user;
  List<Widget> allItems = [];
  List<Widget> myItems = [];

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
    }
    setState(() {
      allItems = finalItems;
    });
    return finalItems;
  }

  Future<List<Widget>> getMyItems() async {
    final Map<String, dynamic> data = await ApiServices().getMyMarketplaceItems(context);

    List<Widget> finalItems = [];
    if (data['status'] == 200) {
      final items = data['items'] as List<dynamic>;
      finalItems.addAll(items.map((item) {
        return BuySellItem(
          currentUserEmail: user.email,
          item: BuyAndSellModel.fromJson(item),
          showDeleteButton: true,
          onDeleted: () {
            // Refresh the list after deletion
            getMyItems();
          },
        ) as Widget;
      }));
    }
    setState(() {
      myItems = finalItems;
    });
    return finalItems;
  }

  @override
  void initState() {
    analyticsService.logScreenView(screenName: "Buy And Sell Screen");
    _searchController = TextEditingController();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestNotifPerms(context);
      getItems();
      getMyItems();
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
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    final List<Widget> tabNames = [
      Text(
        'All Items',
        style: GoogleFonts.inter(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      Text(
        'My Listings',
        style: GoogleFonts.inter(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    ];

    Widget buildItemsGrid(List<Widget> items, {bool showSearch = true}) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSearch) ...[
              CustomSearchBar(
                controller: _searchController,
                onSearch: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    setState(() {
                      _search = value;
                    });
                    getItems();
                  });
                },
              ),
              const SizedBox(height: 20),
            ],
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
    }

    Widget allItemsTab = RefreshIndicator(
      onRefresh: () async {
        await getItems();
      },
      child: FutureBuilder(
        future: allItems.isEmpty ? getItems() : Future.value(allItems),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && allItems.isEmpty) {
            return const Center(child: CustomLoadingScreen());
          }
          return buildItemsGrid(allItems);
        },
      ),
    );

    Widget myListingsTab = RefreshIndicator(
      onRefresh: () async {
        await getMyItems();
      },
      child: FutureBuilder(
        future: myItems.isEmpty ? getMyItems() : Future.value(myItems),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && myItems.isEmpty) {
            return const Center(child: CustomLoadingScreen());
          }
          return buildItemsGrid(myItems, showSearch: false);
        },
      ),
    );

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
                onPressed: () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => BuySellAddBottomSheet(
                      currentUserEmail: user.email,
                    ),
                  );
                  // Reload items after bottom sheet closes
                  getItems();
                  getMyItems();
                },
              ),
              appBar: CustomAppBar(
                title: 'Marketplace',
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                if (!isTabOneSelected) {
                                  setState(() {
                                    isTabOneSelected = true;
                                  });
                                  getItems();
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isTabOneSelected
                                      ? const Color(0xffFE724C)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                alignment: Alignment.center,
                                child: tabNames[0],
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                if (isTabOneSelected) {
                                  setState(() {
                                    isTabOneSelected = false;
                                  });
                                  getMyItems();
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !isTabOneSelected
                                      ? const Color(0xffFE724C)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                alignment: Alignment.center,
                                child: tabNames[1],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: isTabOneSelected ? allItemsTab : myListingsTab,
                  ),
                ],
              ),
            ),
          );
  }
}
