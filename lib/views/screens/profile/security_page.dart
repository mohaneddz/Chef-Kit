// unused import removed

import 'package:chefkit/blocs/auth/auth_cubit.dart';
import 'package:chefkit/blocs/profile/profile_bloc.dart';
import 'package:chefkit/blocs/profile/profile_events.dart';
import 'package:chefkit/common/constants.dart';
import 'package:chefkit/common/config.dart';
import 'package:chefkit/domain/repositories/security_repository.dart';
// unused foundation import removed
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chefkit/l10n/app_localizations.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  late final SecurityRepository _repository;
  late final String _baseUrl;
  String? _accessToken;
  String? _userId;

  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _emailOtpController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _passwordOtpController = TextEditingController();

  bool _emailOtpSent = false;
  bool _passwordOtpSent = false;

  bool _emailRequestLoading = false;
  bool _emailVerifyLoading = false;
  bool _passwordRequestLoading = false;
  bool _passwordVerifyLoading = false;

  final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    _accessToken = authState.accessToken;
    _accessToken = authState.accessToken;
    _userId = authState.userId;
    _baseUrl = AppConfig.baseUrl; // Use centralized config
    _repository = SecurityRepository(
      baseUrl: _baseUrl,
      accessToken: _accessToken,
    );
  }

  @override
  void dispose() {
    _newEmailController.dispose();
    _emailOtpController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _passwordOtpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileBloc>().state.profile;
    final currentEmail = profile?.email ?? '';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.securityTitle,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.accountSecurity,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.accountSecuritySubtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),
            _buildCurrentEmailBadge(currentEmail),
            const SizedBox(height: 28),
            _buildEmailSection(currentEmail),
            const SizedBox(height: 32),
            Divider(height: 1, color: Colors.grey[300]),
            const SizedBox(height: 32),
            _buildPasswordSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailSection(String currentEmail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.changeEmail,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context)!.changeEmailSubtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _newEmailController,
          readOnly: _emailOtpSent,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.newEmailAddress,
            hintText: 'you@example.com',
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.red600, width: 1),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 16),
        if (_emailOtpSent) ...[
          TextField(
            controller: _emailOtpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.enterOtp,
              counterText: '',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.red600, width: 1),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _emailOtpSent
                    ? null
                    : () => _requestEmailOtp(currentEmail),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red600,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _emailRequestLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.sendCode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
              ),
            ),
            if (_emailOtpSent) ...[
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _emailVerifyLoading ? null : _verifyEmailOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _emailVerifyLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.confirmChange,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
        if (_emailOtpSent)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _emailVerifyLoading
                  ? null
                  : () {
                      setState(() {
                        _resetEmailFlow();
                      });
                    },
              child: Text(AppLocalizations.of(context)!.editEmailInput),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.updatePassword,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context)!.updatePasswordSubtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _currentPasswordController,
          readOnly: _passwordOtpSent,
          obscureText: true,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.currentPassword,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.red600, width: 1),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _newPasswordController,
          readOnly: _passwordOtpSent,
          obscureText: true,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.newPassword,
            helperText: AppLocalizations.of(context)!.passwordHelperText,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.red600, width: 1),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          readOnly: _passwordOtpSent,
          obscureText: true,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.confirmNewPassword,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.red600, width: 1),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 16),
        if (_passwordOtpSent) ...[
          TextField(
            controller: _passwordOtpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.enterOtp,
              counterText: '',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.red600, width: 1),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _passwordOtpSent ? null : _requestPasswordOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red600,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _passwordRequestLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.sendCode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
              ),
            ),
            if (_passwordOtpSent) ...[
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _passwordVerifyLoading ? null : _verifyPasswordOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _passwordVerifyLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.confirmChange,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
        if (_passwordOtpSent)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _passwordVerifyLoading
                  ? null
                  : () {
                      setState(() {
                        _resetPasswordFlow();
                      });
                    },
              child: Text(AppLocalizations.of(context)!.editPasswordInputs),
            ),
          ),
      ],
    );
  }

  Widget _buildCurrentEmailBadge(String currentEmail) {
    final display = currentEmail.isEmpty
        ? AppLocalizations.of(context)!.noEmailOnFile
        : currentEmail;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.alternate_email, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Text(
            display,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestEmailOtp(String currentEmail) async {
    final newEmail = _newEmailController.text.trim().toLowerCase();
    if (newEmail.isEmpty) {
      _showSnack(AppLocalizations.of(context)!.enterNewEmail, isError: true);
      return;
    }
    if (!_emailRegex.hasMatch(newEmail)) {
      _showSnack(AppLocalizations.of(context)!.enterValidEmail, isError: true);
      return;
    }
    if (currentEmail.isNotEmpty && currentEmail.toLowerCase() == newEmail) {
      _showSnack(
        AppLocalizations.of(context)!.emailMatchesCurrent,
        isError: true,
      );
      return;
    }

    setState(() => _emailRequestLoading = true);
    try {
      await _repository.requestEmailChange(newEmail: newEmail);
      if (!mounted) return;
      setState(() {
        _emailOtpSent = true;
      });
      _showSnack(AppLocalizations.of(context)!.otpSentTo(newEmail));
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) {
        setState(() => _emailRequestLoading = false);
      }
    }
  }

  Future<void> _verifyEmailOtp() async {
    final newEmail = _newEmailController.text.trim().toLowerCase();
    final otp = _emailOtpController.text.trim();

    if (newEmail.isEmpty || otp.isEmpty) {
      _showSnack(AppLocalizations.of(context)!.enterOtpSent, isError: true);
      return;
    }
    if (otp.length < 6) {
      _showSnack(AppLocalizations.of(context)!.otpLengthError, isError: true);
      return;
    }

    setState(() => _emailVerifyLoading = true);
    try {
      await _repository.verifyEmailChange(newEmail: newEmail, otp: otp);
      if (!mounted) return;
      setState(() {
        _resetEmailFlow();
        _newEmailController.clear();
      });
      _showSnack(AppLocalizations.of(context)!.emailUpdatedSuccess);
      if (_userId != null) {
        context.read<ProfileBloc>().add(LoadProfile(userId: _userId!));
      }
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) {
        setState(() => _emailVerifyLoading = false);
      }
    }
  }

  Future<void> _requestPasswordOtp() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnack(
        AppLocalizations.of(context)!.completePasswordFields,
        isError: true,
      );
      return;
    }
    if (newPassword.length < 8) {
      _showSnack(
        AppLocalizations.of(context)!.passwordLengthError,
        isError: true,
      );
      return;
    }
    if (newPassword != confirmPassword) {
      _showSnack(
        AppLocalizations.of(context)!.passwordsDoNotMatch,
        isError: true,
      );
      return;
    }
    if (newPassword == currentPassword) {
      _showSnack(
        AppLocalizations.of(context)!.passwordMustDiffer,
        isError: true,
      );
      return;
    }

    setState(() => _passwordRequestLoading = true);
    try {
      await _repository.requestPasswordChange(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      if (!mounted) return;
      setState(() {
        _passwordOtpSent = true;
      });
      _showSnack(AppLocalizations.of(context)!.otpSentEmail);
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) {
        setState(() => _passwordRequestLoading = false);
      }
    }
  }

  Future<void> _verifyPasswordOtp() async {
    final otp = _passwordOtpController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (otp.isEmpty || newPassword.isEmpty) {
      _showSnack(
        AppLocalizations.of(context)!.provideOtpAndPassword,
        isError: true,
      );
      return;
    }
    if (otp.length < 6) {
      _showSnack(AppLocalizations.of(context)!.otpLengthError, isError: true);
      return;
    }

    setState(() => _passwordVerifyLoading = true);
    try {
      await _repository.verifyPasswordChange(
        newPassword: newPassword,
        otp: otp,
      );
      if (!mounted) return;
      setState(() {
        _resetPasswordFlow();
      });
      _showSnack(AppLocalizations.of(context)!.passwordUpdatedSuccess);
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) {
        setState(() => _passwordVerifyLoading = false);
      }
    }
  }

  void _resetEmailFlow() {
    _emailOtpSent = false;
    _emailOtpController.clear();
  }

  void _resetPasswordFlow() {
    _passwordOtpSent = false;
    _passwordOtpController.clear();
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
      ),
    );
  }

  void _showError(Object error) {
    var message = error.toString();
    if (message.startsWith('Exception: ')) {
      message = message.substring(11);
    }
    _showSnack(
      message.isEmpty
          ? AppLocalizations.of(context)!.somethingWentWrong
          : message,
      isError: true,
    );
  }

  // _resolveBaseUrl removed in favor of AppConfig.baseUrl
}
