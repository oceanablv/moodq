import 'package:flutter/material.dart';
import '../theme.dart';
import '../controllers/login_controller.dart'; // Import Controller Login yang baru

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Panggil Controller Khusus Halaman Ini
  final LoginController _controller = LoginController();

  @override
  void dispose() {
    _controller.dispose(); // Bersihkan memori controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header ---
                const Text(
                  "Welcome Back!",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textWhite),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Sign in to continue your journey.",
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 16),
                ),
                const SizedBox(height: 40),

                // --- Input Email (Pake Controller) ---
                _buildTextField(
                  controller: _controller.emailController,
                  hintText: "Email Address",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // --- Input Password (Pake Controller) ---
                _buildPasswordField(),
                const SizedBox(height: 8),

                // --- Forgot Password Link ---
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot_password');
                    },
                    child: const Text('Forgot password?', style: TextStyle(color: AppTheme.primaryColor)),
                  ),
                ),

                const SizedBox(height: 22),

                // --- Tombol Login ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // Logic dipindah ke Controller
                    onPressed: _controller.isLoading ? null : () {
                      _controller.submitLogin(
                        context: context,
                        onStartLoading: () => setState(() => _controller.isLoading = true),
                        onStopLoading: () => setState(() => _controller.isLoading = false),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.background,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.5),
                    ),
                    child: _controller.isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppTheme.background, strokeWidth: 2))
                        : const Text("LOGIN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 20),

                // --- Register Link ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: AppTheme.textGrey)),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text("Register", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widget TextField Biasa ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textWhite),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.cardColor,
        prefixIcon: Icon(icon, color: AppTheme.textGrey),
        hintText: hintText,
        hintStyle: const TextStyle(color: AppTheme.textGrey),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
      ),
    );
  }

  // --- Helper Widget Password Field ---
  Widget _buildPasswordField() {
    return TextField(
      controller: _controller.passwordController, // Pakai variable controller
      obscureText: !_controller.isPasswordVisible, // Pakai variable controller
      style: const TextStyle(color: AppTheme.textWhite),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.cardColor,
        prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textGrey),
        hintText: "Password",
        hintStyle: const TextStyle(color: AppTheme.textGrey),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        suffixIcon: IconButton(
          icon: Icon(
            _controller.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: AppTheme.textGrey,
          ),
          // Logic Toggle pindah ke controller
          onPressed: () {
            _controller.togglePassword(() => setState(() {}));
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
      ),
    );
  }
}