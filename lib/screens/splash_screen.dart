import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _scaleAnim = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
    );
  }

  Widget buildDot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 18 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF7C6FE8)
            : Colors.white24,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F0C29),
              Color(0xFF302B63),
              Color(0xFF24243E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [

            Positioned(
              top: -80,
              left: -80,
              child: buildCircle(300),
            ),

            Positioned(
              bottom: 50,
              right: -50,
              child: buildCircle(220),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const Spacer(),

                      Container(
                        width: 95,
                        height: 95,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white24,
                          ),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: Color(0xFFB3A7FF),
                          size: 48,
                        ),
                      ),

                      const SizedBox(height: 30),

                      AnimatedTextKit(
                        totalRepeatCount: 1,
                        animatedTexts: [
                          TyperAnimatedText(
                            'Smart Campus',
                            speed: const Duration(milliseconds: 80),
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Navigate your campus easily",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),

                      const Spacer(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildDot(true),
                          const SizedBox(width: 6),
                          buildDot(false),
                          const SizedBox(width: 6),
                          buildDot(false),
                        ],
                      ),

                      const SizedBox(height: 40),
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
}