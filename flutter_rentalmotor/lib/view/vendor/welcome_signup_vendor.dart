import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_rentalmotor/view/vendor/homepage/homepagevendor.dart';

class WelcomeSignupVendorPage extends StatefulWidget {
  const WelcomeSignupVendorPage({Key? key}) : super(key: key);

  @override
  State<WelcomeSignupVendorPage> createState() => _WelcomeSignupCustomerPageState();
}

class _WelcomeSignupCustomerPageState extends State<WelcomeSignupVendorPage> with TickerProviderStateMixin {
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
            ? const Color(0xFF225378).withOpacity(0.3) 
            : (index % 3 == 1
                ? Colors.blue.withOpacity(0.3) 
                : Colors.lightBlueAccent.withOpacity(0.3)), 
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
              Color(0xFF225378), 
              Color(0xFF3A86A8), 
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
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomepageVendor()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF225378), 
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
