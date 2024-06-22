import 'package:flutter/material.dart';
import 'package:frontend/screens/cab_sharing_screen.dart';
import 'package:frontend/screens/lost_and_found_screen.dart';
import 'package:frontend/screens/time_table_screen.dart';
import 'package:frontend/widgets/home_card_no_options.dart';
import 'package:frontend/widgets/home_card_two_options.dart';
import 'package:frontend/widgets/home_screen_appbar.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

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
      key: _scaffoldKey,
      backgroundColor: const Color(0xfffcfcfc),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            const HomeScreenAppBar(),
            const SizedBox(height: 20),
            HomeCardNoOptions(
              title: 'Time Table',
              image: 'assets/icons/calendar.svg',
              onTap: () {
                widget.user == 'guest'
                    ? showError()
                    : Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const TimeTableScreen(),
                      ));
              },
            ),
            const SizedBox(height: 20),
            HomeCardTwoOptions(
              title: 'Lost & Found',
              title1: 'I found',
              title2: 'I lost',
              image1: 'assets/icons/magnifying-icon.svg',
              image2: 'assets/icons/magnifying-icon.svg',
              onTap: [
                widget.user == 'guest'
                    ? showError
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LostAndFoundScreen(),
                          ),
                        ),
                showError
              ],
            ),
            const SizedBox(height: 20),
            HomeCardNoOptions(
              title: 'Cab Sharing',
              image: 'assets/icons/cab-sharing-icon.svg',
              onTap: () {
                widget.user == 'guest'
                    ? showError()
                    : Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const CabSharingScreen(),
                      ));
              },
            ),
            const SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}
