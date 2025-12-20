import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReauthEmailScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const ReauthEmailScreen({super.key, required this.data});

  @override
  State<ReauthEmailScreen> createState() => _ReauthEmailScreenState();
}

class _ReauthEmailScreenState extends State<ReauthEmailScreen> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _confirmChange() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final currentEmail = widget.data['currentEmail'];
      final newEmail = widget.data['newEmail'];

      // 🔐 1. Re-authentication (WAJIB)
      final credential = EmailAuthProvider.credential(
        email: currentEmail,
        password: _passwordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);

      // 2️⃣ Kirim email verifikasi ke EMAIL BARU
await user.verifyBeforeUpdateEmail(newEmail);

// 3️⃣ Update status saja (JANGAN delete, JANGAN logout)
await FirebaseFirestore.instance
    .collection('email_change_temp')
    .doc(user.uid)
    .update({
  'status': 'waiting_verification',
});

if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Email verifikasi telah dikirim ke EMAIL BARU. Silakan cek inbox atau spam.',
      ),
    ),
  );

  Navigator.pop(context);
}

    } catch (e) {
      setState(() {
        _error = 'Password salah atau sesi login kadaluarsa';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Password'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Konfirmasi Perubahan Email',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Email lama: ${widget.data['currentEmail']}',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              'Email baru: ${widget.data['newEmail']}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Saat Ini',
                border: OutlineInputBorder(),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmChange,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Konfirmasi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
