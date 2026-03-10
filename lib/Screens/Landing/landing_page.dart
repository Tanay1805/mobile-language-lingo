import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_animations/simple_animations.dart';
import '../Dashboard/dashboard_page.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_animations/simple_animations.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() { _isLoading = true; });
    try {
      // Use Supabase's built-in OAuth for web and mobile. 
      // It handles the redirect automatically!
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.languagelearner://login-callback', // Ignore if just testing on web
      );
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google Sign-In Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _handleNetflixLogin() async {
    setState(() { _isLoading = true; });
    try {
      // Use 10.0.2.2 for Android Emulator, or localhost for iOS/web. 
      // Replace with your actual machine IP if running on a real device.
      final url = Uri.parse('http://localhost:3000/auth/netflix/simulate');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : 'simulated@netflix.com',
          'name': 'Netflix User',
          'netflixId': 'sim-123456789'
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Netflix Auth Simulated Success!')));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        }
      } else {
        throw 'Backend error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Netflix Auth Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we need to show side-by-side or scrollable
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Flowing Background
          Positioned.fill(
            child: _buildAnimatedBackground(),
          ),
          // Main Body
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                constraints: const BoxConstraints(maxWidth: 900),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 40,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: IntrinsicHeight(
                    child: isDesktop 
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(flex: 5, child: _buildLeftPanel()),
                            Expanded(flex: 5, child: _buildRightPanel()),
                          ],
                        )
                      : Column(
                          children: [
                            _buildLeftPanel(),
                            SizedBox(height: 400, child: _buildRightPanel()),
                          ],
                        ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return MirrorAnimationBuilder<Color?>(
      tween: ColorTween(begin: const Color(0xFFEAE6F9), end: const Color(0xFFD3C8F3)),
      duration: const Duration(seconds: 5),
      builder: (context, value, child) {
        return LoopAnimationBuilder<Alignment>(
          tween: AlignmentTween(begin: Alignment.topLeft, end: Alignment.bottomRight),
          duration: const Duration(seconds: 10),
          builder: (context, alignmentValue, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: alignmentValue,
                  end: Alignment(-alignmentValue.x, -alignmentValue.y),
                  colors: [
                    value ?? const Color(0xFFEAE6F9),
                    const Color(0xFFEAE6F9),
                    const Color(0xFFD3C8F3),
                    value ?? const Color(0xFFEAE6F9),
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 70),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeInDown(
            child: Text(
              "LOGIN",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E1E1E),
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: Text(
              "Lets Take you to excellence and enjoy the application ahead",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ),
          const SizedBox(height: 40),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildTextField(
              controller: _emailController,
              hint: "Username",
              icon: CupertinoIcons.person,
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: _buildTextField(
              controller: _passwordController,
              hint: "Password",
              icon: CupertinoIcons.lock,
              isPassword: true,
            ),
          ),
          const SizedBox(height: 40),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Welcome back!',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: const Color(0xFF6B4FE8),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                // Also redirect on normal login click
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B4FE8),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Text(
                "Login Now",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: Row(
              children: [
                const Expanded(child: Divider(color: Color(0xFFEEEEEE), thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Login with Others",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: Color(0xFFEEEEEE), thickness: 1)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildSocialButton(
              iconWidget: Text(
                "G",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              label: "Login with Google",
              onPressed: _handleGoogleSignIn,
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 700),
            child: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildSocialButton(
              iconWidget: Text(
                "N",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE50914), // Netflix Red
                ),
              ),
              label: "Login with Netflix",
              onPressed: _handleNetflixLogin,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0FF), // Light purple from mockup
        borderRadius: BorderRadius.circular(30), // Pill shape from mockup
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20, right: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: const Color(0xFF6B4FE8)),
              ],
            ),
          ),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: const Color(0xFF9E9E9E),
            fontSize: 15,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required Widget iconWidget,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF1E1E1E), padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: Color(0xFFEEEEEE)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    return Container(
      color: const Color(0xFF6B4FE8),
      child: Stack(
        children: [
          // Background curves
          Positioned.fill(
            child: CustomPaint(
              painter: _CurvePainter(),
            ),
          ),
          // Decorator circle (dark purple)
          Positioned(
            left: -30,
            top: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFF5A3DD8),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Decorator circle (white)
          Positioned(
            right: 40,
            bottom: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Main center image container
          Center(
            child: FadeIn(
              duration: const Duration(seconds: 1),
              child: Container(
                width: 260,
                height: 340,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B75EC),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Center(
                    child: Lottie.asset(
                      "lib/assets/animations/education.json",
                      width: 180,
                      height: 180,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.cast_for_education,
                          color: Colors.white,
                          size: 80,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Decorator circle (yellow !)
          Positioned(
            left: 20,
            top: MediaQuery.of(context).size.height * 0.4,
            child: Bounce(
              infinite: true,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "!",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFFD700),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path1 = Path();
    path1.moveTo(-50, size.height * 0.2);
    path1.quadraticBezierTo(size.width * 0.5, size.height * 0.05, size.width * 1.2, size.height * 0.3);
    canvas.drawPath(path1, paint);

    final path2 = Path();
    path2.moveTo(-50, size.height * 0.4);
    path2.quadraticBezierTo(size.width * 0.6, size.height * 0.3, size.width * 1.2, size.height * 0.6);
    canvas.drawPath(path2, paint);

    final path3 = Path();
    path3.moveTo(size.width * -0.2, size.height * 0.7);
    path3.quadraticBezierTo(size.width * 0.4, size.height * 1.1, size.width * 1.2, size.height * 0.8);
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}