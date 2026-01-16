import 'package:flutter/material.dart';
import '../theme.dart';
// Import controller baru yang kita buat di atas
import '../controllers/register_controller.dart'; 

class RegisterPage extends StatefulWidget {
  final List<String> selectedGoals;

  const RegisterPage({
    super.key, 
    this.selectedGoals = const [], 
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Panggil Controller khusus halaman ini
  final RegisterController _controller = RegisterController();

  @override
  void dispose() {
    _controller.dispose(); // Controller yang membersihkan memory
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Create Account", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                const SizedBox(height: 8),
                const Text("Sign up to start your journey.", style: TextStyle(fontSize: 16, color: AppTheme.textGrey)),
                const SizedBox(height: 32),

                // View hanya mengikat data dari Controller
                _buildTextField(
                  controller: _controller.nameController, 
                  hintText: "Full Name", 
                  icon: Icons.person_outline
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _controller.emailController, 
                  hintText: "Email Address", 
                  icon: Icons.email_outlined, 
                  inputType: TextInputType.emailAddress
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _controller.passwordController, 
                  hintText: "Password", 
                  icon: Icons.lock_outline, 
                  isPassword: true, 
                  isHidden: _controller.isPasswordHidden, 
                  // Logic pindah ke controller
                  onVisibilityToggle: () => _controller.togglePasswordVisibility(() => setState(() {}))
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _controller.confirmPasswordController, 
                  hintText: "Confirm Password", 
                  icon: Icons.lock_outline, 
                  isPassword: true, 
                  isHidden: _controller.isConfirmPasswordHidden, 
                  onVisibilityToggle: () => _controller.toggleConfirmPasswordVisibility(() => setState(() {}))
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // Logic tombol dipindah ke controller
                    onPressed: _controller.isLoading ? null : () {
                      _controller.submitRegister(
                        context: context,
                        selectedGoals: widget.selectedGoals,
                        onStartLoading: () => setState(() => _controller.isLoading = true),
                        onStopLoading: () => setState(() => _controller.isLoading = false),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.background,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _controller.isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppTheme.background, strokeWidth: 2))
                      : const Text("REGISTER", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? ", style: TextStyle(color: AppTheme.textGrey)),
                    GestureDetector(
                      onTap: () {
                         Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      },
                      child: const Text("Login", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
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

  Widget _buildTextField({
    required TextEditingController controller, required String hintText, required IconData icon,
    bool isPassword = false, bool isHidden = false, TextInputType inputType = TextInputType.text, VoidCallback? onVisibilityToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? isHidden : false,
      keyboardType: inputType,
      style: const TextStyle(color: AppTheme.textWhite),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.cardColor,
        hintText: hintText,
        hintStyle: const TextStyle(color: AppTheme.textGrey),
        prefixIcon: Icon(icon, color: AppTheme.textGrey),
        suffixIcon: isPassword ? IconButton(icon: Icon(isHidden ? Icons.visibility_off : Icons.visibility, color: AppTheme.textGrey), onPressed: onVisibilityToggle) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
      ),
    );
  }
}