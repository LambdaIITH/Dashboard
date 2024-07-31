import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class OrientationGameScreen extends StatefulWidget {
  const OrientationGameScreen({super.key});

  @override
  State<OrientationGameScreen> createState() => _OrientationGameScreenState();
}

class _OrientationGameScreenState extends State<OrientationGameScreen> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return WillPopScope(
      onWillPop: () async {
        // Reset the orientation to system defaults when leaving the screen
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Housie by Lambda',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
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
        body: Row(
          children: [
            Expanded(
              flex: 8,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 9, // 9 buttons per row
                    childAspectRatio: 1,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: 27,
                  itemBuilder: (context, index) {
                    return _buildGridButton(index);
                  },
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: selectedIndex != null ? () {} : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedIndex != null
                            ? Colors.blue
                            : Colors
                                .grey, // Change button color based on selection
                        minimumSize: const Size(80, 80),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridButton(int index) {
    bool isSelected = selectedIndex == index;

    final List<String> imageURLs =
        List.generate(27, (index) => 'assets/icons/google.png');

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedIndex == index) {
            selectedIndex = null;
          } else {
            selectedIndex = index;
          }
        });
      },
      child: Stack(
        children: [
          // Image container with opacity change on selection
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.blueAccent : Colors.transparent,
                width: 3,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imageURLs[index],
                fit: BoxFit.cover,
                color: isSelected ? Colors.black.withOpacity(0.3) : null,
                colorBlendMode: isSelected ? BlendMode.darken : null,
              ),
            ),
          ),
          // Tick mark for selected button
          if (isSelected)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }
}
