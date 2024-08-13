import 'package:dashbaord/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

class OrientationGameScreen extends StatefulWidget {
  final List<List<int>> grid;
  final List<List<bool>> state;
  final bool isWon;
  final bool isKilled;
  const OrientationGameScreen(
      {super.key,
      required this.grid,
      required this.state,
      required this.isKilled,
      required this.isWon});

  @override
  State<OrientationGameScreen> createState() => _OrientationGameScreenState();
}

class _OrientationGameScreenState extends State<OrientationGameScreen> {
  int? selectedIndex;
  List<List<bool>> state = [];
  bool isKilled = false;
  bool isWon = false;

  bool isClicked = false;

  @override
  void initState() {
    super.initState();
    state = widget.state;
    isKilled = widget.isKilled;
    isWon = widget.isWon;
  }

  void showError({String? msg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text(msg ?? 'Something Went Wrong!')),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit the game?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  // Reset the orientation to portrait when leaving the screen
                  await SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                    DeviceOrientation.portraitDown,
                  ]);
                  Navigator.of(context).pop(true);
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    final textColor = Colors.black;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Theme(
        data: ThemeData.light().copyWith(
          scaffoldBackgroundColor:
              Colors.white, // Ensure the background is light
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white, // AppBar background color
            iconTheme: IconThemeData(color: textColor), // Icon color
            titleTextStyle: TextStyle(
              color: textColor, // Title text color
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: Colors.grey[800], // SnackBar background color
            contentTextStyle: TextStyle(color: Colors.white), // Text color
          ),
        ),
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
                size: 30.0,
              ),
              onPressed: () async {
                final shouldPop = await _onWillPop();
                if (shouldPop) {
                  Navigator.pop(context);
                }
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 48),
                child: Container(
                  padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: isKilled
                          ? Colors.red
                          : isWon
                              ? Colors.green
                              : Colors.transparent),
                  child: Text(isKilled
                      ? 'You Lost'
                      : isWon
                          ? 'You Won'
                          : ''),
                ),
              )
            ],
          ),
          body: Row(
            children: [
              Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                        onPressed: selectedIndex != null
                            ? () async {
                                setState(() {
                                  isClicked = true;
                                });
                                int i = selectedIndex! ~/ 9;
                                int j = selectedIndex! % 9;
                                if (state[i][j]) {
                                  showError(
                                      msg: 'You already marked this cell.');
                                }
                                final response =
                                    await ApiServices().updateGameState(i, j);
                                if (response.statusCode != 200) {
                                  showError(msg: response.data);
                                } else {
                                  setState(() {
                                    state[i][j] = true;
                                    //TODO: test these once
                                    isKilled = response.data['killed'];
                                    isWon = response.data['won'];
                                  });
                                }
                                setState(() {
                                  isClicked = false;
                                });
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isClicked
                              ? Colors.grey
                              : selectedIndex != null
                                  ? Colors.blue
                                  : Colors
                                      .grey, // Change button color based on selection
                          minimumSize: const Size(80, 80),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isClicked
                            ? CircularProgressIndicator(
                                color: Colors.blue,
                              )
                            : const Icon(
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
      ),
    );
  }

  Widget _buildGridButton(int idx) {
    int row = idx ~/ 9; // Integer division to get the row index
    int col = idx % 9; // Modulus operation to get the column index

    // Handle the case where the grid value is -1 (return a placeholder)
    if (widget.grid[row][col] == -1) {
      return GestureDetector(
        onTap: () {
          // Handle tap for empty grid slot, if needed
        },
        child: Container(
          width: 100, // Adjust the size as needed
          height: 100, // Adjust the size as needed
          decoration: BoxDecoration(
            color: Colors.grey[300], // Placeholder background color
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.block, color: Colors.grey), // Placeholder icon
        ),
      );
    }

    bool isSelected = selectedIndex == idx;
    String backendUrl = dotenv.env["BACKEND_URL"] ?? "";
    String imgUrl = '$backendUrl/game/images/${widget.grid[row][col]}.png';

    // Handle the case where the grid cell is already marked
    if (state.isNotEmpty && state[row][col]) {
      return Container(
        width: 100, // Adjust the size as needed
        height: 100, // Adjust the size as needed
        decoration: BoxDecoration(
          color: Colors.grey[300], // Background color for marked cells
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.redAccent, // Border color for marked cells
            width: 3,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                '$backendUrl/game/images/${widget.grid[row][col]}.png',
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: Icon(Icons.error, color: Colors.red),
                  );
                },
              ),
            ),
            const Icon(
              Icons.lock, // Lock icon to indicate the cell is marked
              color: Colors.white,
              size: 30,
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (isKilled || isWon) return;

        setState(() {
          if (selectedIndex == idx) {
            selectedIndex = null;
          } else {
            selectedIndex = idx;
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
              child: Image.network(
                imgUrl,
                fit: BoxFit.cover,
                color: isSelected ? Colors.black.withOpacity(0.3) : null,
                colorBlendMode: isSelected ? BlendMode.darken : null,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: Icon(Icons.error, color: Colors.red),
                  );
                },
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
