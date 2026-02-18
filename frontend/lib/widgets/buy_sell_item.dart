import 'package:flutter/material.dart';
import 'package:dashbaord/models/buy_and_sell_model.dart';
import 'package:dashbaord/utils/normal_text.dart';
import 'package:dashbaord/widgets/custom_carousel.dart';
import 'package:go_router/go_router.dart';

class BuySellItem extends StatelessWidget {
  const BuySellItem({super.key, required this.item, required this.currentUserEmail});

  final BuyAndSellModel item;
  final String currentUserEmail;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/marketplace/${item.buyOrSell.name}/${item.id}', extra: {
        'currentUserEmail': currentUserEmail,
        'buyOrSell': item.buyOrSell,
      }),
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 250,
        ),
        width: 160,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomCarousel(
                images: item.images,
                fromMemory: false,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: NormalText(
                          text: item.itemName,
                          size: 16,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '₹${item.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2ECC71),
                          ),
                        ),
                      ),
                      if (item.condition != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: NormalText(
                            text: item.condition!,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
