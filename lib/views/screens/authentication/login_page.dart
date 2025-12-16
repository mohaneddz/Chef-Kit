import 'package:chefkit/blocs/auth/auth_cubit.dart';
import 'package:chefkit/common/constants.dart';
import 'package:chefkit/views/screens/authentication/singup_page.dart';
import 'package:chefkit/views/screens/authentication/otp_verify_page.dart';
import 'package:chefkit/views/screens/home_page.dart';
import 'package:chefkit/views/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
    // Use LayoutBuilder to ensure it fits the screen or scrolls if needed

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (!state.loading && state.user != null && state.fieldErrors.isEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
        if (!state.loading && state.needsOtp) {
          final email =
              context.read<AuthCubit>().pendingEmail ??
              emailController.text.trim();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your email is not verified. We sent a new code.'),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OtpVerifyPage(email: email, fromSignup: false),
            ),
          );
        }
        if (!state.loading &&
            state.error != null &&
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400, // Limit width on large screens/tablets
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Brand Section ---
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/images/final_logo.png',
                      height: 120, // Bigger logo
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Welcome Back",
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
                      "Sign in to continue your culinary journey",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontFamily: "LeagueSpartan",
                      ),
                    ),
                    const SizedBox(height: 48),

                    // --- Form Section ---
                    TextFieldWidget(
                      controller: emailController,
                      hintText: "Email Address",
                      trailingIcon: Icons.email_outlined,
                      errorText: errors["email"],
                      textColor: Colors.black87,
                      hintColor: Colors.grey[500]!,
                      fillColor: const Color(0xFFF5F5F5), // Very light grey
                      borderColor: Colors.transparent,
                    ),
                    const SizedBox(height: 16),
                    TextFieldWidget(
                      controller: passwordController,
                      hintText: "Password",
                      trailingIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      errorText: errors["password"],
                      textColor: Colors.black87,
                      hintColor: Colors.grey[500]!,
                      fillColor: const Color(0xFFF5F5F5),
                      borderColor: Colors.transparent,
                    ),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12, right: 8),
                        child: GestureDetector(
                          onTap: () {}, // TODO: Implement
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: AppColors.red600,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- Actions Section ---
                    Container(
                      height: 56, // Taller button
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
                                context.read<AuthCubit>().login(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
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
                                "Sign In",
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
                          "Don't have an account? ",
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
                                      const SingupPage(),
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
                            "Sign Up",
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
