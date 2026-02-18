import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:dashbaord/constants/enums/buy_and_sell.dart';
import 'package:dashbaord/services/api_service.dart';

class BuySellAddBottomSheet extends StatefulWidget {
  final String currentUserEmail;

  const BuySellAddBottomSheet({
    super.key,
    required this.currentUserEmail,
  });

  @override
  State<BuySellAddBottomSheet> createState() => _BuySellAddBottomSheetState();
}

class _BuySellAddBottomSheetState extends State<BuySellAddBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  BuyOrSell _type = BuyOrSell.sell;
  String _condition = 'New';
  String _category = 'Electronics';
  List<File> _images = [];
  bool _isLoading = false;

  final List<String> _conditions = ['New', 'Like New', 'Good', 'Fair', 'Poor'];
  final List<String> _categories = [
    'Electronics',
    'Books',
    'Furniture',
    'Clothing',
    'Sports',
    'Other'
  ];

  @override
  void dispose() {
    _itemNameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_images.length >= 5) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 5 images allowed')),
        );
      }
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: const Color.fromARGB(204, 254, 115, 76),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _images.add(File(croppedFile.path));
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_images.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text('Images Required'),
            ],
          ),
          content: const Text('Please add at least one image to create a listing.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xffFE724C)),
              ),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final pickedFiles = _images.map((file) => PickedFile(file.path)).toList();

      final response = await ApiServices().addMarketplaceItem(
        itemName: _itemNameController.text.trim(),
        itemDescription: _descriptionController.text.trim(),
        sellingPrice: double.parse(_priceController.text.trim()),
        imagesWeb: [], // Empty for mobile
        images: pickedFiles,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response['status'] == 200) {
          Navigator.of(context).pop();

          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Listing created successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['error'] ?? 'Failed to create listing'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final borderColor = isDark ? Colors.grey[700] : Colors.grey[300];

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Listing',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: textColor),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
              Divider(color: borderColor),
              // Form
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Type selector
                        Text(
                          'Type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<BuyOrSell>(
                                title: Text(
                                  'Buying',
                                  style: TextStyle(color: textColor),
                                ),
                                value: BuyOrSell.buy,
                                groupValue: _type,
                                onChanged: (value) {
                                  setState(() {
                                    _type = value!;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                                activeColor: const Color(0xffFE724C),
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<BuyOrSell>(
                                title: Text(
                                  'Selling',
                                  style: TextStyle(color: textColor),
                                ),
                                value: BuyOrSell.sell,
                                groupValue: _type,
                                onChanged: (value) {
                                  setState(() {
                                    _type = value!;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                                activeColor: const Color(0xffFE724C),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Item name
                        TextFormField(
                          controller: _itemNameController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            labelText: 'Item Name',
                            labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xffFE724C),
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter item name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Price
                        TextFormField(
                          controller: _priceController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            labelText: 'Price (₹)',
                            labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xffFE724C),
                                width: 2,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter price';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Category
                        DropdownButtonFormField<String>(
                          value: _category,
                          dropdownColor: cardColor,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xffFE724C),
                                width: 2,
                              ),
                            ),
                          ),
                          items: _categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _category = newValue;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        // Condition
                        DropdownButtonFormField<String>(
                          value: _condition,
                          dropdownColor: cardColor,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            labelText: 'Condition',
                            labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xffFE724C),
                                width: 2,
                              ),
                            ),
                          ),
                          items: _conditions.map((String condition) {
                            return DropdownMenuItem<String>(
                              value: condition,
                              child: Text(condition),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _condition = newValue;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xffFE724C),
                                width: 2,
                              ),
                            ),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Images
                        Text(
                          'Images (Max 5)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_images.isEmpty)
                          OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(
                              Icons.add_photo_alternate,
                              color: Color(0xffFE724C),
                            ),
                            label: Text(
                              'Add Images',
                              style: TextStyle(color: textColor),
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              side: BorderSide(color: borderColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          )
                        else
                          Column(
                            children: [
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _images.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == _images.length) {
                                      return Container(
                                        width: 120,
                                        margin: const EdgeInsets.only(right: 8),
                                        child: OutlinedButton(
                                          onPressed: _pickImage,
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: borderColor),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Color(0xffFE724C),
                                          ),
                                        ),
                                      );
                                    }
                                    return Container(
                                      width: 120,
                                      margin: const EdgeInsets.only(right: 8),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.file(
                                              _images[index],
                                              fit: BoxFit.cover,
                                              width: 120,
                                              height: 120,
                                            ),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: GestureDetector(
                                              onTap: () => _removeImage(index),
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 24),
                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitListing,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffFE724C),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              disabledBackgroundColor: Colors.grey,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Create Listing',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
