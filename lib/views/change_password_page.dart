import 'package:flutter/material.dart';
import '../theme.dart';
import '../controllers/auth_controller.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['email'] != null) {
      _emailController.text = args['email'];
    }
  }

  Future<void> _changePassword() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text;
    final conf = _confirmController.text;
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email is required')));
      return;
    }

    if (pass.isEmpty || conf.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill password fields')));
      return;
    }

    if (pass != conf) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _isLoading = true);
    final api = AuthController();

    // Verify email exists first (call request_reset which checks registration)
    final check = await api.requestPasswordReset(email);
    if (check['success'] != true) {
      setState(() => _isLoading = false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(check['message'] ?? 'Email not registered')));
      return;
    }

    // Proceed to change password
    final res = await api.changePassword(email, pass);
    setState(() => _isLoading = false);

    if (!context.mounted) return;

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed successfully')));
      Navigator.popUntil(context, ModalRoute.withName('/login'));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Failed to change password')));
    }
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
                const Text("Change Password", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                const SizedBox(height: 8),
                const Text("Set a new password for your account.", style: TextStyle(color: AppTheme.textGrey, fontSize: 16)),
                const SizedBox(height: 32),

                TextField(
                  controller: _emailController,
                  readOnly: true,
                  style: const TextStyle(color: AppTheme.textWhite),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.cardColor,
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textGrey),
                    hintText: 'Email',
                    hintStyle: const TextStyle(color: AppTheme.textGrey),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _passwordController,
                  hintText: 'New Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  isVisible: _isPasswordVisible,
                  toggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _confirmController,
                  hintText: 'Confirm Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  isVisible: _isConfirmVisible,
                  toggleVisibility: () => setState(() => _isConfirmVisible = !_isConfirmVisible),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.background,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppTheme.background, strokeWidth: 2)) : const Text('CHANGE PASSWORD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Remembered your password? ", style: TextStyle(color: AppTheme.textGrey)),
                    TextButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
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
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !isVisible : false,
      style: const TextStyle(color: AppTheme.textWhite),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.cardColor,
        prefixIcon: Icon(icon, color: AppTheme.textGrey),
        hintText: hintText,
        hintStyle: const TextStyle(color: AppTheme.textGrey),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppTheme.textGrey,
                ),
                onPressed: toggleVisibility,
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
      ),
    );
  }
}
