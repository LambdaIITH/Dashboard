import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/utils/loading_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CustomGoogleButton extends StatefulWidget {
  const CustomGoogleButton({super.key});

  @override
  State<CustomGoogleButton> createState() => _CustomGoogleButtonState();
}

class _CustomGoogleButtonState extends State<CustomGoogleButton> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ["email"]);

  Future<bool> checkLoggedIn() async {
    return _googleSignIn.isSignedIn();
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xffFE724C),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<bool> signInWithGoogle() async {
    timeDilation = 1;
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return false;
      }

      if (mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CustomLoadingScreen()));
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await auth.signInWithCredential(credential);

      printInChunks(googleAuth.idToken ?? '');

      var result = await ApiServices().login(googleAuth.idToken ?? 'aa45');

      if (result['status'] == 401) {
        showSnackBar(result['error']);
        return false;
      }
      if (result['user'] == null) {
        showSnackBar('Failed to sign in with Google.');
        return false;
      }
      // successfully logged in

      return true;
    } catch (error) {
      print(error);
      showSnackBar('Failed to sign in with Google.');
      return false;
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
  }

  void printInChunks(String longString, {int chunkSize = 500}) {
    for (int i = 0; i < longString.length; i += chunkSize) {
      int end = (i + chunkSize < longString.length)
          ? i + chunkSize
          : longString.length;
      debugPrint(longString.substring(i, end));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xffFE724C),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            bool status = await signInWithGoogle();
            bool isLoggedIn = await checkLoggedIn();

            if (isLoggedIn && status) {
              var email = FirebaseAuth.instance.currentUser?.email ?? '';

              if (email.isEmpty) {
                await logout();
                showSnackBar('Error!');
                Navigator.of(context).pop(); //POP THE LOADING SCREEN
              } else {
                //verifying iith users
                var splitted = email.split('@');
                if (splitted.length > 1 && splitted[1].contains("iith.ac.in")) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const HomeScreen(
                      isGuest: false,
                    ),
                  ));
                } else {
                  await logout();
                  showSnackBar('Please login with IITH email-ID');
                  Navigator.of(context).pop(); //POP THE LOADING SCREEN
                }
              }
            } else {
              await logout();
              Navigator.of(context).pop(); //POP THE LOADING SCREEN
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/icons/google.png",
                  height: 36,
                  width: 36,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    "Continue with Google",
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff454545),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
