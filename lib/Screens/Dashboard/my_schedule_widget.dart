import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class MyScheduleWidget extends StatefulWidget {
  const MyScheduleWidget({super.key});

  @override
  State<MyScheduleWidget> createState() => _MyScheduleWidgetState();
}

class _MyScheduleWidgetState extends State<MyScheduleWidget> {
  List<Map<String, dynamic>> _instructorSessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await Supabase.instance.client
          .from('user_sessions')
          .select('*, instructor_sessions(*)')
          .eq('user_id', user.id)
          .order('booked_at', ascending: false);
      
      if (mounted) {
        setState(() {
          _instructorSessions = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching instructor sessions: \$e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "My schedule",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  _buildNavIcon(CupertinoIcons.chevron_left),
                  const SizedBox(width: 8),
                  Text(
                    "Today",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildNavIcon(CupertinoIcons.chevron_right),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          // Scrollable List of classes
          _isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _instructorSessions.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "You haven't booked any sessions yet.",
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Go to the Schedule tab to book a class!",
                              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B4FE8)),
                            )
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: _instructorSessions.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final userSession = _instructorSessions[index];
                          final sessionDetails = userSession['instructor_sessions'];
                          if (sessionDetails == null) return const SizedBox.shrink();

                          return _buildScheduleCard(
                            time: sessionDetails['time_slot'] ?? "Flexible",
                            title: sessionDetails['title'] ?? sessionDetails['language'],
                            level: sessionDetails['level'] ?? "All Levels",
                            mentorName: sessionDetails['mentor_name'] ?? "Instructor",
                            isActive: sessionDetails['is_active'] ?? false,
                          );
                        },
                      ),
                    )
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(icon, size: 18, color: Colors.black87),
    );
  }

  Widget _buildScheduleCard({
    required String time,
    required String title,
    required String level,
    required String mentorName,
    required bool isActive,
  }) {
    final bgColor = isActive ? const Color(0xFF6B4FE8) : const Color(0xFFF9F9FB);
    final textColor = isActive ? Colors.white : Colors.black87;
    final subtitleColor = isActive ? Colors.white70 : Colors.grey.shade600;

    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF6B4FE8).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: subtitleColor,
                ),
              ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                     children: [
                       Container(
                         width: 6,
                         height: 6,
                         decoration: const BoxDecoration(
                           color: Colors.white,
                           shape: BoxShape.circle,
                         ),
                       ),
                       const SizedBox(width: 4),
                       Text(
                         "Now",
                         style: GoogleFonts.poppins(
                           fontSize: 10,
                           color: Colors.white,
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                     ],
                  )
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? Colors.white.withOpacity(0.2) : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              level,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? Colors.white : const Color(0xFF6B4FE8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: isActive ? const Color(0xFF6B4FE8) : Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  "Confirmed",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? const Color(0xFF6B4FE8) : Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.blueGrey,
                child: Icon(CupertinoIcons.person_solid, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mentorName,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    "Mentor",
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: subtitleColor,
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
