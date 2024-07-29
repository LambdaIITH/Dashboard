import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dashbaord/models/user_model.dart';
import 'package:dashbaord/screens/login_screen.dart';
import 'package:dashbaord/services/analytics_service.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  final String image;
  final ValueChanged<int> onThemeChanged;
  const ProfileScreen(
      {super.key,
      required this.user,
      required this.image,
      required this.onThemeChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final analyticsService = FirebaseAnalyticsService();

  @override
  void initState() {
    super.initState();
    getThemeMode();
    analyticsService.logScreenView(screenName: "Profile Screen");
  }

  int? _mode;

  getThemeMode() async {
    const String themeKey = 'is_dark';
    final prefs = await SharedPreferences.getInstance();
    int? mode = prefs.getInt(themeKey);
    setState(() {
      _mode = mode;
    });
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to log out?',
                  style: GoogleFonts.inter(fontSize: 16),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No',
                style: GoogleFonts.inter(fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Yes',
                style: GoogleFonts.inter(fontSize: 16),
              ),
              onPressed: () {
                analyticsService.logEvent(name: "Logout");
                Navigator.of(context).pop();
                logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You have been logged out successfully.'),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => LoginScreen(
                  onThemeChanged: widget.onThemeChanged,
                  timeDilation: 1,
                )),
        (Route<dynamic> route) => false,
      );
    }
    await ApiServices().serverLogout();
  }

  Future<void> openURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.inter(),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.fixed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void updatePhoneNumber(String newPhoneNumber) {
    setState(() {
      widget.user.phone = newPhoneNumber;
      showMessage("Your phone number has been successfully updated");
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Profile',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: textColor,
            )),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            // color: textColor,
            size: 30.0,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 80,
                  // replaces google image with size parameter changed to improve image resolution
                  backgroundImage: CachedNetworkImageProvider(
                      widget.image.replaceFirst(RegExp(r'=s\d+'), '=s240')),
                ),
                const SizedBox(height: 15),
                Text(
                  widget.user.name,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.user.getRollNumber(),
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    // color: Colors.black45,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 20),
                ProfileButton(
                  buttonName: 'Theme',
                  iconName: Icons.light_mode,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return ThemeBottomSheet(
                          changeState: (value) {
                            setState(() {
                              _mode = value;
                            });
                          },
                          current: _mode ?? 0,
                          onThemeChanged: widget.onThemeChanged,
                        );
                      },
                    );
                  },
                ),
                ProfileButton(
                  buttonName: "Edit Phone Number",
                  iconName: Icons.edit_rounded,
                  onPressed: () {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (ctx) => EditPhoneNumber(
                            user: widget.user,
                            onUpdate: (newPhoneNumber) {
                              updatePhoneNumber(newPhoneNumber);
                            }));
                  },
                ),
                ProfileButton(
                  buttonName: 'Feedback',
                  iconName: Icons.feedback_rounded,
                  onPressed: () {
                    openURL('https://iith-dashboard.feedbase.app');
                  },
                ),
                ProfileButton(
                  buttonName: 'Logout',
                  iconName: Icons.logout_rounded,
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                ),
                const SizedBox(height: 45),
              ],
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            margin: const EdgeInsets.only(bottom: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    await openURL('https://iith.dev');
                  },
                  onDoubleTap: () async {
                    await openURL("https://github.com/LambdaIITH/Dashboard");
                  },
                  onLongPress: () async {
                    await openURL("mailto:support@iith.dev");
                  },
                  child: Text(
                    'Made with 💜 by Lambda',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (BuildContext context,
                      AsyncSnapshot<PackageInfo> snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!.version,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      );
                    } else {
                      return const Text('Debug App');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ThemeBottomSheet extends StatefulWidget {
  final int current;
  final ValueChanged<int> onThemeChanged;
  final ValueChanged<int> changeState;
  const ThemeBottomSheet(
      {super.key,
      this.current = 0,
      required this.onThemeChanged,
      required this.changeState});
  @override
  _ThemeBottomSheetState createState() => _ThemeBottomSheetState();
}

class _ThemeBottomSheetState extends State<ThemeBottomSheet> {
  int _selectedTheme = 0; // 0: System, 1: Light, 2: Dark

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.current;
  }

  void _handleThemeChange(int? value) {
    setState(() {
      _selectedTheme = value!;
    });
    widget.onThemeChanged(value ?? 0);
    widget.changeState(value ?? 0);
    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Theme',
            style: GoogleFonts.inter(
                color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          RadioListTile<int>(
            title: const Text('System Default'),
            value: 0,
            groupValue: _selectedTheme,
            onChanged: _handleThemeChange,
          ),
          RadioListTile<int>(
            title: const Text('Light'),
            value: 1,
            groupValue: _selectedTheme,
            onChanged: _handleThemeChange,
          ),
          RadioListTile<int>(
            title: const Text('Dark'),
            value: 2,
            groupValue: _selectedTheme,
            onChanged: _handleThemeChange,
          ),
        ],
      ),
    );
  }
}

class EditPhoneNumber extends StatefulWidget {
  final UserModel user;
  final Function(String) onUpdate;
  const EditPhoneNumber({
    super.key,
    required this.user,
    required this.onUpdate,
  });

  @override
  State<EditPhoneNumber> createState() => _EditPhoneNumberState();
}

class _EditPhoneNumberState extends State<EditPhoneNumber> {
  bool buttonStatus = false;
  TextEditingController phoneController = TextEditingController();

  bool updateButtonStatus() {
    if (widget.user.phone != null &&
        phoneController.text.trim() ==
            widget.user.phone!.replaceAll(RegExp(r'\+91'), '')) {
      return false;
    }
    return isValidIndianPhoneNumber(phoneController.text.trim());
  }

  bool isValidIndianPhoneNumber(String phoneNumber) {
    final RegExp regex = RegExp(r'^[6-9]\d{9}$');
    return regex.hasMatch(phoneNumber);
  }

  Future<void> updatePhoneNumber() async {
    final res = await ApiServices()
        .updatePhoneNumber(context, phoneController.text.trim());
    if (res != null) {
      widget.onUpdate(phoneController.text.trim());
      Navigator.pop(context);
    } else {
      showMessage("Something went wrong!");
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.inter(),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.fixed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void initState() {
    if (widget.user.phone != null) {
      if (widget.user.phone!.startsWith("+91")) {
        phoneController.text =
            widget.user.phone?.replaceAll(RegExp(r'\+91'), '') ?? "";
      } else {
        phoneController.text = widget.user.phone!;
      }
    }
    buttonStatus = updateButtonStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Phone Number',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Please enter your new phone number',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Note: Do not enter country code [+91]',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              TextField(
                onChanged: (v) {
                  setState(() {
                    buttonStatus = updateButtonStatus();
                  });
                },
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '1234567890',
                  hintStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black45,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: Colors.black12,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: Colors.black12,
                      width: 1,
                    ),
                  ),
                ),
                maxLines: 1,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                alignment: Alignment.bottomCenter,
                margin: const EdgeInsets.only(bottom: 16),
                child: TextButton(
                  onPressed: !buttonStatus
                      ? null
                      : () {
                          updatePhoneNumber();
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: !buttonStatus
                          ? const Color.fromARGB(255, 113, 113, 113)
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
                    child: Text(
                      'Submit',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileButton extends StatelessWidget {
  final String buttonName;
  final IconData iconName;
  final VoidCallback? onPressed;

  const ProfileButton({
    super.key,
    this.buttonName = 'Feedback',
    this.iconName = Icons.feedback_rounded,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        if (onPressed != null) {
          onPressed!();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).textTheme.titleMedium?.color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
                offset: Offset(0, 4), // Offset in the x, y direction
                blurRadius: 10.0,
                spreadRadius: 0.0,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                iconName,
                size: 30,
                // color: Colors.black,
              ),
              const SizedBox(width: 20),
              Text(
                buttonName,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
