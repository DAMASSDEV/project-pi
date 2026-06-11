import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_theme.dart';

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
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
            const SizedBox(height: 24),
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
                padding: const EdgeInsets.all(32),
                child: Image.asset(
                  'assets/hero-bot.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 36),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Lupa Kata Sandi?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.neutralColor,
                  height: 1.3,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Jangan khawatir! Masukkan alamat email Anda di bawah ini untuk menerima instruksi pemulihan kata sandi.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 36),
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
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'you@example.com',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(
                  Icons.mail_outline_rounded,
                  color: Colors.grey.shade600,
                ),
                fillColor: const Color(0xFFF8F9FA),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
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
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleResetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Kirim Petunjuk Pemulihan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
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
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Kembali ke Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
