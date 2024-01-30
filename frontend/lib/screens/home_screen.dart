import 'package:flutter/material.dart';
import 'package:frontend/widgets/home_card_no_options.dart';
import 'package:frontend/widgets/home_card_two_options.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildNavBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            ListTile(
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.low_priority),
              ),
              contentPadding: const EdgeInsets.all(0),
            ),
            const HomeCardNoOptions(
              title: 'Acad Navigation',
              image: 'assets/icons/acad-nav-icon.svg',
              onTap: null,
            ),
            const SizedBox(height: 13),
            const HomeCardTwoOptions(
              title: 'Lost & Found',
              title1: 'I found',
              title2: 'I lost',
              image1: 'assets/icons/magnifying-icon.svg',
              image2: 'assets/icons/magnifying-icon.svg',
              onTap: null,
            ),
            const SizedBox(height: 13),
            const HomeCardTwoOptions(
              title: 'Mess Services',
              title1: 'Mess Swap',
              title2: 'Mess Rebate',
              image2: 'assets/icons/money-icon.png',
              image1: 'assets/icons/swap-icon.svg',
              onTap: null,
            ),
            const SizedBox(height: 13),
            const HomeCardNoOptions(
              title: 'Cab Sharing',
              image: 'assets/icons/cab-sharing-icon.svg',
              onTap: null,
            ),
          ],
        ),
      ),
    );
  }

  AppBar buildNavBar() {
    return AppBar(
      title: const Text(
        "Home",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 40,
          shadows: [
            Shadow(
              offset: Offset(0, 1.5),
              color: Colors.black12,
            )
          ],
        ),
      ),
      leadingWidth: 65,
      leading: Builder(builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            icon: const Icon(Icons.menu, size: 40),
            onPressed: () {
              // Scaffold.of(context).openDrawer();
            },
          ),
        );
      }),
      actions: [
        Card(
          elevation: 2,
          color: const Color(0xb3FE724C),
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.search,
                  size: 37,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications,
                  size: 37,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
      ],
      toolbarHeight: kToolbarHeight + 20,
    );
  }
}
