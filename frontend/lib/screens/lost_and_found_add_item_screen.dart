import 'package:dashbaord/screens/lost_and_found_screen.dart';
import 'package:dashbaord/widgets/custom_carousel_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dashbaord/constants/enums/lost_and_found.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:dashbaord/utils/bold_text.dart';
import 'package:dashbaord/utils/normal_text.dart';
import 'package:dashbaord/utils/show_message.dart';
import 'package:dashbaord/widgets/custom_carousel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class LostAndFoundAddItemScreen extends StatefulWidget {
  const LostAndFoundAddItemScreen({super.key, required this.currentUserEmail});
  final String currentUserEmail;

  @override
  State<LostAndFoundAddItemScreen> createState() =>
      _LostAndFoundAddItemScreenState();
}

class _LostAndFoundAddItemScreenState extends State<LostAndFoundAddItemScreen> {
  late final TextEditingController _itemNameController;
  late final TextEditingController _itemDescriptionController;
  late final ImagePicker _imagePicker;

  LostOrFound? _lostOrFound;
  // final List<String> _images = [];
  final List<PickedFile> _images = [];
  final List<Uint8List> _imagesWeb = [];
  bool imagePicked = false;
  bool isLoading = false;

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

  // void pickImage(ImageSource source) async {

  // final image = await _imagePicker.pickImage(
  //   source: source,
  //   imageQuality: 50, // <- Reduce Image quality
  //   maxHeight: 500, // <- reduce the image size
  //   maxWidth: 500,
  // );
  // if (image == null) {
  //   return;
  // }
  // setState(() {
  //   _images.add(image.path);
  // });
  // }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      );
      if (croppedFile != null) {
        setState(() {
          imagePicked = true;
          _images.add(PickedFile(croppedFile.path));
        });
      }
    }
  }

  Future<void> pickImageWeb(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 40, // Optionally reduce the image quality
      maxWidth: 800, // Optionally set a max width for resizing
      maxHeight: 800, // Optionally set a max height for resizing
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      print(bytes);
      setState(() {
        _imagesWeb.add(bytes);
        imagePicked = true;
        // _images.add(PickedFile(pickedFile.path));
      });
    }
  }

  void showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  kIsWeb
                      ? pickImageWeb(ImageSource.camera)
                      : pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  kIsWeb
                      ? pickImageWeb(ImageSource.gallery)
                      : pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void createListing() async {
    if (_images.isEmpty && !imagePicked) {
      showMessage(
        msg: "Please add at least 1 image",
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

    setState(() {
      isLoading = true;
    });

    final response = await ApiServices().addLostAndFoundItem(
      itemName: _itemNameController.text,
      itemDescription: _itemDescriptionController.text,
      lostOrFound: _lostOrFound!,
      images: _images,
      imagesWeb: _imagesWeb,
    );

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 200) {
      showMessage(
        context: context,
        msg: "Item successfully added!",
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LostAndFoundScreen(
            currentUserEmail: widget.currentUserEmail,
          ),
        ),
        (route) => route.isFirst,
      );
    } else {
      showMessage(
        context: context,
        msg: response['error'].toString(),
      );
    }
  }

  updateButtonStatus() {
    return _itemDescriptionController.text.trim().isNotEmpty &&
        _itemNameController.text.trim().isNotEmpty &&
        (_images.isNotEmpty || imagePicked) &&
        _lostOrFound != null;
  }

  selectionWidget(bool isImageUploaded) {
    if (isImageUploaded) {
      return Column(
        children: [
          const SizedBox(
            height: 24,
          ),
          CustomCarouselWeb(
            imagesWeb: _imagesWeb,
            height: 350,
          ),
          const SizedBox(
            height: 24,
          ),
          Container(
            padding: const EdgeInsets.all(6),
            // margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
                color: const Color.fromARGB(204, 254, 115, 76).withOpacity(0.5),
                borderRadius: BorderRadius.circular(12)),
            child: IconButton(
                icon: const Icon(
                  Icons.add,
                ),
                onPressed: () {
                  showImageSourceDialog();
                }),
          ),
          const SizedBox(
            height: 24,
          ),
        ],
      );
    } else {
      return InkWell(
        onTap: () {
          showImageSourceDialog();
        },
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
                text: 'Make sure to add a minimum of 1 picture.',
                center: true,
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: BoldText(
          text: 'Listings',
          color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
          size: 28,
        ),
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
          child: Column(
            children: [
              kIsWeb
                  ? selectionWidget(imagePicked)
                  : _images.isNotEmpty
                      ? Stack(
                          children: [
                            CustomCarousel(
                              images: _images.map((file) => file.path).toList(),
                              height: 350,
                              fromMemory: true,
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(204, 254, 115, 76)
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    showImageSourceDialog();
                                  },
                                ),
                              ),
                            ),
                          ],
                        )
                      : InkWell(
                          onTap: () {
                            showImageSourceDialog();
                          },
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
                                      'Make sure to add a minimum of 1 picture.',
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
                    Container(
                      width: screenWidth * 0.4,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12)),
                      child: TextField(
                        onChanged: (v) {
                          setState(() {});
                        },
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(10),
                          filled: true,
                          fillColor: Colors.black12,
                          hintText: 'Title...',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                        controller: _itemNameController,
                      ),
                    ),
                    SizedBox(
                      width: screenWidth * 0.4,
                      child: DropdownButtonFormField(
                        hint: Text(
                          'Lost / Found',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(10),
                          filled: true,
                          fillColor: Colors.black12,
                          // hintText: 'Lost / Found',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _lostOrFound = value;
                          });
                        },
                        items: [
                          DropdownMenuItem(
                            value: LostOrFound.lost,
                            child: Text(
                              'Lost',
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color),
                            ),
                          ),
                          DropdownMenuItem(
                            value: LostOrFound.found,
                            child: Text(
                              'Found',
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  onChanged: (v) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    filled: true,
                    fillColor: Colors.black12,
                    hintText: 'Add more details about the item.',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                  controller: _itemDescriptionController,
                  minLines: 5,
                  maxLines: 10,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                alignment: Alignment.bottomCenter,
                margin: const EdgeInsets.only(bottom: 16),
                child: TextButton(
                  onPressed: !updateButtonStatus() || isLoading
                      ? null
                      : () {
                          createListing();
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: !updateButtonStatus() || isLoading
                          ? Colors.grey
                          : const Color.fromRGBO(254, 114, 76, 0.70),
                      boxShadow: const [
                        BoxShadow(
                          color:
                              Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
                          offset: Offset(0, 8), // Offset in the x, y direction
                          blurRadius: 21.0,
                          spreadRadius: 4.0,
                        ),
                      ],
                    ),
                    width: double.infinity,
                    height: 60,
                    alignment: Alignment.center,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Add Item',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
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
  }
}
