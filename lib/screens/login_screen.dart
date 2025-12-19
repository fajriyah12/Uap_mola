import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:luxora_app/services/auth_service.dart';
import 'package:luxora_app/config/app_theme.dart';
import 'package:luxora_app/screens/signup_screen.dart';
import 'package:luxora_app/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = context.read<AuthService>();
    final error = await authService.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (error == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ===== HEADER IMAGE =====
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            width: double.infinity,
            child: Image.asset(
              'assets/images/back1.png',
              fit: BoxFit.cover,
            ),
          ),

          // ===== OVERLAY =====
          Container(
            height: MediaQuery.of(context).size.height * 0.55,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ===== FORM CARD =====
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.55,
            maxChildSize: 0.75,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 50,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          'Login to your account',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            hintText: 'Email address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Email wajib diisi' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) =>
                              value!.length < 6 ? 'Password minimal 6' : null,
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text('Forgot password?'),
                          ),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text('Login'),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Don’t have an account? '),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SignUpScreen()),
                                );
                              },
                              child: const Text('Sign up'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
