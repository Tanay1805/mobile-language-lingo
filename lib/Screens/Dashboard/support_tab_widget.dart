import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class SupportTabWidget extends StatefulWidget {
  const SupportTabWidget({super.key});

  @override
  State<SupportTabWidget> createState() => _SupportTabWidgetState();
}

class _SupportTabWidgetState extends State<SupportTabWidget> with SingleTickerProviderStateMixin {
  // Player state
  double _playerX = 50.0;
  double _playerY = 0.0; // 0 is ground level (bottom)
  final double _playerSize = 40.0;
  
  // Jump physics
  bool _isJumping = false;
  late AnimationController _jumpController;
  late Animation<double> _jumpAnimation;
  
  // Game state
  String? _selectedSupport;

  // Blocks (Support Options)
  final List<Map<String, dynamic>> _blocks = [
    {
      'label': 'Email Us',
      'icon': Icons.email,
      'x': 250.0,
      'y': 120.0, // Height from ground
      'color': const Color(0xFF6B4FE8)
    },
    {
      'label': 'Live Chat',
      'icon': Icons.chat_bubble,
      'x': 500.0,
      'y': 150.0,
      'color': const Color(0xFF26D390)
    },
    {
      'label': 'FAQ',
      'icon': Icons.help,
      'x': 750.0,
      'y': 120.0,
      'color': const Color(0xFFFF9421)
    },
  ];

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _jumpAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 180.0).chain(CurveTween(curve: Curves.easeOutQuad)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 180.0, end: 0.0).chain(CurveTween(curve: Curves.easeInQuad)), weight: 50),
    ]).animate(_jumpController);
    
    _jumpController.addListener(() {
      setState(() {
        _playerY = _jumpAnimation.value;
      });
      _checkHit(jumping: _jumpController.isAnimating);
    });

    _jumpController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _jumpController.reset();
        _isJumping = false;
      }
    });
  }

  @override
  void dispose() {
    _jumpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _moveLeft() {
    if (_selectedSupport != null) return;
    setState(() {
      _playerX -= 30.0;
      if (_playerX < 0) _playerX = 0;
    });
  }

  void _moveRight() {
    if (_selectedSupport != null) return;
    setState(() {
      _playerX += 30.0;
      if (_playerX > 1000) _playerX = 1000; 
    });
  }

  void _jump() {
    if (_selectedSupport != null || _isJumping) return;
    _isJumping = true;
    _jumpController.forward();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _moveLeft();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _moveRight();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp || event.logicalKey == LogicalKeyboardKey.space) {
        _jump();
      }
    }
  }

  void _checkHit({bool jumping = false}) {
    if (!jumping || _selectedSupport != null) return;

    final playerLeft = _playerX;
    final playerRight = _playerX + _playerSize;
    final playerTop = _playerY + _playerSize; 

    for (var block in _blocks) {
      final blockLeft = block['x'];
      final blockRight = block['x'] + 80;
      final blockBottom = block['y'];
      
      // If player peak hits bottom of block
      if (playerTop >= blockBottom && 
          playerTop <= blockBottom + 20 && 
          playerRight > blockLeft && 
          playerLeft < blockRight) {
        
        setState(() {
          _selectedSupport = block['label'];
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKeyEvent,
      autofocus: true,
      child: Container(
        height: 650, // Making it large ("full screen there")
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.lightBlue.shade50,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.blue.shade200, width: 2),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Background Elements (Clouds)
            Positioned(top: 50, left: 100, child: Icon(Icons.cloud, color: Colors.white, size: 80)),
            Positioned(top: 100, left: 400, child: Icon(Icons.cloud, color: Colors.white, size: 100)),
            Positioned(top: 30, right: 150, child: Icon(Icons.cloud, color: Colors.white, size: 60)),

            // UI Text Overlay
            Positioned(
              top: 24,
              left: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Support World 1-1",
                    style: GoogleFonts.pressStart2p(
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Use Arrow Keys (← → Space) or on-screen buttons to jump and hit a block!",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Game Area (Offsets calculated from bottom)
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final groundHeight = 90.0;
                  return Stack(
                    children: [
                      // Ground floor
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: groundHeight,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF8B4513), 
                            border: Border(top: BorderSide(color: Color(0xFF5C2e0e), width: 8)),
                          ),
                          child: Stack(
                            children: List.generate(
                              20, 
                              (index) => Positioned(
                                left: index * 60.0,
                                top: 20,
                                child: Icon(Icons.grass, color: Colors.green.shade800, size: 24),
                              )
                            )
                          ),
                        ),
                      ),

                      // Target Blocks
                      ..._blocks.map((block) {
                        return Positioned(
                          left: block['x'],
                          bottom: groundHeight + block['y'],
                          child: Container(
                            width: 80,
                            height: 60,
                            decoration: BoxDecoration(
                              color: block['color'],
                              border: Border.all(color: Colors.black87, width: 3),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(4, 4),
                                )
                              ]
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(block['icon'], color: Colors.white, size: 20),
                                  const SizedBox(height: 4),
                                  Text(
                                    block['label'].toString(),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                      // Player
                      Positioned(
                        left: _playerX,
                        bottom: groundHeight + _playerY,
                        child: Icon(
                          Icons.engineering, 
                          size: _playerSize,
                          color: Colors.red.shade800,
                        ),
                      ),
                    ],
                  );
                }
              ),
            ),

            // On-screen Game Controls
            if (_selectedSupport == null)
              Positioned(
                bottom: 16,
                left: 24,
                right: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildControlButton(Icons.arrow_back, _moveLeft),
                        const SizedBox(width: 16),
                        _buildControlButton(Icons.arrow_forward, _moveRight),
                      ],
                    ),
                    _buildControlButton(Icons.arrow_upward, _jump, isAction: true),
                  ],
                ),
              ),

             // Support Content Overlay (Opened upon hitting a block)
            if (_selectedSupport != null)
              Positioned.fill(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          color: _blocks.firstWhere((b) => b['label'] == _selectedSupport)['color'],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(_blocks.firstWhere((b) => b['label'] == _selectedSupport)['icon'], color: Colors.white, size: 28),
                                const SizedBox(width: 12),
                                Text(
                                  "$_selectedSupport",
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, size: 30),
                              onPressed: () {
                                setState(() {
                                  _selectedSupport = null;
                                  _focusNode.requestFocus();
                                });
                              },
                            )
                          ],
                        ),
                      ),
                      
                      // Content Body
                      Expanded(
                        child: _buildContentBody(_selectedSupport!),
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentBody(String type) {
    if (type == 'Email Us') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_read, size: 80, color: Color(0xFF6B4FE8)),
            const SizedBox(height: 24),
            Text(
              "Reach out to our team directly:",
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                "support@lingolearn.com",
                style: GoogleFonts.poppins(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: const Color(0xFF6B4FE8)
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "We generally reply within 24 hours.",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    } else if (type == 'FAQ') {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          _buildFaqItem("How do I book a lesson?", "Go to the Schedule tab, find your target language session, and click \"Book Session\" to be taken to the mentor's Calendly page."),
          _buildFaqItem("How are flashcards generated?", "Whenever you get a quiz question wrong, our AI dynamically creates a custom flashcard with an explanation and mnemonic specific to what you missed."),
          _buildFaqItem("Can I change my target language?", "Currently, language is chosen implicitly based on the Netflix series you decide to watch from the Content Courses tab."),
          _buildFaqItem("When will new courses be added?", "We update our AI context dictionaries monthly to include new trending Netflix shows!"),
        ],
      );
    } else if (type == 'Live Chat') {
      return const LiveChatWidget();
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF9F9FB),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: ExpansionTile(
        title: Text(
          question, 
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87)
        ),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          Text(answer, style: GoogleFonts.poppins(color: Colors.black54, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed, {bool isAction = false}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isAction ? Colors.redAccent : Colors.white.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          boxShadow: const [
             BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 4,
            )
          ],
          border: Border.all(
            color: isAction ? Colors.red.shade900 : Colors.grey.shade300, 
            width: 2
          )
        ),
        child: Icon(
          icon, 
          size: 28, 
          color: isAction ? Colors.white : Colors.black87
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// Live Chat Interactive Mistral UI
// ---------------------------------------------------------

class LiveChatWidget extends StatefulWidget {
  const LiveChatWidget({super.key});

  @override
  State<LiveChatWidget> createState() => _LiveChatWidgetState();
}

class _LiveChatWidgetState extends State<LiveChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {"role": "assistant", "content": "Hi there! I am LingoLearn's AI Support. How can I help you today?"}
  ];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": text});
      _isLoading = true;
      _controller.clear();
    });
    
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/chat/support'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': text,
          'previousMessages': _messages.sublist(0, _messages.length - 1).map((m) => {
             "role": m["role"],
             "content": m["content"]
          }).toList()
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _messages.add({"role": "assistant", "content": data['reply']});
        });
      } else {
        setState(() {
          _messages.add({"role": "assistant", "content": "Sorry, I am having trouble connecting to the support server right now."});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({"role": "assistant", "content": "Network error offline."});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(24),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isUser = msg['role'] == 'user';
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF6B4FE8) : const Color(0xFFF0F0F5),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 0),
                      bottomRight: Radius.circular(isUser ? 0 : 20),
                    ),
                  ),
                  child: Text(
                    msg['content']!,
                    style: GoogleFonts.poppins(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(color: Color(0xFF26D390)),
          ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(0, -4),
                blurRadius: 10,
              )
            ]
          ),
          child: Row(
             children: [
               Expanded(
                 child: Container(
                   decoration: BoxDecoration(
                     color: const Color(0xFFF9F9FB),
                     borderRadius: BorderRadius.circular(30),
                     border: Border.all(color: Colors.grey.shade300),
                   ),
                   padding: const EdgeInsets.symmetric(horizontal: 20),
                   child: TextField(
                     controller: _controller,
                     decoration: const InputDecoration(
                       border: InputBorder.none,
                       hintText: "Type a message...",
                     ),
                     onSubmitted: (_) => _sendMessage(),
                   ),
                 ),
               ),
               const SizedBox(width: 16),
               GestureDetector(
                 onTap: _sendMessage,
                 child: Container(
                   padding: const EdgeInsets.all(14),
                   decoration: const BoxDecoration(
                     color: Color(0xFF26D390),
                     shape: BoxShape.circle,
                   ),
                   child: const Icon(Icons.send, color: Colors.white),
                 ),
               )
             ],
          ),
        ),
      ],
    );
  }
}
