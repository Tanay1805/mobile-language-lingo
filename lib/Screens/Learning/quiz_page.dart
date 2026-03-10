import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'flashcards_page.dart';

class QuizPage extends StatefulWidget {
  final String showName;
  final String targetLanguage;
  final String episode;

  const QuizPage({
    super.key,
    required this.showName,
    required this.targetLanguage,
    required this.episode,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  bool _isLoading = true;
  bool _isGeneratingFlashcards = false;
  List<dynamic> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  List<dynamic> _mistakes = [];
  bool _quizFinished = false;

  final FlutterTts flutterTts = FlutterTts();
  Timer? _timer;
  int _timeLeft = 15;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _setupTts();
    _fetchQuiz();
  }

  @override
  void dispose() {
    _timer?.cancel();
    flutterTts.stop();
    super.dispose();
  }

  void _setupTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
  }

  void _speakQuestion(String text) async {
    await flutterTts.speak(text);
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timeLeft = 15);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        timer.cancel();
        _handleTimeUp();
      }
    });
  }

  void _handleTimeUp() {
    // Treat timeout as a mistake automatically
    final currentQ = _questions[_currentIndex];
    _mistakes.add(currentQ);
    setState(() => _streak = 0);
    _advanceToNextQuestion();
  }

  Future<void> _fetchQuiz() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/quiz/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'showName': widget.showName,
          'targetLanguage': widget.targetLanguage,
          'episode': widget.episode,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _questions = data['questions'];
          _isLoading = false;
        });
        if (_questions.isNotEmpty) {
          _startTimer();
          _speakQuestion(_questions[0]['question_text']);
        }
      } else {
        throw Exception('Failed to load quiz');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching quiz: $e')),
        );
      }
    }
  }

  void _handleAnswer(String selectedAnswer, String correctAnswer, Map<String, dynamic> questionContext) {
    _timer?.cancel();
    flutterTts.stop();

    if (selectedAnswer == correctAnswer) {
      _score++;
      _streak++;
    } else {
      _mistakes.add(questionContext);
      _streak = 0;
    }
    _advanceToNextQuestion();
  }

  void _advanceToNextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
      _startTimer();
      _speakQuestion(_questions[_currentIndex]['question_text']);
    } else {
      setState(() => _quizFinished = true);
    }
  }

  Future<void> _generateFlashcards() async {
    setState(() => _isGeneratingFlashcards = true);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/flashcards/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mistakes': _mistakes,
          'targetLanguage': widget.targetLanguage,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FlashcardsPage(
                flashcards: data['flashcards'],
                targetLanguage: widget.targetLanguage,
              ),
            ),
          );
        }
      } else {
        throw Exception('Failed to generate flashcards');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating flashcards: $e')),
        );
      }
    } finally {
      setState(() => _isGeneratingFlashcards = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: Text(
          "AI Quiz: ${widget.showName}",
          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B4FE8)))
          : _quizFinished
              ? _buildResultsScreen()
              : _buildQuizScreen(),
    );
  }

  Widget _buildQuizScreen() {
    if (_questions.isEmpty) {
      return const Center(child: Text("No questions generated."));
    }

    final currentQ = _questions[_currentIndex];
    final List<dynamic> options = currentQ['options'];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // UI Gamification Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Question ${_currentIndex + 1}/${_questions.length}",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  if (_streak >= 2) ...[
                    const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      "$_streak Streak!",
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B4FE8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Score: $_score",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6B4FE8),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          // Timer UI
          Row(
            children: [
              Icon(Icons.timer_outlined, color: _timeLeft <= 5 ? Colors.red : Colors.grey.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _timeLeft / 15, // Assuming 15s max
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _timeLeft <= 5 ? Colors.redAccent : const Color(0xFF26D390),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "0:${_timeLeft.toString().padLeft(2, '0')}",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _timeLeft <= 5 ? Colors.red : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            currentQ['question_text'],
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.3),
          ),
          const SizedBox(height: 40),
          ...options.asMap().entries.map((entry) {
            int idx = entry.key;
            String option = entry.value;
            String letter = String.fromCharCode(65 + idx); // A, B, C, D
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () => _handleAnswer(option, currentQ['correct_answer'], currentQ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F0FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6B4FE8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        option,
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResultsScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: const Icon(
                Icons.celebration,
                size: 64,
                color: Color(0xFF6B4FE8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Quiz Complete!",
              style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              "You scored $_score out of ${_questions.length}",
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 48),
            if (_mistakes.isNotEmpty) ...[
              Text(
                "You made ${_mistakes.length} mistakes.",
                style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 16),
              ),
              const SizedBox(height: 16),
              _isGeneratingFlashcards
                  ? const CircularProgressIndicator(color: Color(0xFF6B4FE8))
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B4FE8),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _generateFlashcards,
                      icon: const Icon(Icons.style, color: Colors.white),
                      label: Text(
                         "Generate AI Flashcards from Mistakes",
                         style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
            ] else ...[
              Text(
                "Perfect score! No flashcards needed.",
                style: GoogleFonts.poppins(color: const Color(0xFF26D390), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text("Return to Dashboard", style: GoogleFonts.poppins(color: Colors.white)),
              )
            ]
          ],
        ),
      ),
    );
  }
}
