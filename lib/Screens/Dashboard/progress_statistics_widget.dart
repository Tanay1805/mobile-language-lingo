import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressStatisticsWidget extends StatelessWidget {
  const ProgressStatisticsWidget({super.key});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Progress statistics",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "64%",
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total",
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    "activity",
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          // Progress Bars
          Row(
             children: [
               Expanded(
                 flex: 24,
                 child: _buildSegmentedBar(const Color(0xFF6B4FE8), "24%"), // Purple
               ),
               const SizedBox(width: 4),
               Expanded(
                 flex: 35,
                 child: _buildSegmentedBar(const Color(0xFF26D390), "35%"), // Green
               ),
               const SizedBox(width: 4),
               Expanded(
                 flex: 41,
                 child: _buildSegmentedBar(const Color(0xFFFF9421), "41%"), // Orange
               ),
             ],
          ),
          
          const Spacer(),
          // Stats row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9FB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(CupertinoIcons.book, const Color(0xFF6B4FE8), "8", "In progress"),
                Container(width: 1, height: 40, color: Colors.grey.shade200),
                _buildStatItem(CupertinoIcons.check_mark_circled, const Color(0xFF26D390), "12", "Completed"),
                Container(width: 1, height: 40, color: Colors.grey.shade200),
                _buildStatItem(CupertinoIcons.clock, const Color(0xFFFF9421), "14", "Upcoming"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedBar(Color color, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, Color color, String count, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
