import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:image_picker/image_picker.dart';
import '../dashboard/dashboard_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLogin = true; // Toggle between Login and Sign Up
  Uint8List? _profileImageBytes;
  String? _profileImageExt;
  
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
        _profileImageExt = pickedFile.name.split('.').last;
      });
    }
  }

  Future<void> _handleAuth() async {
    setState(() { _isLoading = true; });
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      
      if (email.isEmpty || password.isEmpty) {
        throw 'Please enter email and password';
      }

      if (_isLogin) {
        // --- LOGIN FLOW ---
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (response.user != null) {
          if (mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
          }
        }
      } else {
        // --- SIGN UP FLOW ---
        final username = _usernameController.text.trim();
        if (username.isEmpty) throw 'Please enter a username';
        
        // 1. Create the user in Auth
        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: {'username': username},
        );
        
        if (response.user != null) {
          // Explicitly log the user in if the session didn't auto-populate (fixes 400 auth missing error)
          if (response.session == null) {
            await Supabase.instance.client.auth.signInWithPassword(
              email: email,
              password: password,
            );
          }

          String? avatarUrl;
          
          // 2. Upload Profile Picture if selected
          if (_profileImageBytes != null) {
            final fileExt = _profileImageExt ?? 'jpg';
            final fileName = '${response.user!.id}.$fileExt';
            
            // Bypass Flutter Web SDK bug where uploadBinary drops API keys on binary/blob construction
            final uploadUrl = Uri.parse('https://vntakbqalzorqxopxxul.supabase.co/storage/v1/object/avatars/$fileName');
            final uploadResponse = await http.post(
              uploadUrl,
              headers: {
                'Authorization': 'Bearer ${response.session!.accessToken}',
                'apikey': 'sb_publishable_Pm7o73nIZwHOeLBGtbUBVQ_DwEShQiV',
                'Content-Type': 'image/$fileExt',
                'x-upsert': 'true',
              },
              body: _profileImageBytes!,
            );
            
            if (uploadResponse.statusCode >= 400) {
               throw 'Storage Upload Failed: ${uploadResponse.body}';
            }
              
            avatarUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(fileName);
            
            // Update Auth Metadata with actual URL
            await Supabase.instance.client.auth.updateUser(
              UserAttributes(data: {'avatar_url': avatarUrl, 'username': username}),
            );
            
            // Manual profile update if the trigger didn't catch the photo in time
            await Supabase.instance.client.from('profiles').upsert({
              'id': response.user!.id,
              'username': username,
              'email': email,
              'avatar_url': avatarUrl,
            });
          } else {
             await Supabase.instance.client.from('profiles').upsert({
              'id': response.user!.id,
              'username': username,
              'email': email,
            });
          }
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account Created Successfully!')));
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Auth Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() { _isLoading = true; });
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.languagelearner://login-callback',
      );
      // Supabase handles the deep link return natively on mobile
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
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
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeInDown(
            child: Text(
              _isLogin ? "LOGIN" : "CREATE ACCOUNT",
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
              _isLogin ? "Welcome back! Let's get learning." : "Join LingoLearn and excel today.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          // Image Picker (Only shown on Sign Up)
          if (!_isLogin)
            FadeInDown(
              child: Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: const Color(0xFFF4F0FF),
                    backgroundImage: _profileImageBytes != null ? MemoryImage(_profileImageBytes!) : null,
                    child: _profileImageBytes == null 
                      ? const Icon(CupertinoIcons.camera, size: 30, color: Color(0xFF6B4FE8))
                      : null,
                  ),
                ),
              ),
            ),
            
          if (!_isLogin) const SizedBox(height: 20),

          // Username Field (Only shown on Sign Up)
          if (!_isLogin)
            FadeInUp(
              delay: const Duration(milliseconds: 150),
              child: _buildTextField(
                controller: _usernameController,
                hint: "Username",
                icon: CupertinoIcons.person,
              ),
            ),
          if (!_isLogin) const SizedBox(height: 20),

          // Email Field
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildTextField(
              controller: _emailController,
              hint: "Email Address",
              icon: CupertinoIcons.mail,
            ),
          ),
          const SizedBox(height: 20),

          // Password Field
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: _buildTextField(
              controller: _passwordController,
              hint: "Password",
              icon: CupertinoIcons.lock,
              isPassword: true,
            ),
          ),
          const SizedBox(height: 30),

          // Auth Button
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4FE8),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isLogin ? "Login Now" : "Sign Up",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
          ),
          
          const SizedBox(height: 16),
          
          // Toggle Login/SignUp
          FadeInUp(
            delay: const Duration(milliseconds: 450),
            child: TextButton(
              onPressed: () {
                setState(() { _isLogin = !_isLogin; });
              },
              child: Text(
                _isLogin ? "Don't have an account? Sign Up" : "Already have an account? Sign In",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF6B4FE8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: Row(
              children: [
                const Expanded(child: Divider(color: Color(0xFFEEEEEE), thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Or continue with",
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
          const SizedBox(height: 20),
          
          // Google Button
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: _buildSocialButton(
              iconWidget: Text(
                "G",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              label: "Google",
              onPressed: _handleGoogleSignIn,
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
        color: const Color(0xFFF4F0FF),
        borderRadius: BorderRadius.circular(30),
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
          Positioned.fill(
            child: CustomPaint(
              painter: _CurvePainter(),
            ),
          ),
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
                          CupertinoIcons.book_fill,
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