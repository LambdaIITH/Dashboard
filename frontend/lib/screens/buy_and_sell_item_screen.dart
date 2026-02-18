import 'package:dashbaord/services/api_service.dart';
import 'package:dashbaord/utils/bold_text.dart';
import 'package:dashbaord/utils/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:dashbaord/constants/enums/buy_and_sell.dart';
import 'package:dashbaord/models/buy_and_sell_model.dart';
import 'package:dashbaord/utils/normal_text.dart';
import 'package:dashbaord/utils/show_message.dart';
import 'package:dashbaord/widgets/custom_carousel.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class BuyAndSellItemScreen extends StatelessWidget {
  const BuyAndSellItemScreen(
      {super.key, required this.id, required this.buyOrSell, required this.currentUserEmail});
  final String id;
  final BuyOrSell buyOrSell;
  final String? currentUserEmail;

  Future<BuyAndSellModel> getItem(BuildContext context) async {
    final Map<String, dynamic> data = await ApiServices().getMarketplaceItem(
      id: id,
      context: context,
    );

    if (data['status'] == 200) {
      return BuyAndSellModel.fromJson(data['item']);
    } else {
      throw Exception('Failed to load item');
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
          title: Text('Seller Information',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: $name',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                Text('Email: $email',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      context.pop();
                    },
                    child: Container(
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color.fromRGBO(254, 114, 76, 0.70),
                      ),
                      child: Text('Close',
                          style: GoogleFonts.inter(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color.fromRGBO(254, 114, 76, 0.70),
                      ),
                      child: Text('Connect',
                          style: GoogleFonts.inter(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
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

  void deleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Item',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      context.pop();
                    },
                    child: Container(
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey,
                      ),
                      child: Text('Cancel',
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final response = await ApiServices().deleteMarketplaceItem(
                        id: id,
                        context: context,
                      );

                      if (response['status'] == 200) {
                        context.pop();
                        context.go('/marketplace');
                        showMessage(
                          context: context,
                          msg: 'Item deleted successfully',
                        );
                      } else {
                        context.pop();
                        showMessage(
                          context: context,
                          msg: response['error'] ?? 'Failed to delete item',
                        );
                      }
                    },
                    child: Container(
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.red,
                      ),
                      child: Text('Delete',
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BoldText(
          text: 'Item Details',
          color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
          size: 28,
        ),
      ),
      body: FutureBuilder<BuyAndSellModel>(
        future: getItem(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomLoadingScreen());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading item'));
          }

          final item = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image carousel
                  Container(
                    height: 400,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(51, 51, 51, 0.10),
                          offset: Offset(0, 4),
                          blurRadius: 10.0,
                          spreadRadius: 0.0,
                        ),
                      ],
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: item.images.isNotEmpty
                        ? CustomCarousel(
                            images: item.images,
                            height: 400,
                            fromMemory: false,
                          )
                        : const Center(
                            child: Icon(Icons.image_not_supported, size: 100),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Item details card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(51, 51, 51, 0.10),
                          offset: Offset(0, 4),
                          blurRadius: 10.0,
                          spreadRadius: 0.0,
                        ),
                      ],
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: BoldText(
                                text: item.itemName,
                                size: 24,
                                color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                              ),
                            ),
                            if (item.userEmail == currentUserEmail)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteDialog(context),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '₹${item.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2ECC71),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (item.condition != null) ...[
                          Row(
                            children: [
                              const Icon(Icons.star, size: 20),
                              const SizedBox(width: 8),
                              NormalText(
                                text: 'Condition: ${item.condition}',
                                size: 16,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (item.category != null) ...[
                          Row(
                            children: [
                              const Icon(Icons.category, size: 20),
                              const SizedBox(width: 8),
                              NormalText(
                                text: 'Category: ${item.category}',
                                size: 16,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        const Divider(height: 32),
                        BoldText(
                          text: 'Description',
                          size: 20,
                          color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                        ),
                        const SizedBox(height: 12),
                        NormalText(
                          text: item.itemDescription ?? 'No description available',
                          size: 16,
                          limit: 50,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contact button
                  if (item.userEmail != currentUserEmail)
                    InkWell(
                      onTap: () {
                        profileDialog(
                          item.userName ?? 'Unknown',
                          item.userEmail ?? '',
                          context,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: const Color.fromRGBO(254, 114, 76, 0.70),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(51, 51, 51, 0.10),
                              offset: Offset(0, 8),
                              blurRadius: 21.0,
                              spreadRadius: 4.0,
                            ),
                          ],
                        ),
                        child: Text(
                          'Contact Seller',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
