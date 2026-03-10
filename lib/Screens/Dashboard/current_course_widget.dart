import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class CurrentCourseWidget extends StatelessWidget {
  const CurrentCourseWidget({super.key});

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
          // Labels
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF26D390).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Group course",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF26D390),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D81FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Advanced",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D81FF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Title
          Text(
            "English punctuation made easy",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          
          // Description
          Text(
            "Punctuation — learn the basics without the pain. People will never laugh at your punctuation again. You do not require any materials or software.",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          
          // Participants & Progress area
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Participants",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildParticipantAvatar(),
                      Transform.translate(offset: const Offset(-10, 0), child: _buildParticipantAvatar()),
                      Transform.translate(offset: const Offset(-20, 0), child: _buildParticipantAvatar()),
                      Transform.translate(offset: const Offset(-30, 0), child: _buildParticipantAvatar()),
                    ],
                  ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Course progress",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                       height: 36,
                       padding: const EdgeInsets.symmetric(horizontal: 12),
                       decoration: BoxDecoration(
                         color: const Color(0xFFFFF2D0), // Light yellow bg like ref
                         borderRadius: BorderRadius.circular(18),
                       ),
                       child: Stack(
                         children: [
                           // The filled part
                           Align(
                             alignment: Alignment.centerLeft,
                             child: LayoutBuilder(
                               builder: (context, constraints) {
                                  return Container(
                                    width: constraints.maxWidth * 0.75, // 75% wide
                                    decoration: BoxDecoration(
                                       color: const Color(0xFFFFCC33),
                                       borderRadius: BorderRadius.circular(18),
                                    ),
                                  );
                               }
                             ),
                           ),
                           // Text overlay
                           Align(
                             alignment: Alignment.centerLeft,
                             child: Text(
                               "75%",
                               style: GoogleFonts.poppins(
                                 fontSize: 14,
                                 fontWeight: FontWeight.bold,
                                 color: Colors.black87,
                               ),
                             ),
                           )
                         ],
                       )
                    )
                  ],
                ),
              ),
            ],
          ),
          
          const Spacer(),
          // Continue Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                "Continue learning",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildParticipantAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const CircleAvatar(
        radius: 16,
        backgroundColor: Colors.blueGrey,
        child: Icon(CupertinoIcons.person_solid, color: Colors.white, size: 18),
      ),
    );
  }
}
