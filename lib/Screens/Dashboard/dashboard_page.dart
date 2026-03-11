import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import 'activity_chart_widget.dart';
import 'quick_learning_modules_widget.dart';
import 'progress_statistics_widget.dart';
import 'my_schedule_widget.dart';
import 'schedule_tab_widget.dart';
import 'support_tab_widget.dart';
import 'current_course_widget.dart';
import '../Learning/series_selection_page.dart';
import '../Learning/netflix_transition_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedNavIndex = 1; // Default to Dashboard
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Fetch from profiles table directly, as userMetadata is often a cached token
      try {
        final profileData = await Supabase.instance.client
            .from('profiles')
            .select('avatar_url')
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() {
            _avatarUrl = profileData['avatar_url'] as String?;
          });
        }
      } catch (e) {
        // Fallback to metadata if table fetch fails
        if (mounted) {
          setState(() {
            _avatarUrl = user.userMetadata?['avatar_url'];
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1100;
    final isTablet = screenWidth > 750 && screenWidth <= 1100;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB), // Light grey background from ref
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 40.0 : 20.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopNavigationBar(isDesktop || isTablet),
                const SizedBox(height: 30),
                // Only show dashboard widget grids if "Dashboard" (index 1) is selected
                if (_selectedNavIndex == 1) ...[
                  if (isDesktop) _buildDesktopLayout(),
                  if (isTablet) _buildTabletLayout(),
                ] else if (_selectedNavIndex == 2) ...[
                  const ScheduleTabWidget(),
                ] else if (_selectedNavIndex == 4) ...[
                  const SupportTabWidget(),
                ] else ...[
                  _buildComingSoonTab(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavigationBar(bool showFullMenu) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              const Icon(CupertinoIcons.globe, color: Colors.black, size: 28),
              const SizedBox(width: 8),
              Text(
                "LingoLearn",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          // Center Menu (Pill styling) if space allows
          if (showFullMenu)
            Row(
              children: [
                _buildNavItem("Content Courses", 0),
                _buildNavItem("Dashboard", 1),
                _buildNavItem("Schedule", 2),
                _buildNavItem("Support", 4),
              ],
            ),

          // Right Profile & Actions
          Row(
            children: [
              IconButton(
                icon: const Icon(CupertinoIcons.search, color: Colors.black87),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.bell, color: Colors.black87),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEAE6F9),
                  image: _avatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(_avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : const DecorationImage(
                        image: NetworkImage("https://i.pravatar.cc/150?img=11"),
                        fit: BoxFit.cover,
                      ),
                ),
                child: _avatarUrl == null
                    ? const Icon(CupertinoIcons.person_fill, color: Color(0xFF6B4FE8), size: 24)
                    : null,
              ),
              const SizedBox(width: 8),
              const Icon(CupertinoIcons.chevron_down, color: Colors.black54),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, int index) {
    final isSelected = _selectedNavIndex == index;
    final isPremium = index == 0; // The "Content Courses" button

    return GestureDetector(
      onTap: () {
        if (isPremium) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NetflixTransitionPage()),
          );
        } else {
          setState(() => _selectedNavIndex = index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          // Shiny premium gradient for "Content Courses"
          gradient: isPremium 
            ? const LinearGradient(
                colors: [Color(0xFFE50914), Color(0xFFB71C1C)], // Netflix Reds
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
          color: isPremium ? null : (isSelected ? Colors.black : Colors.transparent),
          borderRadius: BorderRadius.circular(24),
          boxShadow: (isSelected || isPremium)
              ? [
                  BoxShadow(
                    color: isPremium ? const Color(0xFFE50914).withValues(alpha: 0.4) : Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            if (isPremium) ...[
              const Icon(CupertinoIcons.play_circle_fill, color: Colors.white, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: isSelected || isPremium ? FontWeight.w600 : FontWeight.w500,
                color: isSelected || isPremium ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonTab() {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "Coming Soon",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (Activity & Learning Modules)
        const Expanded(
          flex: 3,
          child: Column(
            children: [
               SizedBox(height: 340, child: ActivityChartWidget()),
               SizedBox(height: 20),
               SizedBox(height: 280, child: QuickLearningModulesWidget()),
            ],
          ),
        ),
        const SizedBox(width: 20),
        
        // Middle Column (Stats & Schedule)
        const Expanded(
          flex: 4,
          child: Column(
            children: [
               SizedBox(height: 340, child: ProgressStatisticsWidget()),
               SizedBox(height: 20),
               SizedBox(height: 280, child: MyScheduleWidget()),
            ],
          ),
        ),
        const SizedBox(width: 20),
        
        // Right Column (Current Course)
        const Expanded(
          flex: 3,
          child: Column(
            children: [
               SizedBox(height: 640, child: CurrentCourseWidget()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return const Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(height: 340, child: ActivityChartWidget()),
            ),
            SizedBox(width: 20),
            Expanded(
              child: SizedBox(height: 340, child: ProgressStatisticsWidget()),
            ),
          ],
        ),
        SizedBox(height: 20),
        SizedBox(height: 280, child: MyScheduleWidget()),
        SizedBox(height: 20),
        Row(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Expanded(
               child: SizedBox(height: 280, child: QuickLearningModulesWidget()),
             ),
             SizedBox(width: 20),
             Expanded(
               child: SizedBox(height: 640, child: CurrentCourseWidget()),
             ),
           ],
        )
      ],
    );
  }

  Widget _buildMobileLayout() {
    return const Column(
      children: [
        SizedBox(height: 340, child: ActivityChartWidget()),
        SizedBox(height: 20),
        SizedBox(height: 280, child: QuickLearningModulesWidget()),
        SizedBox(height: 20),
        SizedBox(height: 340, child: ProgressStatisticsWidget()),
        SizedBox(height: 20),
        SizedBox(height: 280, child: MyScheduleWidget()),
        SizedBox(height: 20),
        SizedBox(height: 640, child: CurrentCourseWidget()),
      ],
    );
  }
}
