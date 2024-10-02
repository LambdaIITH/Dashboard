import 'package:dashbaord/screens/lost_and_found_add_item_screen.dart';
import 'package:dashbaord/utils/custom_page_route.dart';
import 'package:dashbaord/utils/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:dashbaord/models/lost_and_found_model.dart';
import 'package:dashbaord/services/analytics_service.dart';
import 'package:dashbaord/utils/bold_text.dart';
import 'package:dashbaord/widgets/lost_found_item.dart';
import 'package:dashbaord/services/api_service.dart';

class LostAndFoundScreen extends StatefulWidget {
  const LostAndFoundScreen({super.key, required this.currentUserEmail});
  final String currentUserEmail;

  @override
  State<LostAndFoundScreen> createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen> {
  String _search = '';
  late final TextEditingController _searchController;
  final analyticsService = FirebaseAnalyticsService();

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
          currentUserEmail: widget.currentUserEmail,
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
    return WillPopScope(
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
                          Navigator.of(context)
                              .pop();
                        },
                        child: const Text('Cancel', 
                        style: TextStyle(color: Colors.red),),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            CustomPageRoute(
                              startPos: const Offset(0, 1),
                              child: LostAndFoundAddItemScreen(
                                currentUserEmail: widget.currentUserEmail,
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor:
                              Colors.green, 
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
        appBar: AppBar(
          title: BoldText(
            text: 'Lost and Found',
            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            size: 28,
          ),
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
                          Navigator.pop(context);
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
                          Navigator.pop(context);
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
                        SearchBar(
                          hintText: 'Search...',
                          controller: _searchController,
                          onSubmitted: (value) {
                            setState(() {
                              _search = _searchController.text;
                            });
                          },
                          trailing: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _search = _searchController.text;
                                });
                              },
                              icon: const Icon(Icons.search),
                            )
                          ],
                        ),
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
