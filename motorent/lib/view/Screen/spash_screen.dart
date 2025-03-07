import 'package:flutter/material.dart';
import 'package:motorent2/view/Screen/sign_in.dart';// Import UserSelectionPage
import 'package:motorent2/view/Screen/welcome_screen.dart';
import 'package:motorent2/view/Utils/colors.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  bool isPressedRegister = false;
  bool isPressedSignIn = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        color: backgroundColor1,
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: size.height * 0.53,
                width: size.width,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  color: backgroundColor5,
                  image: const DecorationImage(
                    image: AssetImage(
                      "images/assets/logom.png",
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.6,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      "Discover your\nDream job Here",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                          color: textColor1,
                          height: 1.2),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      "Explore all the most exciting job roles\nbased on your interest and study major",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: textColor2,
                      ),
                    ),
                    SizedBox(height: size.height * 0.07),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Container(
                        height: size.height * 0.08,
                        width: size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: backgroundColor3.withOpacity(0.9),
                          border: Border.all(color: Colors.white),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12.withOpacity(0.05),
                              spreadRadius: 1,
                              blurRadius: 7,
                              offset: const Offset(0, -1),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTapDown: (_) => setState(() => isPressedRegister = true),
                                onTapUp: (_) {
                                  setState(() => isPressedRegister = false);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const WelcomeScreen(),
                                    ),
                                  );
                                },
                                onTapCancel: () => setState(() => isPressedRegister = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 100),
                                  height: size.height * 0.08,
                                  width: size.width / 2.2,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: isPressedRegister
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: Colors.black26,
                                              offset: Offset(4, 4),
                                              blurRadius: 6,
                                            ),
                                            BoxShadow(
                                              color: Colors.white,
                                              offset: Offset(-4, -4),
                                              blurRadius: 6,
                                            ),
                                          ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Register",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: textColor1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTapDown: (_) => setState(() => isPressedSignIn = true),
                                onTapUp: (_) {
                                  setState(() => isPressedSignIn = false);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SignIn(),
                                    ),
                                  );
                                },
                                onTapCancel: () => setState(() => isPressedSignIn = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 100),
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: backgroundColor3,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: isPressedSignIn
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: Colors.black26,
                                              offset: Offset(4, 4),
                                              blurRadius: 6,
                                            ),
                                            BoxShadow(
                                              color: Colors.white,
                                              offset: Offset(-4, -4),
                                              blurRadius: 6,
                                            ),
                                          ],
                                  ),
                                  child: Text(
                                    "Sign In",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: textColor1,
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
