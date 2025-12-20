import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:luxora_app/config/app_theme.dart';
import 'package:luxora_app/utils/validators.dart';
import 'package:luxora_app/screens/auth/login_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Password strength indicator
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Calculate password strength
  void _checkPasswordStrength() {
    final password = _newPasswordController.text;
    double strength = 0.0;

    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0.0;
        _passwordStrengthText = '';
      });
      return;
    }

    // Length check
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.1;

    // Contains lowercase
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;

    // Contains uppercase
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;

    // Contains number
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;

    // Contains special character
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.1;

    // Set strength text and color
    String strengthText = '';
    Color strengthColor = Colors.red;

    if (strength <= 0.3) {
      strengthText = 'Lemah';
      strengthColor = Colors.red;
    } else if (strength <= 0.6) {
      strengthText = 'Sedang';
      strengthColor = Colors.orange;
    } else if (strength <= 0.8) {
      strengthText = 'Kuat';
      strengthColor = Colors.blue;
    } else {
      strengthText = 'Sangat Kuat';
      strengthColor = Colors.green;
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthText = strengthText;
      _passwordStrengthColor = strengthColor;
    });
  }

  /// Verify current password by re-authenticating
  Future<bool> _verifyCurrentPassword(String currentPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) return false;

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return false;
      }
      rethrow;
    }
  }

  /// Change password
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User tidak ditemukan');
      }

      // Verify current password
      final isCurrentPasswordCorrect = await _verifyCurrentPassword(
        _currentPasswordController.text,
      );

      if (!isCurrentPasswordCorrect) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password saat ini salah'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
        return;
      }

      // Update password
      await user.updatePassword(_newPasswordController.text);

      setState(() => _isLoading = false);

      if (!mounted) return;

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.successColor),
              SizedBox(width: 12),
              Text('Berhasil!'),
            ],
          ),
          content: const Text(
            'Password Anda telah berhasil diubah. Silakan login kembali dengan password baru Anda.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Sign out user
                await FirebaseAuth.instance.signOut();

                if (mounted) {
                  // Navigate to login screen
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);

      String errorMessage = 'Terjadi kesalahan';

      if (e.code == 'weak-password') {
        errorMessage = 'Password terlalu lemah';
      } else if (e.code == 'requires-recent-login') {
        errorMessage = 'Silakan login ulang untuk mengubah password';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Setelah mengubah password, Anda akan diminta untuk login kembali dengan password baru.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Current Password
              const Text(
                'Password Saat Ini',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                decoration: InputDecoration(
                  hintText: 'Masukkan password saat ini',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrentPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                  ),
                ),
                validator: (value) =>
                    Validators.validateRequired(value, 'Password saat ini'),
              ),

              const SizedBox(height: 24),

              // New Password
              const Text(
                'Password Baru',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                decoration: InputDecoration(
                  hintText: 'Masukkan password baru',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                ),
                validator: Validators.validatePassword,
              ),

              // Password Strength Indicator
              if (_newPasswordController.text.isNotEmpty) ...[
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _passwordStrength,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation(
                                _passwordStrengthColor,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _passwordStrengthText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _passwordStrengthColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gunakan kombinasi huruf besar, huruf kecil, angka, dan simbol',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // Confirm New Password
              const Text(
                'Konfirmasi Password Baru',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  hintText: 'Konfirmasi password baru',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: (value) => Validators.validateConfirmPassword(
                  value,
                  _newPasswordController.text,
                ),
              ),

              const SizedBox(height: 32),

              // Password Requirements
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Persyaratan Password:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PasswordRequirement(
                      text: 'Minimal 6 karakter',
                      isMet: _newPasswordController.text.length >= 6,
                    ),
                    _PasswordRequirement(
                      text: 'Mengandung huruf besar (A-Z)',
                      isMet: _newPasswordController.text
                          .contains(RegExp(r'[A-Z]')),
                    ),
                    _PasswordRequirement(
                      text: 'Mengandung huruf kecil (a-z)',
                      isMet: _newPasswordController.text
                          .contains(RegExp(r'[a-z]')),
                    ),
                    _PasswordRequirement(
                      text: 'Mengandung angka (0-9)',
                      isMet: _newPasswordController.text
                          .contains(RegExp(r'[0-9]')),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Ubah Password'),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget for password requirement indicator
class _PasswordRequirement extends StatelessWidget {
  final String text;
  final bool isMet;

  const _PasswordRequirement({
    required this.text,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: isMet ? AppTheme.successColor : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isMet ? AppTheme.textPrimary : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}