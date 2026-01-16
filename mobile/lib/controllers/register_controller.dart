import 'package:flutter/material.dart';
import 'auth_controller.dart'; 

class RegisterController {
  
  final AuthController _authRepo = AuthController();

  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  
  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;
  bool isLoading = false;

  
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  
  void togglePasswordVisibility(VoidCallback updateUI) {
    isPasswordHidden = !isPasswordHidden;
    updateUI(); 
  }

  void toggleConfirmPasswordVisibility(VoidCallback updateUI) {
    isConfirmPasswordHidden = !isConfirmPasswordHidden;
    updateUI();
  }

  
  Future<void> submitRegister({
    required BuildContext context,
    required List<String> selectedGoals,
    required VoidCallback onStartLoading,
    required VoidCallback onStopLoading,
  }) async {
    
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match"), backgroundColor: Colors.red),
      );
      return;
    }

    
    onStartLoading();

    
    final result = await _authRepo.register(
      nameController.text,
      emailController.text,
      passwordController.text,
      selectedGoals,
    );

    
    onStopLoading();

    
    if (!context.mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration Successful!"), backgroundColor: Colors.green),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Failed"), backgroundColor: Colors.red),
      );
    }
  }
}