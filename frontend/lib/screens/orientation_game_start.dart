import 'package:dashbaord/screens/orientation_game.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class GameStartScreen extends StatefulWidget {
  const GameStartScreen({super.key});

  @override
  State<GameStartScreen> createState() => _GameStartScreenState();
}

class _GameStartScreenState extends State<GameStartScreen> {
  String svgData =
      '''<svg width="1037" height="128" viewBox="0 0 1037 128" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M47.8457 0H986.223V108C986.223 119.046 977.269 128 966.223 128H67.8457C56.8 128 47.8457 119.046 47.8457 108V0Z" fill="#503D2B"/>
<rect width="1037" height="38.1754" rx="19.0877" fill="#503D2B"/>
<rect x="15.623" y="31.4385" width="1005.75" height="41.5439" rx="20.7719" fill="#503D2B"/>
<rect x="31.2471" y="65.123" width="971.577" height="38.1754" rx="19.0877" fill="#503D2B"/>
</svg>

''';

  List<List<int>> grid = [];
  List<List<bool>> state = [];
  bool isWon = false;
  bool isKilled = false;

  bool isLoading = false;
  bool buttonClicked = false;

  startGame() async {
    setState(() {
      buttonClicked = true;
      isLoading = true;
    });
    ApiServices apiServices = ApiServices();
    final response = await apiServices.gameStart();

    setState(() {
      grid = response['game_state'];
      state = response['current_state'];
      isKilled = response['killed'];
      isWon = response['won'];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Housie',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 24, 14, 40),
                    margin: const EdgeInsets.fromLTRB(24, 36, 24, 0),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8E7C8),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(0),
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Draw Numbers: The caller draws one number at a time from the container and announces it to the players.\n\n'
                      'Mark Numbers: Players look for the called number on their cards and mark it if it is present.\n\n'
                      'Complete Patterns: The game can be played with various patterns, such as a full house (all numbers on the card), a single line (any horizontal line), or other patterns as specified at the start of the game.\n\n'
                      'Call Housie: When a player completes the required pattern, they must call out "Housie" or "Bingo!" The game pauses while the caller checks the player\'s card.',
                      style: GoogleFonts.raleway(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff382D21),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.string(
                          svgData,
                          height: 64,
                        ),
                        Positioned(
                          child: Text(
                            'Guide For Housie',
                            style: GoogleFonts.raleway(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12.0),
                margin: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6C1F8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Game starts during lambda orientation. Stay Tuned!',
                  style: GoogleFonts.raleway(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff000000),
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF503D2B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 18.0),
                ),
                onPressed: buttonClicked
                    ? null
                    : () async {
                        await startGame();

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (ctx) => OrientationGameScreen(
                                      isKilled: isKilled,
                                      isWon: isWon,
                                      grid: grid,
                                      state: state,
                                    )));

                        // Navigator.of(context).push(
                        //     MaterialPageRoute(builder: (context) => OrientationGameScreen()));
                      },
                child: Text(
                  'Start Game',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
