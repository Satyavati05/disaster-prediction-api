import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _selectedRoleIndex = 2; // 0: Researcher, 1: Student, 2: Public
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    // Ensure E.164 format e.g. +919876543210
    if (!phone.startsWith('+')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please include country code, e.g. +91XXXXXXXXXX'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await _authService.sendOTP(
      phoneNumber: phone,
      onCodeSent: (verificationId) {
        if (!mounted) return;
        setState(() => _isLoading = false);

        final role = _selectedRoleIndex == 0
            ? 'Researcher'
            : (_selectedRoleIndex == 1 ? 'Student' : 'Public');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              phoneNumber: phone,
              role: role,
              verificationId: verificationId,
              authService: _authService,
            ),
          ),
        );
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // App Logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.bolt,
                    color: AppTheme.primaryOrange,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Climate AI',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Empowering environmental insights\nthrough AI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.grayText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Role Selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.inputBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildRoleTab('Researcher', 0),
                    _buildRoleTab('Student', 1),
                    _buildRoleTab('Public', 2),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Phone Field
              _buildTextFieldLabel('Phone Number'),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+91 98765 43210',
                  hintStyle: const TextStyle(color: AppTheme.grayText),
                  prefixIcon:
                      const Icon(Icons.phone_outlined, color: AppTheme.grayText),
                  filled: true,
                  fillColor: AppTheme.inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryOrange),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Include country code, e.g. +91XXXXXXXXXX',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.grayText.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Send OTP Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOTP,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Send OTP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTab(String text, int index) {
    bool isSelected = _selectedRoleIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRoleIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.surfaceWhite : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryOrange : AppTheme.grayText,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.darkText,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}
