import '../backend/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../backend/providers/auth_provider.dart';
import '../screens/signin_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

// Logika Backend Fitur Autentikasi Sign Up
class SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  void _signUp() async {
    if (!mounted) return;

    // Validate input fields
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All fields must be filled!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiServices.signup(
        nameController.text,
        emailController.text,
        passwordController.text,
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      // Show success message and navigate regardless of backend message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please sign in.'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to sign in screen after a short delay to allow the snackbar to be visible
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SigninScreen()),
          );
        }
      });
      
    } catch (e) {
      if (!mounted) return;
      
      setState(() => isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${e.toString()}'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }

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
                  child: Image.asset('assets/signup.png', width: 150),
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
                        controller: nameController,
                      ),
                      const SizedBox(height: 15),
                      buildInputField(
                        Icons.email,
                        "Email",
                        "Enter your email",
                        controller: emailController,
                      ),
                      const SizedBox(height: 15),
                      buildInputField(
                        Icons.lock,
                        "Password",
                        "Enter your password",
                        obscureText: true,
                        controller: passwordController,
                      ),
                      const SizedBox(height: 15),

                      // Tombol Sign Up
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(47, 73, 44, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: _signUp,
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
    TextEditingController? controller,
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
          controller: controller,
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
