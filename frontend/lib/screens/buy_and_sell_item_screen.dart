import 'package:dashbaord/services/api_service.dart';
import 'package:dashbaord/utils/bold_text.dart';
import 'package:dashbaord/utils/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:dashbaord/models/buy_and_sell_model.dart';
import 'package:dashbaord/widgets/custom_carousel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

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

  String formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Interested in your item',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _showContactOptions(BuildContext context, BuyAndSellModel item) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Contact Seller',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              if (item.userEmail != null)
                ListTile(
                  leading: const Icon(Icons.email, color: Color(0xFFFE724C)),
                  title: const Text('Send Email'),
                  subtitle: Text(item.userEmail!),
                  onTap: () {
                    Navigator.pop(context);
                    _launchEmail(item.userEmail!);
                  },
                ),
              if (item.userPhoneNumber != null)
                ListTile(
                  leading: const Icon(Icons.phone, color: Color(0xFFFE724C)),
                  title: const Text('Call Phone'),
                  subtitle: Text(item.userPhoneNumber!),
                  onTap: () {
                    Navigator.pop(context);
                    _launchPhone(item.userPhoneNumber!);
                  },
                ),
              const SizedBox(height: 10),
            ],
          ),
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

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
                              if (item.description != null && item.description!.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).textTheme.bodyLarge?.color ??
                                        Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.description!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                                        Colors.grey,
                                  ),
                                ),
                              ],
                              if (item.createdAt != null) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 18, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Posted: ${formatDate(item.createdAt)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Seller info card
                        if (item.userName != null || item.userEmail != null)
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
                                Text(
                                  'Seller Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).textTheme.bodyLarge?.color ??
                                        Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (item.userName != null) ...[
                                  Row(
                                    children: [
                                      const Icon(Icons.person, size: 18, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(
                                        item.userName!,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                if (item.userEmail != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.email, size: 18, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item.userEmail!,
                                          style: const TextStyle(fontSize: 16),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                if (item.userPhoneNumber != null) ...[
                                  if (item.userEmail != null) const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, size: 18, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(
                                        item.userPhoneNumber!,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        const SizedBox(height: 80), // Space for floating button
                      ],
                    ),
                  ),
                ),
              ),
              // Contact button
              if ((item.userEmail != null || item.userPhoneNumber != null) &&
                  item.userEmail != currentUserEmail)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(51, 51, 51, 0.10),
                        offset: Offset(0, -4),
                        blurRadius: 10.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _showContactOptions(context, item),
                      icon: const Icon(Icons.contact_phone, color: Colors.white),
                      label: const Text(
                        'Contact Seller',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFE724C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
