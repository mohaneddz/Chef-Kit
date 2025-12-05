import 'package:chefkit/blocs/auth/auth_cubit.dart';
import 'package:chefkit/common/constants.dart';
import 'package:chefkit/views/screens/authentication/login_page.dart';
import 'package:chefkit/views/screens/authentication/otp_verify_page.dart';
import 'package:chefkit/views/widgets/button_widget.dart';
import 'package:chefkit/views/widgets/text_field_widget.dart';
import 'package:chefkit/views/layout/triangle_painter.dart';
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
    // Clear any stale field errors when entering signup page
    Future.microtask(() {
      if (mounted) {
        context.read<AuthCubit>().emit(
          context.read<AuthCubit>().state.copyWith(fieldErrors: {}, error: null),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final errors = context.watch<AuthCubit>().state.fieldErrors;
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Debug outputs for signup flow
        debugPrint('[SignupPage] AuthState loading=${state.loading} error=${state.error} signedUp=${state.signedUp}');
        
        // Only navigate to OTP if signedUp is true AND no field errors exist
        if (!state.loading && state.signedUp && state.error == null && state.fieldErrors.isEmpty) {
          // With OTP flow, navigate to verification page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OtpVerifyPage(email: emailController.text.trim(), fromSignup: true)),
          );
        }
        
        if (state.error != null && !state.loading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Signup failed: ${state.error}')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.red600,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            CustomPaint(
              size: Size(
                MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height,
              ),
              painter: TrianglePainter(
                color: AppColors.orange,
                stratProportion: 0.35,
                endProportion: 0.15,
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.10,
                              ),
                              Image.asset(
                                "assets/images/couscous.png",
                                width: 180,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 41),
                              TextFieldWidget(
                                controller: fullnameController,
                                hintText: "Full Name",
                                trailingIcon: Icons.person_outline,
                                errorText: errors["name"],
                              ),
                              const SizedBox(height: 20),
                              TextFieldWidget(
                                controller: emailController,
                                hintText: "Email Address",
                                trailingIcon: Icons.email_outlined,
                                errorText: errors["email"],
                              ),
                              const SizedBox(height: 20),
                              TextFieldWidget(
                                controller: passwordController,
                                hintText: "Password",
                                trailingIcon: Icons.visibility_off_outlined,
                                isPassword: true,
                                errorText: errors["password"],
                              ),
                              const SizedBox(height: 20),
                              TextFieldWidget(
                                controller: confirmPasswordController,
                                hintText: "Confirm Password",
                                trailingIcon: Icons.visibility_off_outlined,
                                isPassword: true,
                                errorText: errors["confirm"],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const SizedBox(height: 30),
                              ButtonWidget(
                                text: "Sign Up",
                                isLoading: context.watch<AuthCubit>().state.loading,
                                onTap: () {
                                  debugPrint('[SignupPage] SignUp button tapped');
                                  context.read<AuthCubit>().signup(
                                    fullnameController.text.trim(),
                                    emailController.text.trim(),
                                    passwordController.text.trim(),
                                    confirmPasswordController.text.trim(),
                                  );
                                },
                              ),
                              const SizedBox(height: 25),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Already have an account?",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  TextButton(
                                    onPressed: () => Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      "Login",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFFA974),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
