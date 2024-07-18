import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/constants/enums/lost_and_found.dart';
import 'package:frontend/models/lost_and_found_model.dart';
import 'package:frontend/screens/lost_and_found_edit_item_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/utils/bold_text.dart';
import 'package:frontend/utils/normal_text.dart';
import 'package:frontend/utils/show_message.dart';
import 'package:frontend/widgets/custom_carousel.dart';

class LostAndFoundItemScreen extends StatelessWidget {
  const LostAndFoundItemScreen({
    super.key,
    required this.id,
    required this.lostOrFound,
  });
  final String id;
  final LostOrFound lostOrFound;

  void deleteItem(BuildContext context, LostAndFoundModel item) async {
    final response = await ApiServices().deleteLostAndFoundItem(
      id: item.id,
      lostOrFound: item.lostOrFound,
    );

    if (response['status'] == 200) {
      showMessage(
        context: context,
        msg: "Item Deleted Successfully",
      );
    } else {
      debugPrint(response['error']);
      showMessage(
        context: context,
        msg: "Item couldn't be deleted. Something went wrong",
      );
    }
  }

  Future<LostAndFoundModel> getItem(BuildContext context) async {
    final data = await ApiServices().getLostAndFoundItem(
      id: id,
      lostOrFound: lostOrFound,
    );
    debugPrint(data.toString());
    if (data['status'] == 200) {
      debugPrint(data['item']['image_urls'].runtimeType.toString());
      return LostAndFoundModel(
        id: data['item']['id'].toString(),
        itemName: data['item']['item_name'],
        itemDescription: data['item']['item_description'],
        images: (data['item']['image_urls'] as List)
            .map(
              (e) => e.toString(),
            )
            .toList(),
        lostOrFound: data['item']['lostOrFound'],
      );
    } else {
      showMessage(
        context: context,
        msg: 'Something went wrong: ${data['error']}',
      );
      Navigator.of(context).pop();
      return LostAndFoundModel(
          id: id,
          lostOrFound: lostOrFound,
          itemName: '',
          images: [],
          itemDescription: '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: getItem(context),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final item = snapshot.data!;
            debugPrint(snapshot.hasData.toString());
            // final item = LostAndFoundModel(
            //     id: id,
            // // lostOrFound: lostOrFound,
            // // itemName: '',
            // // images: [],
            // itemDescription: '');
            return Scaffold(
              appBar: AppBar(
                title: const BoldText(
                  text: 'Listings',
                  color: Colors.black,
                  size: 28,
                ),
                actions: [
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 1,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => LostAndFoundEditItemScreen(
                                id: id,
                                lostOrFound: lostOrFound,
                                itemName: item.itemName,
                                itemDescription: item.itemDescription!,
                              ),
                            ));
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Edit")
                            ],
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: InkWell(
                          onTap: () {
                            deleteItem(context, item);
                            Navigator.of(context).pop();
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.delete),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Delete")
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
                        offset: Offset(0, 4), // Offset in the x, y direction
                        blurRadius: 10.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: ListView(
                    children: [
                      CustomCarousel(
                        images: item.images,
                        height: 350,
                        fromMemory: false,
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: min(300, screenWidth * 0.35),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: NormalText(
                                text: item.itemName,
                                size: 18,
                              ),
                            ),
                            Container(
                              width: min(300, screenWidth * 0.35),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: NormalText(
                                text: lostOrFound == LostOrFound.lost
                                    ? 'Lost'
                                    : 'Found',
                                size: 18,
                                color: const Color(0xB2FE724C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          height: 200,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: NormalText(text: item.itemDescription!),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: max(screenWidth * 0.28, 20),
                        ),
                        title: FilledButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            backgroundColor: WidgetStateColor.resolveWith(
                              (_) => const Color(0xB2FE724C),
                            ),
                          ),
                          child: const Text('Contact'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
