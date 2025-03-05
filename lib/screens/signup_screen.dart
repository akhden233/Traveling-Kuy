import 'package:flutter/material.dart';
import 'signin_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Mencegah overflow saat keyboard muncul
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/background_signup.png',
                fit: BoxFit.cover,
              ),
            ),

            // Gambar Sign Up di tengah atas dengan transparansi
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Opacity(
                  opacity: 0.6,
                  child: Image.asset('assets/signup.png', width: 200),
                ),
              ),
            ),

            // Form Sign Up
            Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildInputField(
                        Icons.person,
                        "Full Name",
                        "Enter your full name",
                      ),
                      const SizedBox(height: 15),
                      buildInputField(Icons.email, "Email", "Enter your email"),
                      const SizedBox(height: 15),
                      buildInputField(
                        Icons.lock,
                        "Password",
                        "Enter your password",
                        obscureText: true,
                      ),
                      const SizedBox(height: 15),

                      // Tombol Sign Up
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: () {
                            // Navigasi ke halaman Sign In setelah Sign Up
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SigninScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Login dengan Social Media
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/google.png", width: 30),
                          const SizedBox(width: 20),
                          Image.asset("assets/apple.png", width: 30),
                          const SizedBox(width: 20),
                          Image.asset("assets/facebook.png", width: 30),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Navigasi ke Sign In
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SigninScreen(),
                            ),
                          );
                        },
                        child: const Text("Already have an account? Sign In"),
                      ),
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

  Widget buildInputField(
    IconData icon,
    String label,
    String hint, {
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextField(
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[300],
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
