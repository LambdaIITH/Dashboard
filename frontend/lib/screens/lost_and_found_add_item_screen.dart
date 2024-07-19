import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dashbaord/constants/enums/lost_and_found.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:dashbaord/utils/bold_text.dart';
import 'package:dashbaord/utils/normal_text.dart';
import 'package:dashbaord/utils/show_message.dart';
import 'package:dashbaord/widgets/custom_carousel.dart';
import 'package:image_picker/image_picker.dart';

class LostAndFoundAddItemScreen extends StatefulWidget {
  const LostAndFoundAddItemScreen({super.key});

  @override
  State<LostAndFoundAddItemScreen> createState() =>
      _LostAndFoundAddItemScreenState();
}

class _LostAndFoundAddItemScreenState extends State<LostAndFoundAddItemScreen> {
  late final TextEditingController _itemNameController;
  late final TextEditingController _itemDescriptionController;
  late final ImagePicker _imagePicker;

  LostOrFound? _lostOrFound;
  final List<String> _images = [];

  @override
  void initState() {
    _itemDescriptionController = TextEditingController();
    _itemNameController = TextEditingController();
    _imagePicker = ImagePicker();
    super.initState();
  }

  @override
  void dispose() {
    _itemDescriptionController.dispose();
    _itemNameController.dispose();
    super.dispose();
  }

  void pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50, // <- Reduce Image quality
      maxHeight: 500, // <- reduce the image size
      maxWidth: 500,
    );
    if (image == null) {
      return;
    }
    setState(() {
      _images.add(image.path);
    });
  }

  void createListing() async {
    if (_images.isEmpty) {
      showMessage(
        msg: "Images cannot be empty",
        context: context,
      );
      return;
    }

    if (_lostOrFound == null) {
      showMessage(
        msg: "Lost / Found cannot be empty",
        context: context,
      );
      return;
    }
    if (_itemNameController.text.isEmpty) {
      showMessage(
        msg: "Title cannot be empty",
        context: context,
      );
      return;
    }
    if (_itemDescriptionController.text.isEmpty) {
      showMessage(
        msg: "Description cannot be empty",
        context: context,
      );
      return;
    }

    final response = await ApiServices().addLostAndFoundItem(
      itemName: _itemNameController.text,
      itemDescription: _itemDescriptionController.text,
      lostOrFound: _lostOrFound!,
      images: _images,
    );

    if (response['status'] == 200) {
      showMessage(
        context: context,
        msg: "Successfully item added!",
      );
      Navigator.of(context).pop();
    } else {
      showMessage(
        context: context,
        msg: response['error'].toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const BoldText(
          text: 'Listings',
          color: Colors.black,
          size: 28,
        ),
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
              _images.isNotEmpty
                  ? Stack(
                      children: [
                        CustomCarousel(
                          images: _images,
                          height: 350,
                          fromMemory: true,
                        ),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: CircleAvatar(
                            backgroundColor: Colors.black12,
                            child: IconButton(
                              icon: const Icon(
                                Icons.add,
                              ),
                              onPressed: pickImage,
                            ),
                          ),
                        )
                      ],
                    )
                  : InkWell(
                      onTap: pickImage,
                      child: Container(
                        height: 350,
                        padding: const EdgeInsets.all(25),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            NormalText(
                              text: 'Upload images.',
                              center: true,
                            ),
                            Icon(
                              Icons.add,
                              size: 80,
                            ),
                            NormalText(
                              text:
                                  'Make sure to add a minimum of 3 pictures from differet angles for best results.',
                              center: true,
                            ),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: min(200, screenWidth * 0.35),
                      child: TextField(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          filled: true,
                          fillColor: Colors.black12,
                          hintText: 'Title...',
                        ),
                        controller: _itemNameController,
                      ),
                    ),
                    SizedBox(
                      width: min(200, screenWidth * 0.35),
                      child: DropdownButtonFormField(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          filled: true,
                          fillColor: Colors.black12,
                          hintText: 'Lost / Found',
                        ),
                        onChanged: (value) {
                          _lostOrFound = value;
                        },
                        items: const [
                          DropdownMenuItem(
                            value: LostOrFound.lost,
                            child: Text('Lost'),
                          ),
                          DropdownMenuItem(
                            value: LostOrFound.found,
                            child: Text('Found'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    filled: true,
                    fillColor: Colors.black12,
                    hintText: 'Add Details...',
                  ),
                  controller: _itemDescriptionController,
                  minLines: 5,
                  maxLines: 10,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: screenWidth * 0.3),
                title: FilledButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateColor.resolveWith(
                        (_) => const Color(0xB2FE724C)),
                  ),
                  onPressed: createListing,
                  child: const Text('Post'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
