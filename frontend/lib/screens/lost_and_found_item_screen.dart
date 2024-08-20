import 'dart:math';

import 'package:dashbaord/screens/lost_and_found_screen.dart';
import 'package:dashbaord/utils/bold_text.dart';
import 'package:dashbaord/utils/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:dashbaord/constants/enums/lost_and_found.dart';
import 'package:dashbaord/models/lost_and_found_model.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:dashbaord/utils/normal_text.dart';
import 'package:dashbaord/utils/show_message.dart';
import 'package:dashbaord/widgets/custom_carousel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class LostAndFoundItemScreen extends StatelessWidget {
  const LostAndFoundItemScreen(
      {super.key,
      required this.id,
      required this.lostOrFound,
      required this.currentUserEmail});
  final String id;
  final LostOrFound lostOrFound;
  final String currentUserEmail;

  Future<LostAndFoundModel> getItem(BuildContext context) async {
    final data = await ApiServices().getLostAndFoundItem(
      id: id,
      lostOrFound: lostOrFound,
      context: context
    );
    debugPrint(data.toString());
    if (data['status'] == 200) {
      debugPrint(data['item']['image_urls'].runtimeType.toString());
      return LostAndFoundModel(
        userEmail: data['item']['user_email'],
        userName: data['item']['username'],
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
          userEmail: '',
          userName: '',
          id: id,
          lostOrFound: lostOrFound,
          itemName: '',
          images: [],
          itemDescription: '');
    }
  }

  Future<void> openURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  void profileDialog(String name, String email, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Creator of this item',
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: $name',
                    style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                Text('Email: $email',
                    style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color.fromRGBO(254, 114, 76, 0.70),
                      ),
                      // onPressed: () => Navigator.of(context).pop(),
                      child: Text('Close',
                          style: GoogleFonts.inter(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      openURL('mailto:$email');
                    },
                    child: Container(
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color.fromRGBO(254, 114, 76, 0.70),
                      ),
                      // onPressed: () => Navigator.of(context).pop(),
                      child: Text('Connect',
                          style: GoogleFonts.inter(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  showConfirmationDialog(
      BuildContext context, String title, String button, Function onTap) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Confirmation',
              style:
                  GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.w600),
            ),
            content: Text(
              title,
              style:
                  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            actions: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color.fromRGBO(254, 114, 76, 0.70),
                        ),
                        child: Text('No',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        await onTap();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LostAndFoundScreen(
                              currentUserEmail: currentUserEmail,
                            ),
                          ),
                          (route) => route.isFirst,
                        );
                      },
                      child: Container(
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xffdc2828),
                        ),
                        child: Text(button,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    void deleteItem() async {
      final response = await ApiServices().deleteLostAndFoundItem(
        id: id,
        lostOrFound: lostOrFound,
        context: context
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
                title: BoldText(
                  text: item.itemName,
                  // text: lostOrFound == LostOrFound.lost
                  //     ? 'Lost Item'
                  //     : 'Found Item',
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.black,
                  size: 28,
                ),
                actions: [
                  if (item.userEmail == currentUserEmail)
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        // PopupMenuItem(
                        //   value: 1,
                        //   child: InkWell(
                        //     onTap: () {
                        //       Navigator.of(context).pop();
                        //       Navigator.of(context).push(MaterialPageRoute(
                        //         builder: (context) =>
                        //             LostAndFoundEditItemScreen(
                        //           id: id,
                        //           lostOrFound: lostOrFound,
                        //           itemName: item.itemName,
                        //           itemDescription: item.itemDescription!,
                        //         ),
                        //       ));
                        //     },
                        //     child: const Row(
                        //       children: [
                        //         Icon(Icons.edit),
                        //         SizedBox(
                        //           width: 10,
                        //         ),
                        //         Text("Edit")
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        PopupMenuItem(
                          value: 2,
                          child: InkWell(
                            onTap: () {
                              showConfirmationDialog(
                                  context,
                                  'Are you sure you want to delete this item?',
                                  'Yes',
                                  deleteItem);
                              // deleteItem(context, item);
                              // Navigator.of(context).pop();
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
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
                        offset: Offset(0, 4), // Offset in the x, y direction
                        blurRadius: 10.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
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
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
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
                          child: NormalText(
                            text: item.itemDescription!,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: max(screenWidth * 0.28, 20),
                        ),
                        title: InkWell(
                          onTap: () {
                            profileDialog(item.userName ?? '',
                                item.userEmail ?? '', context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xB2FE724C),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: FittedBox(
                                child: Text(
                                  'CONTACT',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          default:
            return const CustomLoadingScreen();
        }
      },
    );
  }
}
