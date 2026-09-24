import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/post_login_router.dart';
import '../services/phone_auth_completion.dart';
import '../utils/synthetic_email.dart';
import '../widgets/app_logo.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radii.dart';
import 'otp_verify_screen.dart';
import 'forgot_password_screen.dart';

enum _Step { phone, password, name }

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  _Step _step = _Step.phone;
  bool _isSubmitting = false;
  String? _errorText;
  String? _normalizedPhone;

  String _normalizePhone(String rawInput) {
    String phone = rawInput;
    if (phone.startsWith('0')) {
      phone = '+249${phone.substring(1)}';
    } else if (!phone.startsWith('+')) {
      phone = '+249$phone';
    }
    return phone;
  }

  Future<void> _continueWithPhone() async {
    final rawInput = _phoneController.text.trim();
    final l10n = AppLocalizations.of(context)!;
    if (rawInput.isEmpty) {
      setState(() => _errorText = l10n.enterPhoneError);
      return;
    }

    final phone = _normalizePhone(rawInput);
    setState(() {
      _isSubmitting = true;
      _errorText = null;
      _normalizedPhone = phone;
    });

    try {
      final callable = FirebaseFunctions.instance.httpsCallable('checkPhoneRegistered');
      final result = await callable.call({'phone': phone});
      final exists = result.data['exists'] as bool;
      final hasPassword = result.data['hasPassword'] as bool;

      if (!mounted) return;

      if (exists && hasPassword) {
        setState(() {
          _isSubmitting = false;
          _step = _Step.password;
        });
      } else if (exists) {
        // Existing account, never set a password — prove ownership via OTP
        // first, then it'll be forced to set one (see OtpVerifyScreen).
        await _sendOtp(phone, isNewAccount: false);
      } else {
        setState(() {
          _isSubmitting = false;
          _step = _Step.name;
        });
      }
    } on FirebaseFunctionsException catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorText = e.message ?? l10n.checkPhoneError;
      });
    }
  }

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;
    final password = _passwordController.text;
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: syntheticAuthEmail(_normalizedPhone!),
        password: password,
      );
      if (!mounted) return;
      await routeAfterLogin(context, credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorText = e.code == 'wrong-password' || e.code == 'invalid-credential'
            ? l10n.wrongPasswordError
            : (e.message ?? l10n.wrongPasswordError);
      });
    }
  }

  Future<void> _continueWithName() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = l10n.enterNameError);
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    await _sendOtp(_normalizedPhone!, isNewAccount: true, name: name);
  }

  Future<void> _sendOtp(String phone, {required bool isNewAccount, String? name}) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Android auto-retrieval case — skips the OTP screen entirely, so
        // this has to do everything OtpVerifyScreen._verifyCode() does.
        try {
          await completePhoneAuthSignIn(
            context: context,
            credential: credential,
            isNewAccount: isNewAccount,
            phoneNumber: phone,
            name: name,
          );
        } on FirebaseAuthException catch (e) {
          if (!mounted) return;
          setState(() {
            _isSubmitting = false;
            _errorText = e.message ?? AppLocalizations.of(context)!.verificationFailedError;
          });
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
          _errorText = e.message ?? AppLocalizations.of(context)!.verificationFailedError;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerifyScreen(
              verificationId: verificationId,
              phoneNumber: phone,
              name: name,
              isNewAccount: isNewAccount,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void _changeNumber() {
    setState(() {
      _step = _Step.phone;
      _errorText = null;
      _passwordController.clear();
    });
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      hintStyle: const TextStyle(color: AppColors.mutedOnDark),
      border: OutlineInputBorder(
        borderRadius: AppRadii.fieldRadius,
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadii.fieldRadius,
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadii.fieldRadius,
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
    );
  }

  Widget _phoneField(AppLocalizations l10n) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: AppRadii.fieldRadius,
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: const Text(
              '+249',
              style: TextStyle(fontFamily: AppTypography.monoFamily, fontSize: 15, color: Colors.white),
            ),
          ),
          const SizedBox(width: AppSpacing.s10),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              style: const TextStyle(fontFamily: AppTypography.monoFamily, fontSize: 15, color: Colors.white),
              decoration: _fieldDecoration(l10n.phoneHint),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneStep(AppLocalizations l10n) {
    return Column(
      key: const ValueKey(_Step.phone),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.riderSignInHeading, style: AppTypography.title(size: 22, color: Colors.white)),
        const SizedBox(height: AppSpacing.s8),
        Text(l10n.signInHeading, style: AppTypography.body(size: 14, color: AppColors.mutedOnDark)),
        const SizedBox(height: AppSpacing.s22),
        _phoneField(l10n),
        if (_errorText != null) _errorMessage(),
        const SizedBox(height: AppSpacing.s16),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _continueWithPhone,
          child: _isSubmitting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(l10n.phoneContinueButton),
        ),
      ],
    );
  }

  Widget _buildPasswordStep(AppLocalizations l10n) {
    return Column(
      key: const ValueKey(_Step.password),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _normalizedPhone ?? '',
          textDirection: TextDirection.ltr,
          style: const TextStyle(fontFamily: AppTypography.monoFamily, fontSize: 15, color: AppColors.mutedOnDark),
        ),
        const SizedBox(height: AppSpacing.s22),
        TextField(
          controller: _passwordController,
          obscureText: true,
          style: const TextStyle(fontFamily: AppTypography.monoFamily, fontSize: 15, color: Colors.white),
          decoration: _fieldDecoration(l10n.passwordHint),
          onSubmitted: (_) => _isSubmitting ? null : _login(),
        ),
        if (_errorText != null) _errorMessage(),
        const SizedBox(height: AppSpacing.s16),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _login,
          child: _isSubmitting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(l10n.loginButton),
        ),
        const SizedBox(height: AppSpacing.s12),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.accentOnDark),
            onPressed: _isSubmitting
                ? null
                : () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => ForgotPasswordScreen(phone: _normalizedPhone!))),
            child: Text(l10n.forgotPasswordLink),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.mutedOnDark),
            onPressed: _isSubmitting ? null : _changeNumber,
            child: Text(l10n.backButton),
          ),
        ),
      ],
    );
  }

  Widget _buildNameStep(AppLocalizations l10n) {
    return Column(
      key: const ValueKey(_Step.name),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.phoneLoginHeading, style: AppTypography.title(size: 22, color: Colors.white)),
        const SizedBox(height: AppSpacing.s22),
        TextField(
          controller: _nameController,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[0-9]'))],
          style: const TextStyle(color: Colors.white),
          decoration: _fieldDecoration(l10n.fullNameHint),
        ),
        if (_errorText != null) _errorMessage(),
        const SizedBox(height: AppSpacing.s16),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _continueWithName,
          child: _isSubmitting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(l10n.sendCodeButton),
        ),
        const SizedBox(height: AppSpacing.s12),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.mutedOnDark),
            onPressed: _isSubmitting ? null : _changeNumber,
            child: Text(l10n.backButton),
          ),
        ),
      ],
    );
  }

  Widget _errorMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s8),
      child: Text(_errorText!, style: const TextStyle(color: AppColors.danger)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.s26, AppSpacing.s22, AppSpacing.s26, AppSpacing.s26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(
                alignment: AlignmentDirectional.centerStart,
                child: AppLogo(height: 48, color: AppLogoColor.white),
              ),
              const SizedBox(height: AppSpacing.s30),
              switch (_step) {
                _Step.phone => _buildPhoneStep(l10n),
                _Step.password => _buildPasswordStep(l10n),
                _Step.name => _buildNameStep(l10n),
              },
            ],
          ),
        ),
      ),
    );
  }
}
