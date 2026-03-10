import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'series_selection_page.dart';

class NetflixTransitionPage extends StatefulWidget {
  const NetflixTransitionPage({super.key});

  @override
  State<NetflixTransitionPage> createState() => _NetflixTransitionPageState();
}

class _NetflixTransitionPageState extends State<NetflixTransitionPage> with TickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textScaleAnimation;
  
  bool _showGif = false;

  @override
  void initState() {
    super.initState();
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _textScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack)),
    );

    _textController.forward();

    // Wait 2.5 seconds, then crossfade to the High Quality Tudum GIF
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showGif = true;
        });
        
        // Let the GIF play out for 4 seconds, then transition to the App
        Future.delayed(const Duration(milliseconds: 4000), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const SeriesSelectionPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 800),
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Pure black background
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          child: _showGif 
            ? _buildGifPhase()
            : _buildTextPhase(),
        ),
      ),
    );
  }

  Widget _buildTextPhase() {
    return AnimatedBuilder(
      key: const ValueKey("TextPhase"),
      animation: _textController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _textFadeAnimation,
          child: ScaleTransition(
            scale: _textScaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Netflix",
                  style: GoogleFonts.secularOne(
                    fontSize: 52,
                    color: const Color(0xFFE50914), // Netflix Red
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    shadows: [
                      BoxShadow(
                        color: const Color(0xFFE50914).withValues(alpha: 0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 0),
                      )
                    ]
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "LANGUAGE LEARNING",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGifPhase() {
    return Image.network(
      // AAAAC denotes the standard/higher-res GIF rather than the tiny AAAAM version
      "https://media.tenor.com/ysXQdrShUGwAAAAC/netflix-intro.gif", 
      key: const ValueKey("GifPhase"),
      width: double.infinity,
      fit: BoxFit.fitWidth,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFE50914)),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Text(
          "NETFLIX", 
          style: GoogleFonts.secularOne(fontSize: 42, color: const Color(0xFFE50914), letterSpacing: 4)
        );
      },
    );
  }
}
