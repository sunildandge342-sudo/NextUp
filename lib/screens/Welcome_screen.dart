import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _textScrollAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );

    _textScrollAnimation =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// BACKGROUND IMAGE
          Image.asset(
            'assets/images/welcome.jpg',
            fit: BoxFit.cover,
          ),

          /// SOFT WHITE OVERLAY (PREMIUM)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.82),
                  Colors.white.withOpacity(0.96),
                ],
              ),
            ),
          ),

          /// CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// PUSH CONTENT BELOW CENTER (UX-CORRECT)
                      const Spacer(),
                      const SizedBox(height: 40),

                      /// APP TITLE (PREMIUM TYPOGRAPHY)
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF5B4BDB), // deep purple
                            Color(0xFF6A5AE0), // mid purple-blue
                            Color(0xFF3B82F6), // rich blue (shine)
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          "Smart Queue",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Colors.white, // REQUIRED for ShaderMask
                          ),
                        ),
                      ),



                      const SizedBox(height: 6),

                      Text(
                        "Management System",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 22),

                      /// PREMIUM SCROLLING / MOTION TEXT
                      SlideTransition(
                        position: _textScrollAnimation,
                        child: Text(
                          "Reduce wait time.\nImprove customer experience.\nOperate smarter.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.7,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),

                      /// LIGHT GREEN PREMIUM GRADIENT BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: Container(
                          padding: const EdgeInsets.all(1.5), // ⬅️ creates visible border gap
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),

                            // 🔹 OUTER BORDER (premium ring)
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF9F9AFF), // light lavender border
                                Color(0xFF6EC3FF), // light blue border
                              ],
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),

                              // 🔹 INNER BUTTON GRADIENT (darker, premium)
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF5B4BDB), // deep purple
                                  Color(0xFF2563EB), // rich blue
                                ],
                              ),

                              // 🔹 SOFT DEPTH
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF2563EB).withOpacity(0.35),
                                  blurRadius: 24,
                                  offset: Offset(0, 12),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignUpScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                "Get Started",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),




                      const SizedBox(height: 22),

                      /// LOGIN LINK (SUBTLE, PREMIUM)
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            children: const [
                              TextSpan(
                                text: "Sign In",
                                style: TextStyle(
                                  color: Color(0xFF10B981), // green accent
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),
                    ],
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
