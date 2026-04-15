import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  bool isLogin = true;
  bool isLoading = false;
  bool obscurePassword = true;

  final emailCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  Future<void> handleSignup() async {
    // Validation
    if (usernameCtrl.text.isEmpty || usernameCtrl.text.length < 3) {
      showErrorSnackBar('Username must be at least 3 characters');
      return;
    }
    if (emailCtrl.text.isEmpty || !isValidEmail(emailCtrl.text)) {
      showErrorSnackBar('Invalid email format');
      return;
    }
    if (passwordCtrl.text.isEmpty || passwordCtrl.text.length < 6) {
      showErrorSnackBar('Password must be at least 6 characters');
      return;
    }

    setState(() => isLoading = true);

    final result = await AuthService.signup(
      username: usernameCtrl.text,
      email: emailCtrl.text,
      password: passwordCtrl.text,
    );

    setState(() => isLoading = false);

    if (result['success']) {
      showSuccessSnackBar('Signup successful! Please login');
      setState(() => isLogin = true);
      emailCtrl.clear();
      usernameCtrl.clear();
      passwordCtrl.clear();
    } else {
      showErrorSnackBar(result['message']);
    }
  }

  Future<void> handleLogin() async {
    // Validation
    if (emailCtrl.text.isEmpty || !isValidEmail(emailCtrl.text)) {
      showErrorSnackBar('Invalid email format');
      return;
    }
    if (passwordCtrl.text.isEmpty) {
      showErrorSnackBar('Password cannot be empty');
      return;
    }

    setState(() => isLoading = true);

    final result = await AuthService.login(
      email: emailCtrl.text,
      password: passwordCtrl.text,
    );

    setState(() => isLoading = false);

    if (result['success']) {
      showSuccessSnackBar('Login successful!');
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      showErrorSnackBar(result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              children: [
                // LOGO
                const Text(
                  'MusicApp',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // TOGGLE BUTTON
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isLogin = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isLogin ? Colors.green : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Text(
                            'Login',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isLogin = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isLogin ? Colors.green : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Text(
                            'Signup',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // EMAIL FIELD
                TextField(
                  controller: emailCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.email, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.green),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // USERNAME FIELD (Only for Signup)
                if (!isLogin)
                  Column(
                    children: [
                      TextField(
                        controller: usernameCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Username',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.person, color: Colors.green),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.green),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.green, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // PASSWORD FIELD
                TextField(
                  controller: passwordCtrl,
                  obscureText: obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.lock, color: Colors.green),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => obscurePassword = !obscurePassword),
                      child: Icon(
                        obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.green,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.green),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // SUBMIT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : (isLogin ? handleLogin : handleSignup),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            isLogin ? 'Login' : 'Signup',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // FORGOT PASSWORD (Login only)
                if (isLogin)
                  GestureDetector(
                    onTap: () {
                      showErrorSnackBar('Forgot Password feature coming soon!');
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }
}