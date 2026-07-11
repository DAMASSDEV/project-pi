import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/brand_header.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final result = await _apiService.forgotPassword(email);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success'] == true) {
        setState(() {
          _isSuccess = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal mengirim email pemulihan.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double cardSize = screenSize.width * 0.64;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppTheme.neutralColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Nutrify',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _isSuccess
              ? _buildSuccessView(cardSize)
              : _buildFormView(cardSize),
        ),
      ),
    );
  }

  Widget _buildFormView(double cardSize) {
    return SingleChildScrollView(
      key: const ValueKey('form_view'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const BrandHeader(
              subtitle: 'Jangan khawatir! Masukkan alamat email Anda di bawah ini untuk menerima instruksi pemulihan kata sandi.',
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
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email wajib diisi';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              text: 'Kirim Petunjuk Pemulihan',
              isLoading: _isLoading,
              onPressed: _handleResetPassword,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(double cardSize) {
    return Padding(
      key: const ValueKey('success_view'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 3),
          Center(
            child: Container(
              width: cardSize,
              height: cardSize,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FAF7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.06),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(36),
              child: const Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 36),
          const Text(
            'Email Terkirim!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppTheme.neutralColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Kami telah mengirimkan tautan pemulihan kata sandi ke email ${_emailController.text}. Silakan periksa kotak masuk atau folder spam Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
                height: 1.6,
              ),
            ),
          ),
          const Spacer(flex: 4),
          PrimaryButton(
            text: 'Atur Ulang Kata Sandi',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ResetPasswordPage(email: _emailController.text),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Kembali ke Login',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final result = await _apiService.resetPassword(widget.email, _passwordController.text);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kata sandi berhasil diperbarui! Silakan masuk kembali.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal memperbarui kata sandi.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.neutralColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Atur Ulang Kata Sandi',
          style: TextStyle(
            color: AppTheme.neutralColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Masukkan kata sandi baru untuk akun Anda.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Kata Sandi Baru',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Kata Sandi Baru',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kata sandi wajib diisi';
                    }
                    if (value.length < 6) {
                      return 'Kata sandi minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Konfirmasi Kata Sandi Baru',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Konfirmasi Kata Sandi',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi kata sandi wajib diisi';
                    }
                    if (value != _passwordController.text) {
                      return 'Kata sandi tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                PrimaryButton(
                  text: 'Simpan Kata Sandi',
                  isLoading: _isLoading,
                  onPressed: _handleResetPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
