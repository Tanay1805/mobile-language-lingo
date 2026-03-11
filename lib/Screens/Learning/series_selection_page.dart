import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'quiz_page.dart';

class SeriesSelectionPage extends StatelessWidget {
  const SeriesSelectionPage({super.key});

  final List<Map<String, String>> netflixShows = const [
    {"title": "Squid Game", "language": "Korean", "img": "https://static.tvmaze.com/uploads/images/original_untouched/576/1440521.jpg"},
    {"title": "Money Heist", "language": "Spanish", "img": "https://static.tvmaze.com/uploads/images/original_untouched/430/1076004.jpg"},
    {"title": "Lupin", "language": "French", "img": "https://static.tvmaze.com/uploads/images/original_untouched/603/1507749.jpg"},
    {"title": "Dark", "language": "German", "img": "https://static.tvmaze.com/uploads/images/original_untouched/504/1262352.jpg"},
    {"title": "Alice in Borderland", "language": "Japanese", "img": "https://static.tvmaze.com/uploads/images/original_untouched/589/1473249.jpg"},
    {"title": "Elite", "language": "Spanish", "img": "https://static.tvmaze.com/uploads/images/original_untouched/529/1324751.jpg"},
    {"title": "Call My Agent!", "language": "French", "img": "https://static.tvmaze.com/uploads/images/original_untouched/426/1065697.jpg"},
    {"title": "Borgen", "language": "Danish", "img": "https://static.tvmaze.com/uploads/images/original_untouched/461/1154695.jpg"},
    {"title": "The Empress", "language": "German", "img": "https://static.tvmaze.com/uploads/images/original_untouched/216/540247.jpg"},
    {"title": "Ragnarok", "language": "Norwegian", "img": "https://static.tvmaze.com/uploads/images/original_untouched/365/913671.jpg"},
    {"title": "3%", "language": "Portuguese", "img": "https://static.tvmaze.com/uploads/images/original_untouched/208/520741.jpg"},
    {"title": "The Rain", "language": "Danish", "img": "https://static.tvmaze.com/uploads/images/original_untouched/202/505919.jpg"},
    {"title": "Into the Night", "language": "French", "img": "https://static.tvmaze.com/uploads/images/original_untouched/257/644938.jpg"},
    {"title": "Vincenzo", "language": "Korean", "img": "https://static.tvmaze.com/uploads/images/original_untouched/481/1202670.jpg"},
    {"title": "Sacred Games", "language": "Hindi", "img": "https://static.tvmaze.com/uploads/images/original_untouched/204/511629.jpg"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: Text(
          "Select a Series",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "Learn through Context",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Choose a Netflix show below. Our AI will generate custom vocabulary quizzes and flashcards based on the show's actual dialogue, plot, and target language!",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: netflixShows.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Smaller cards via 3 columns
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.65, // Classic portrait movie poster ratio
                ),
                itemBuilder: (context, index) {
                  final show = netflixShows[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizPage(
                            showName: show["title"]!,
                            targetLanguage: show["language"]!,
                            episode: "Season 1", // Generalized
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey.shade900,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                              imageUrl: show["img"]!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade800,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white54,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade800,
                                child: const Icon(Icons.error, color: Colors.red),
                              ),
                            ),
                          ),
                          // Elegant Gradient Overlay for Text Readability
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [Colors.transparent, Colors.black87],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [0.5, 1.0],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withValues(alpha: 0.9), // Classic Netflix language badge
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    show["language"]!,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  show["title"]!,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
