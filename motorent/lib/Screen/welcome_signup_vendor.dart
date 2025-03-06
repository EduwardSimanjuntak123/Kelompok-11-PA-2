import 'package:flutter/material.dart';
import 'dart:math' as math;

class WelcomeSignupVendorPage extends StatefulWidget {
  const WelcomeSignupVendorPage({Key? key}) : super(key: key);

  @override
  State<WelcomeSignupVendorPage> createState() => _WelcomeSignupVendorPageState();
}

class _WelcomeSignupVendorPageState extends State<WelcomeSignupVendorPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _bubbleController;
  late List<BubbleAnimation> _bubbles;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
    
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    )..repeat();
    
    _bubbles = List.generate(15, (index) {
      return BubbleAnimation(
        size: math.Random().nextDouble() * 40 + 10,
        position: Offset(
          math.Random().nextDouble() * 300,
          math.Random().nextDouble() * 600,
        ),
        color: index % 3 == 0 
            ? Colors.pink.withOpacity(0.3) 
            : (index % 3 == 1 
                ? Colors.orange.withOpacity(0.3) 
                : Colors.yellow.withOpacity(0.3)),
        speed: math.Random().nextDouble() * 2 + 1,
      );
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF9AA2), // Light pink
              Color(0xFFFFB347), // Light orange
            ],
          ),
        ),
        child: Stack(
          children: [
            ...buildBubbles(),
            
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(flex: 2),
                    
                    FadeTransition(
                      opacity: _fadeController,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _fadeController,
                          curve: Curves.easeOut,
                        )),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Welcome, Vendor!',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Your account has been successfully created.\nLet\'s get started!',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const Spacer(flex: 3),
                    
                    FadeTransition(
                      opacity: _fadeController,
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text('Dashboard'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.pink,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text('Next'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildBubbles() {
    return _bubbles.map((bubble) {
      return AnimatedBuilder(
        animation: _bubbleController,
        builder: (context, child) {
          final value = _bubbleController.value;
          final yOffset = math.sin(value * math.pi * 2 * bubble.speed) * 10;
          
          return Positioned(
            left: bubble.position.dx,
            top: bubble.position.dy + yOffset,
            child: Container(
              width: bubble.size,
              height: bubble.size,
              decoration: BoxDecoration(
                color: bubble.color,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      );
    }).toList();
  }
}

class BubbleAnimation {
  final double size;
  final Offset position;
  final Color color;
  final double speed;

  BubbleAnimation({
    required this.size,
    required this.position,
    required this.color,
    required this.speed,
  });
}

