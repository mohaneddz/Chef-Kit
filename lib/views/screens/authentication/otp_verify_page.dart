import 'package:chefkit/blocs/auth/auth_cubit.dart';
import 'package:chefkit/common/constants.dart';
import 'package:chefkit/views/widgets/button_widget.dart';
import 'package:chefkit/views/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chefkit/views/screens/authentication/login_page.dart';
import 'package:chefkit/views/screens/authentication/singup_page.dart';

class OtpVerifyPage extends StatefulWidget {
  final String email;
  final bool fromSignup; // Track if arriving from signup or login
  const OtpVerifyPage({
    super.key,
    required this.email,
    this.fromSignup = false,
  });

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final TextEditingController otpController = TextEditingController();
  int _cooldown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start cooldown immediately since an OTP was just sent
    _startCooldown();
  }

  void _startCooldown() {
    setState(() {
      _cooldown = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_cooldown <= 0) {
        t.cancel();
      } else {
        setState(() {
          _cooldown -= 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthCubit>().state;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? theme.scaffoldBackgroundColor
          : AppColors.red600,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                'Verify Email',
                style: TextStyle(
                  color: isDark
                      ? theme.textTheme.titleLarge?.color
                      : Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'We sent an OTP to ${widget.email}. Enter it to verify your account.',
                style: TextStyle(
                  color: isDark
                      ? theme.textTheme.bodySmall?.color
                      : Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),
              TextFieldWidget(
                controller: otpController,
                hintText: 'Enter OTP code',
                trailingIcon: Icons.lock_outline,
              ),
              const SizedBox(height: 20),
              ButtonWidget(
                text: 'Verify',
                isLoading: state.loading,
                onTap: () async {
                  final code = otpController.text.trim();
                  if (code.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter the OTP code'),
                      ),
                    );
                    return;
                  }
                  await context.read<AuthCubit>().verifyOtp(widget.email, code);
                  final newState = context.read<AuthCubit>().state;
                  if (!newState.loading &&
                      newState.error == null &&
                      !newState.needsOtp) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email verified! You can now login.'),
                      ),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  } else if (newState.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Verification failed: ${newState.error}'),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: (_cooldown > 0 || state.loading)
                    ? null
                    : () async {
                        // Call resend endpoint
                        try {
                          final baseUrl = context.read<AuthCubit>().baseUrl;
                          final resp = await http.post(
                            Uri.parse('$baseUrl/auth/resend'),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode({'email': widget.email}),
                          );
                          if (resp.statusCode == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Code resent. Check your email.'),
                              ),
                            );
                            _startCooldown();
                          } else {
                            final msg = resp.body;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Resend failed: $msg')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Resend error: $e')),
                          );
                        }
                      },
                child: Text(
                  _cooldown > 0 ? 'Resend in $_cooldown s' : 'Resend code',
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Clear any pending OTP state before navigating back
                  final cubit = context.read<AuthCubit>();
                  cubit.pendingEmail = null;
                  cubit.emit(
                    cubit.state.copyWith(
                      needsOtp: false,
                      signedUp: false,
                      fieldErrors: {},
                      error: null,
                    ),
                  );

                  // Navigate to origin page
                  if (widget.fromSignup) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const SingupPage(),
                      ),
                      (route) => false,
                    );
                  } else {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  }
                },
                child: const Text(
                  'Back',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
