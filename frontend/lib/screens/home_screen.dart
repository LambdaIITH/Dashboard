import 'package:flutter/material.dart';
import 'package:frontend/screens/cab_sharing_screen.dart';
import 'package:frontend/widgets/home_card_no_options.dart';
import 'package:frontend/widgets/home_card_two_options.dart';

class HomeScreen extends StatefulWidget {
  final String user;
  const HomeScreen({
    super.key,
    required this.user,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please login to use this feature'),
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcfcfc),
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
            HomeCardTwoOptions(
              title: 'Lost & Found',
              title1: 'I found',
              title2: 'I lost',
              image1: 'assets/icons/magnifying-icon.svg',
              image2: 'assets/icons/magnifying-icon.svg',
              onTap: [showError, showError],
            ),
            const SizedBox(height: 13),
            HomeCardTwoOptions(
              title: 'Mess Services',
              title1: 'Mess Swap',
              title2: 'Mess Rebate',
              image1: 'assets/icons/swap-icon.svg',
              image2: 'assets/icons/money-icon.png',
              onTap: [showError, showError],
            ),
            const SizedBox(height: 13),
            HomeCardNoOptions(
              title: 'Cab Sharing',
              image: 'assets/icons/cab-sharing-icon.svg',
              onTap: () {
                widget.user == 'guest'
                    ? showError()
                    : Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CabSharingScreen(),
                      ));
              },
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
