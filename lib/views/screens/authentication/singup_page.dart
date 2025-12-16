import 'package:chefkit/blocs/auth/auth_cubit.dart';
import 'package:chefkit/common/constants.dart';
import 'package:chefkit/views/screens/authentication/login_page.dart';
import 'package:chefkit/views/screens/authentication/otp_verify_page.dart';
import 'package:chefkit/views/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SingupPage extends StatefulWidget {
  const SingupPage({super.key});

  @override
  State<SingupPage> createState() => _SingupPageState();
}

class _SingupPageState extends State<SingupPage> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<AuthCubit>().emit(
          context.read<AuthCubit>().state.copyWith(
            fieldErrors: {},
            error: null,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final errors = context.watch<AuthCubit>().state.fieldErrors;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (!state.loading &&
            state.signedUp &&
            state.error == null &&
            state.fieldErrors.isEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerifyPage(
                email: emailController.text.trim(),
                fromSignup: true,
              ),
            ),
          );
        }

        if (state.error != null &&
            !state.loading &&
            state.fieldErrors.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red[700],
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400, // Limit width for tablets/desktop
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Brand Section ---
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/images/final_logo.png',
                      height: 120, // Same size as login
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Create Account",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: "Poppins",
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Join us to start cooking",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontFamily: "LeagueSpartan",
                      ),
                    ),
                    const SizedBox(height: 48),

                    // --- Form Section ---
                    TextFieldWidget(
                      controller: fullnameController,
                      hintText: "Full Name",
                      trailingIcon: Icons.person_outline,
                      errorText: errors["name"],
                      textColor:
                          Theme.of(context).textTheme.bodyLarge?.color ??
                          Colors.black87,
                      hintColor:
                          Theme.of(context).textTheme.bodySmall?.color ??
                          Colors.grey[500]!,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Color(0xFF2A2A2A)
                          : const Color(0xFFF5F5F5),
                      borderColor: Colors.transparent,
                    ),
                    const SizedBox(height: 16),
                    TextFieldWidget(
                      controller: emailController,
                      hintText: "Email Address",
                      trailingIcon: Icons.email_outlined,
                      errorText: errors["email"],
                      textColor:
                          Theme.of(context).textTheme.bodyLarge?.color ??
                          Colors.black87,
                      hintColor:
                          Theme.of(context).textTheme.bodySmall?.color ??
                          Colors.grey[500]!,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Color(0xFF2A2A2A)
                          : const Color(0xFFF5F5F5),
                      borderColor: Colors.transparent,
                    ),
                    const SizedBox(height: 16),
                    TextFieldWidget(
                      controller: passwordController,
                      hintText: "Password",
                      trailingIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      errorText: errors["password"],
                      textColor:
                          Theme.of(context).textTheme.bodyLarge?.color ??
                          Colors.black87,
                      hintColor:
                          Theme.of(context).textTheme.bodySmall?.color ??
                          Colors.grey[500]!,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Color(0xFF2A2A2A)
                          : const Color(0xFFF5F5F5),
                      borderColor: Colors.transparent,
                    ),
                    const SizedBox(height: 16),
                    TextFieldWidget(
                      controller: confirmPasswordController,
                      hintText: "Confirm Password",
                      trailingIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      errorText: errors["confirm"],
                      textColor:
                          Theme.of(context).textTheme.bodyLarge?.color ??
                          Colors.black87,
                      hintColor:
                          Theme.of(context).textTheme.bodySmall?.color ??
                          Colors.grey[500]!,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Color(0xFF2A2A2A)
                          : const Color(0xFFF5F5F5),
                      borderColor: Colors.transparent,
                    ),

                    const SizedBox(height: 40),

                    // --- Actions Section ---
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.red600.withOpacity(0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: context.watch<AuthCubit>().state.loading
                            ? null
                            : () {
                                context.read<AuthCubit>().signup(
                                  fullnameController.text.trim(),
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                  confirmPasswordController.text.trim(),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: context.watch<AuthCubit>().state.loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Poppins",
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Toggle Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                            fontFamily: "LeagueSpartan",
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const LoginPage(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                              transitionDuration: const Duration(
                                milliseconds: 200,
                              ),
                            ),
                          ),
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                              color: AppColors.red600,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
