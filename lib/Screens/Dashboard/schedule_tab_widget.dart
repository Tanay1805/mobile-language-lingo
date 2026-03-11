import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleTabWidget extends StatefulWidget {
  const ScheduleTabWidget({super.key});

  @override
  State<ScheduleTabWidget> createState() => _ScheduleTabWidgetState();
}

class _ScheduleTabWidgetState extends State<ScheduleTabWidget> {
  List<Map<String, dynamic>> _availableSessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAvailableSessions();
  }

  Future<void> _fetchAvailableSessions() async {
    try {
      final response = await Supabase.instance.client
          .from('instructor_sessions')
          .select('*')
          .order('id', ascending: true);
      
      if (mounted) {
        setState(() {
          _availableSessions = List<Map<String, dynamic>>.from(response);
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

  Future<void> _bookSession(String sessionId, String calendlyUrl) async {
    final uri = Uri.parse(calendlyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      
      // Save booked session to database
      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
           await Supabase.instance.client.from('user_sessions').upsert({
             'user_id': user.id,
             'session_id': sessionId,
             'status': 'upcoming' // Future expansion
           });
           
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text("Session booked and saved to your Dashboard!")),
             );
           }
        }
      } catch (e) {
         debugPrint("Failed to record booking: \$e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Available Coaching Sessions",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Book 1-on-1 language coaching with expert mentors.",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          if (_availableSessions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Text(
                  "No coaching sessions are currently available.",
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                ),
              ),
            )
          else
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: _availableSessions.map((session) {
                return _buildFullScheduleCard(
                  time: session['time_slot'] ?? "Flexible",
                  title: session['title'] ?? session['language'],
                  level: session['level'] ?? "All Levels",
                  mentorName: session['mentor_name'] ?? "Instructor",
                  isActive: session['is_active'] ?? false,
                  calendlyUrl: session['calendly_url'],
                  sessionId: session['id'] as String,
                );
              }).toList(),
            )
        ],
      ),
    );
  }

  Widget _buildFullScheduleCard({
    required String time,
    required String title,
    required String level,
    required String mentorName,
    required bool isActive,
    required String sessionId,
    String? calendlyUrl,
  }) {
    final bgColor = isActive ? const Color(0xFF6B4FE8) : const Color(0xFFF9F9FB);
    final textColor = isActive ? Colors.white : Colors.black87;
    final subtitleColor = isActive ? Colors.white70 : Colors.grey.shade600;

    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: isActive ? null : Border.all(color: Colors.grey.shade200),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF6B4FE8).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
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
                  fontSize: 13,
                  color: subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? Colors.white.withOpacity(0.2) : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              level,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isActive ? Colors.white24 : Colors.grey.shade200,
                child: Icon(Icons.person, color: isActive ? Colors.white : Colors.grey.shade500, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mentorName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    "Mentor & Coach",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: subtitleColor,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          if (calendlyUrl != null)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => _bookSession(sessionId, calendlyUrl),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? Colors.white : const Color(0xFF6B4FE8),
                  foregroundColor: isActive ? const Color(0xFF6B4FE8) : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Book Session",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
