import 'package:flutter/material.dart';
import 'package:frontend/models/lost_and_found_model.dart';
import 'package:frontend/utils/bold_text.dart';
import 'package:frontend/widgets/lost_found_add_item.dart';
import 'package:frontend/widgets/lost_found_item.dart';
import 'package:frontend/services/api_service.dart';

class LostAndFoundScreen extends StatefulWidget {
  const LostAndFoundScreen({super.key});

  @override
  State<LostAndFoundScreen> createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen> {
  String _search = '';
  late final TextEditingController _searchController;

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

  Future<List<Widget>> getItems() async {
    final Map<String, dynamic> data;
    if (_search.isEmpty) {
      data = await ApiServices().getLostAndFoundItems();
    } else {
      data = await ApiServices().searchLostAndFoundItems(_search);
    }
    List<Widget> finalItems = [const LostFoundAddItem()];
    if (data['status'] == 200) {
      final items = data['items'] as List<dynamic>;
      finalItems.addAll(items.map((item) {
        return LostFoundItem(
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
    _searchController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BoldText(
          text: 'Lost and Found',
          color: Colors.black,
          size: 28,
        ),
      ),
      body: FutureBuilder(
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
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
