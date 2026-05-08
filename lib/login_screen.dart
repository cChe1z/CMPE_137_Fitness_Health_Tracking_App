import 'package:flutter/material.dart';
import 'registration_screen.dart';
import 'profile_setup_screen.dart';
import 'main_navigation.dart';
import 'app_data.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    bool hasError = false;

    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      hasError = true;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      hasError = true;
    }

    if (hasError) return;

    final user = await AuthService().login(email, password);
    if (!mounted) return;

    if (user != null) {
      final profile = await DatabaseService().getUserProfile(user.uid);
      if (!mounted) return;

      if (profile == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
        );
      } else {
        // restore profile data into AppData
        final level = profile['fitnessLevel'] as String? ?? 'Beginner';
        AppData.fitnessLevel.value = level;
        AppData.initDefaultSchedule(level);
        AppData.calorieGoal.value =
            (profile['calorieGoal'] as num?)?.toInt() ?? 2200;
        AppData.bmi.value =
            (profile['bmi'] as num?)?.toDouble() ?? 0.0;

        // restore name
        AppData.userName.value = profile['name'] as String? ?? '';

        // restore profile screen fields
        AppData.age.value =
            (profile['age'] as num?)?.toInt() ?? 0;
        AppData.currentWeight.value =
            (profile['weightLbs'] as num?)?.toDouble() ?? 0.0;
        AppData.heightInches.value =
            (profile['heightInches'] as num?)?.toDouble() ?? 0.0;
        AppData.gender.value =
            profile['gender'] as String? ?? '';
        AppData.activityLevel.value =
            profile['activityLevel'] as String? ?? '';

        // sanitize legacy 'Muscle Gain' value -> 'Bulk'
        final rawGoal = profile['goal'] as String? ?? '';
        final sanitizedGoal = rawGoal == 'Muscle Gain' ? 'Bulk' : rawGoal;
        AppData.goal.value = sanitizedGoal;

        if (rawGoal == 'Muscle Gain') {
          DatabaseService().updateUserProfile(user.uid, {'goal': 'Bulk'});
        }

        AppData.weightGoalRate.value =
        profile['weightGoalRate'] as String?;
        AppData.targetWeight.value =
            (profile['targetWeight'] as num?)?.toDouble() ??
                AppData.currentWeight.value;

        // restore today's logged meals from Firestore
        await AppData.loadTodaysMeals(user.uid);
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      }
    } else {
      setState(() => _emailError = 'Invalid email or password');
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

                const CircleAvatar(
                  radius: 45,
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.person, size: 50, color: Color(0xFF378ADD)),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Welcome!',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Log in to your account',
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
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF378ADD),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Log in',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegistrationScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign up',
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
                  : const BorderSide(color: Color(0xFF378ADD), width: 2),
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