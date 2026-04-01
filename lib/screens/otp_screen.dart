import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'how_it_works_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String role;
  final String verificationId;
  final AuthService authService;

  const OtpScreen({
    Key? key,
    required this.phoneNumber,
    required this.role,
    required this.verificationId,
    required this.authService,
  }) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // 6 individual OTP digit controllers
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  bool _isResending = false;

  // Updated on resend
  late String _verificationId;

  // Resend countdown
  int _resendCooldown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId; // store locally so resend can update it
    _startCountdown();
    // Auto-focus first box
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  void _startCountdown() {
    _resendCooldown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCooldown == 0) {
        t.cancel();
      } else {
        if (mounted) setState(() => _resendCooldown--);
      }
    });
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _verifyOTP() async {
    final otp = _otpCode;

    // ── Debug prints ────────────────────────────────────────────────────────
    print("[OTP] Verification ID: $_verificationId");
    print("[OTP] SMS code entered: $otp");
    // ────────────────────────────────────────────────────────────────────────

    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit OTP')),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      print("[OTP] Calling signInWithCredential...");
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final uid = userCredential.user?.uid;
      print("[OTP] Sign-in successful. UID: $uid");

      if (uid != null) {
        final user = userCredential.user!;
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'phone': user.phoneNumber,
          'role': widget.role,
          'createdAt': DateTime.now(),
        }, SetOptions(merge: true));
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HowItWorksScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      print("[OTP] FirebaseAuthException → code: ${e.code}, message: ${e.message}");
      if (!mounted) return;

      String userMessage;
      switch (e.code) {
        case 'invalid-verification-code':
          userMessage = 'Wrong OTP. Please check the SMS and try again.';
          break;
        case 'session-expired':
          userMessage = 'OTP expired. Please tap Resend to get a new one.';
          break;
        case 'invalid-verification-id':
          userMessage = 'Session error. Please go back and request a new OTP.';
          break;
        case 'too-many-requests':
          userMessage = 'Too many attempts. Please try again later.';
          break;
        default:
          userMessage = 'Error (${e.code}): ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userMessage),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      print("[OTP] Unknown error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendOTP() async {
    if (_resendCooldown > 0) return;
    setState(() => _isResending = true);

    await widget.authService.sendOTP(
      phoneNumber: widget.phoneNumber,
      onCodeSent: (newVerificationId) {
        if (!mounted) return;
        // Update verificationId so the next verify uses the fresh one
        setState(() {
          _verificationId = newVerificationId;
          _isResending = false;
        });
        _startCountdown();
        for (final c in _controllers) {
          c.clear();
        }
        FocusScope.of(context).requestFocus(_focusNodes[0]);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent successfully')),
        );
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isResending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maskedPhone = widget.phoneNumber.length > 6
        ? '${widget.phoneNumber.substring(0, widget.phoneNumber.length - 6)}XXXXXX'
        : widget.phoneNumber;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.sms_outlined,
                    color: AppTheme.primaryOrange,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Verify Your Number',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit OTP to\n$maskedPhone',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.grayText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // OTP Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (i) => _buildOtpBox(i)),
              ),
              const SizedBox(height: 40),

              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOTP,
                  child: _isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Verify OTP'),
                ),
              ),
              const SizedBox(height: 24),

              // Resend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive the OTP? ",
                    style: TextStyle(color: AppTheme.grayText, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: _resendCooldown == 0 ? _resendOTP : null,
                    child: _isResending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryOrange),
                          )
                        : Text(
                            _resendCooldown > 0
                                ? 'Resend in ${_resendCooldown}s'
                                : 'Resend',
                            style: TextStyle(
                              color: _resendCooldown > 0
                                  ? AppTheme.grayText
                                  : AppTheme.primaryOrange,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 46,
      height: 56,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          // Handle backspace: clear current box and move focus back
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            if (_controllers[index].text.isEmpty && index > 0) {
              _controllers[index - 1].clear();
              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
            }
          }
        },
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkText,
          ),
          decoration: InputDecoration(
            counterText: '',
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
              borderSide:
                  const BorderSide(color: AppTheme.primaryOrange, width: 2),
            ),
          ),
          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              // Move forward
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            } else if (value.isEmpty && index > 0) {
              // Move backward on delete
              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
            }
          },
          onEditingComplete: () {
            if (index < 5) {
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            } else {
              FocusScope.of(context).unfocus();
            }
          },
        ),
      ),
    );
  }
}
