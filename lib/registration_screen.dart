import 'package:flutter/material.dart';
import 'profile_setup_screen.dart';
import 'services/auth_service.dart';
import 'app_data.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    bool hasError = false;

    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      hasError = true;
    } else if (!email.contains('@') || !email.contains('.')) {
      setState(() => _emailError = 'Please enter a valid email');
      hasError = true;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      hasError = true;
    } else if (password.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      hasError = true;
    }

    if (confirmPassword.isEmpty) {
      setState(() => _confirmPasswordError = 'Please confirm your password');
      hasError = true;
    } else if (password != confirmPassword) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      hasError = true;
    }

    if (hasError) return;

    final user = await AuthService().signUp(email, password);
    if (!mounted) return;

    if (user != null) {
      AppData.meals.value = [];

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
      );
    } else {
      setState(() => _emailError = 'Registration failed. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Text(
                  'Create account',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Start your fitness journey',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                _buildTextField(
                  controller: _emailController,
                  hint: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _passwordController,
                  hint: 'Password',
                  obscureText: _obscurePassword,
                  errorText: _passwordError,
                  toggleObscure: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _confirmPasswordController,
                  hint: 'Confirm Password',
                  obscureText: _obscureConfirmPassword,
                  errorText: _confirmPasswordError,
                  toggleObscure: () {
                    setState(() =>
                    _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Sign up',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          color: Color(0xFFD85A30),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    VoidCallback? toggleObscure,
    String? errorText,
  }) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: hasError
                ? const Color(0xFFD85A30).withValues(alpha: 0.05)
                : const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: hasError
                  ? const BorderSide(color: Color(0xFFD85A30), width: 1.5)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: hasError
                  ? const BorderSide(color: Color(0xFFD85A30), width: 2)
                  : const BorderSide(color: Color(0xFF2196F3), width: 2),
            ),
            suffixIcon: toggleObscure != null
                ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: toggleObscure,
            )
                : null,
          ),
        ),

        if (hasError) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.error_outline,
                  color: Color(0xFFD85A30), size: 14),
              const SizedBox(width: 4),
              Text(
                errorText,
                style: const TextStyle(
                  color: Color(0xFFD85A30),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}