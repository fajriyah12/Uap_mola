import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:luxora_app/services/auth_service.dart';
import 'package:luxora_app/config/app_theme.dart';
import 'package:luxora_app/screens/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final error = await authService.signUpWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (error == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ================= HEADER IMAGE =================
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
            child: Image.asset(
              'assets/images/back1.png',
              fit: BoxFit.cover,
            ),
          ),

          // ================= OVERLAY =================
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.45),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ================= BACK BUTTON =================
          SafeArea(
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // ================= FORM CARD =================
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.65,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
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
                          'Create your account',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ===== FULL NAME =====
                        TextFormField(
                          controller: _fullNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama lengkap harus diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ===== EMAIL =====
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Email Address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email harus diisi';
                            }
                            if (!value.contains('@')) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ===== PHONE =====
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nomor telepon harus diisi';
                            }
                            if (value.length < 10) {
                              return 'Nomor telepon tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ===== PASSWORD =====
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password harus diisi';
                            }
                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ===== CONFIRM PASSWORD =====
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Konfirmasi password harus diisi';
                            }
                            if (value != _passwordController.text) {
                              return 'Password tidak sama';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // ===== BUTTON =====
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signUp,
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Text('Sign Up'),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ===== LOGIN LINK =====
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Already have an account? '),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Login'),
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
