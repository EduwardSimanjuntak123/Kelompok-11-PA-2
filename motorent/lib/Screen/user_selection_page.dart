import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:motorent2/Screen/sign_up_vendor_screen.dart';
import 'package:motorent2/Screen/sign_up_customer.dart';

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                child: AnimatedTextKit(
                  repeatForever: true,
                  animatedTexts: [
                    FadeAnimatedText("Pilih Tipe Pengguna"),
                    FadeAnimatedText("Apakah Anda Pelanggan?"),
                    FadeAnimatedText("Atau Seorang Vendor?"),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpCustomer(),
                    ),
                  );
                },
                child: const MyButtonItems(
                  color: Colors.blueAccent,
                  child: Text(
                    "Pelanggan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpScreen(),
                    ),
                  );
                },
                child: const MyButtonItems(
                  color: Colors.orangeAccent,
                  child: Text(
                    "Vendor",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyButtonItems extends StatefulWidget {
  final Widget child;
  final Color color;
  const MyButtonItems({super.key, required this.child, required this.color});

  @override
  State<MyButtonItems> createState() => _MyButtonItemsState();
}

class _MyButtonItemsState extends State<MyButtonItems>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward(from: 0.0);
      }
    });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, index) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(15),
          width: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(colors: [
              Colors.purple,
              widget.color,
              Colors.blue,
            ], stops: [
              0.0,
              controller.value,
              1.0,
            ]),
          ),
          child: widget.child,
        );
      },
    );
  }
}

