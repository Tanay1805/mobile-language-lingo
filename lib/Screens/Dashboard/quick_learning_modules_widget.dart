import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import '../learning/series_selection_page.dart';

class QuickLearningModulesWidget extends StatelessWidget {
  const QuickLearningModulesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Text(
            "Quick Learning",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Flashcards
          _buildModuleRow(
            icon: CupertinoIcons.rectangle_on_rectangle_angled,
            iconColor: Colors.black,
            title: "Flashcards",
            subtitle: "Vocabulary Practice",
            stat: "12 decks",
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFF0F0F0), height: 1),
          ),
          // Audiobooks
          _buildModuleRow(
            icon: CupertinoIcons.headphones,
            iconColor: const Color(0xFF2D81FF), // Zoom blue vibe from ref
            title: "Audiobooks",
            subtitle: "Listening Skills",
            stat: "5 hours",
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFF0F0F0), height: 1),
          ),
          // Quizzes
          _buildModuleRow(
            icon: CupertinoIcons.checkmark_seal_fill,
            iconColor: const Color(0xFF00B25D), // Google Meet green vibe from ref
            title: "Quizzes",
            subtitle: "Test Netflix Vocabulary",
            stat: "AI Gen",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SeriesSelectionPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModuleRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String stat,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            // Icon Container
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9FB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        // Texts
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        // Stat text
        Text(
          stat,
          style: GoogleFonts.poppins(
             fontSize: 14,
             fontWeight: FontWeight.w500,
             color: Colors.black87,
          ),
        ),
      ],
        ),
      ),
    );
  }
}
