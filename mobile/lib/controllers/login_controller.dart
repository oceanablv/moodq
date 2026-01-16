import 'package:flutter/material.dart';
import 'auth_controller.dart'; // Pastikan path ini benar

class LoginController {
  // 1. Panggil AuthController (Untuk urusan API)
  final AuthController _authAPI = AuthController();

  // 2. Text Controllers (Untuk Input)
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // 3. State Variables (Untuk Tampilan)
  bool isPasswordVisible = false;
  bool isLoading = false;

  // Cleanup memori
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  // Logic: Toggle Password Visibility
  void togglePassword(VoidCallback updateUI) {
    isPasswordVisible = !isPasswordVisible;
    updateUI(); // Refresh UI View
  }

  // Logic UTAMA: Submit Login
  Future<void> submitLogin({
    required BuildContext context,
    required VoidCallback onStartLoading,
    required VoidCallback onStopLoading,
  }) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // A. Validasi Input
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // B. Mulai Loading
    onStartLoading();

    // C. PANGGIL API (Lewat AuthController)
    final result = await _authAPI.login(email, password);

    // D. Selesai Loading
    onStopLoading();

    // E. Cek Hasil
    if (!context.mounted) return;

    if (result['success']) {
      // Navigasi ke Home (session sudah disimpan oleh AuthController)
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Tampilkan Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? "Login Failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}