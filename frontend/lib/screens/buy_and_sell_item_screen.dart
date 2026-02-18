import 'package:dashbaord/services/api_service.dart';
import 'package:dashbaord/utils/bold_text.dart';
import 'package:dashbaord/utils/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:dashbaord/models/buy_and_sell_model.dart';
import 'package:dashbaord/widgets/custom_carousel.dart';

class BuyAndSellItemScreen extends StatelessWidget {
  const BuyAndSellItemScreen({super.key, required this.id, required this.currentUserEmail});
  final String id;
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
                        BoldText(
                          text: item.itemName,
                          size: 24,
                          color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
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
                      ],
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
