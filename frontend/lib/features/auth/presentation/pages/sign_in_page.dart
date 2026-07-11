import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/brand_header.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/social_button.dart';
import '../../../../core/widgets/top_toast.dart';
import 'sign_up_page.dart';
import 'forgot_password_page.dart';
import '../../../personalization/presentation/pages/personalization_page.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final result = await _apiService.signIn(email, password);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success'] == true) {
        showTopToast(context, 'Login Berhasil! Selamat datang di Nutrify.');
        
        bool hasPersonalization = false;
        if (result['user'] != null && result['user']['has_completed_personalization'] == true) {
          hasPersonalization = true;
        }

        if (hasPersonalization) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const DashboardPage(),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PersonalizationPage(email: email),
            ),
          );
        }
      } else {
        showTopToast(
          context, 
          result['message'] ?? 'Login Gagal! Periksa kembali email dan password Anda.',
          isError: true,
        );
      }
    }
  }

  void _showFeatureUnavailable(String featureName) {
    showTopToast(context, 'Fitur $featureName akan segera hadir!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const BrandHeader(
                  subtitle: 'Masuk untuk melanjutkan perjalanan nutrisi Anda.',
                ),
                const SizedBox(height: 40),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Alamat Email',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'you@example.com',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Kata Sandi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _passwordController,
                  hintText: '••••••••',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Lupa Kata Sandi?',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Masuk',
                  isLoading: _isLoading,
                  onPressed: _handleSignIn,
                ),
                 const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Baru di Nutrify? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Daftar',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
