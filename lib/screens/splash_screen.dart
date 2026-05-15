import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [

            /// Background decorative circles
            Positioned(
              top: -80,
              left: -80,
              child: _buildCircle(300),
            ),
            Positioned(
              bottom: 60,
              right: -60,
              child: _buildCircle(200),
            ),
            Positioned(
              bottom: 120,
              right: 10,
              child: _buildCircle(120),
            ),

            /// Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const Spacer(),

                      /// Logo box
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C6FE8).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: const Color(0xFF7C6FE8).withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          size: 44,
                          color: Color(0xFF9B8EF8),
                        ),
                      ),

                      const SizedBox(height: 28),

                      /// App name animated
                      AnimatedTextKit(
                        animatedTexts: [
                          TyperAnimatedText(
                            'Smart Campus',
                            textStyle: const TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                            speed: const Duration(milliseconds: 80),
                          ),
                        ],
                        totalRepeatCount: 1,
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Navigate your campus easily",
                        style: TextStyle(
                          color: Color(0x80FFFFFF),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),

                      const Spacer(),

                      /// Dot indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDot(active: true),
                          const SizedBox(width: 6),
                          _buildDot(active: false),
                          const SizedBox(width: 6),
                          _buildDot(active: false),
                        ],
                      ),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildDot({required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 20 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF7C6FE8)
            : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
