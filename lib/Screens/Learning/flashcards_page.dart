import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';

class FlashcardsPage extends StatefulWidget {
  final List<dynamic> flashcards;
  final String targetLanguage;

  const FlashcardsPage({
    super.key,
    required this.flashcards,
    required this.targetLanguage,
  });

  @override
  State<FlashcardsPage> createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("AI Flashcards")),
        body: const Center(child: Text("No flashcards generated.")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: Text(
          "Review Mistakes",
          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Text(
              "Card ${_currentIndex + 1} of ${widget.flashcards.length}",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: widget.flashcards.length,
              itemBuilder: (context, index) {
                final card = widget.flashcards[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                  child: FlashcardItem(
                    index: index,
                    frontText: card['front_text'] ?? 'Missing Word',
                    englishMeaning: card['english_meaning'] ?? 'Missing Meaning',
                    mnemonic: card['mnemonic'] ?? 'Missing Mnemonic',
                    targetLanguage: widget.targetLanguage,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Icon(Icons.arrow_back),
                  )
                else
                  const SizedBox(width: 80),

                if (_currentIndex < widget.flashcards.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B4FE8),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  )
                else
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26D390),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Finish Review", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FlashcardItem extends StatefulWidget {
  final int index;
  final String frontText;
  final String englishMeaning;
  final String mnemonic;
  final String targetLanguage;

  const FlashcardItem({
    super.key,
    required this.index,
    required this.frontText,
    required this.englishMeaning,
    required this.mnemonic,
    required this.targetLanguage,
  });

  @override
  State<FlashcardItem> createState() => _FlashcardItemState();
}

class _FlashcardItemState extends State<FlashcardItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final FlutterTts flutterTts = FlutterTts();
  bool _isFront = true;

  final List<LinearGradient> _cardGradients = [
    const LinearGradient(colors: [Color(0xFF6B4FE8), Color(0xFF9D65C9)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    const LinearGradient(colors: [Color(0xFF4D96FF), Color(0xFF53DFD1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    const LinearGradient(colors: [Color(0xFF26D390), Color(0xFF3D9970)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    const LinearGradient(colors: [Color(0xFFFFB347), Color(0xFFFFD56F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _setupTts();
  }

  void _setupTts() async {
    // Basic language mapping for TTS engines
    String langCode = "en-US";
    if (widget.targetLanguage.toLowerCase().contains("korean")) langCode = "ko-KR";
    if (widget.targetLanguage.toLowerCase().contains("spanish")) langCode = "es-ES";
    if (widget.targetLanguage.toLowerCase().contains("french")) langCode = "fr-FR";
    if (widget.targetLanguage.toLowerCase().contains("german")) langCode = "de-DE";
    if (widget.targetLanguage.toLowerCase().contains("japanese")) langCode = "ja-JP";
    await flutterTts.setLanguage(langCode);
    await flutterTts.setSpeechRate(0.5); // Slower for learning
  }

  void _speakWord() async {
    await flutterTts.speak(widget.frontText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_controller.isAnimating) return;
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: _buildCardContent(angle),
          );
        },
      ),
    );
  }

  Widget _buildCardContent(double angle) {
    final showFront = angle < pi / 2;
    final gradient = _cardGradients[widget.index % _cardGradients.length];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        gradient: gradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Transform(
        transform: Matrix4.identity()..rotateY(showFront ? 0 : pi),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: showFront 
            // FRONT OF CARD
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  Text(
                    widget.frontText,
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  IconButton(
                    onPressed: _speakWord,
                    icon: const Icon(Icons.volume_up_rounded, size: 36, color: Colors.white),
                  ),
                  Spacer(),
                  Text(
                    "Tap anywhere to flip",
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                  )
                ],
              )
            // BACK OF CARD
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  Text(
                    "Meaning",
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.englishMeaning,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(color: Colors.white24),
                  ),
                  Text(
                    "Memory Device",
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.mnemonic,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                  Text(
                    "Tap to flip back",
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                  )
                ],
              ),
        ),
      ),
    );
  }
}
