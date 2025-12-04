import 'package:chefkit/blocs/auth/auth_cubit.dart';
import 'package:chefkit/common/constants.dart';
import 'package:chefkit/views/screens/authentication/singup_page.dart';
import 'package:chefkit/views/widgets/button_widget.dart';
import 'package:chefkit/views/widgets/text_field_widget.dart';
import 'package:chefkit/views/layout/triangle_painter.dart';
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
  Widget build(BuildContext context) {
    final errors = context.watch<AuthCubit>().state.fieldErrors;
    return Scaffold(
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
              stratProportion: 0.4,
              endProportion: 0.2,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
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
                            height: MediaQuery.of(context).size.height * 0.13,
                          ),
                          Image.asset(
                            "assets/images/couscous.png",
                            width: 180,
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 41),
                          // the icons will be changed
                          TextFieldWidget(
                            controller: emailController,
                            hintText: "Email Address",
                            trailingIcon: Icons.email_outlined,
                            errorText: errors["email"],
                          ),
                          SizedBox(height: 20),
                          TextFieldWidget(
                            controller: passwordController,
                            hintText: "Password",
                            trailingIcon: Icons.visibility_off_outlined,
                            isPassword: true,
                            errorText: errors["password"],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          ButtonWidget(
                            text: "Log In",
                            onTap: () {
                              context.read<AuthCubit>().login(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );
                            },
                          ),
                          SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Forgot email or password ?",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(width: 3),
                              TextButton(
                                onPressed: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SingupPage(),
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: Text(
                                  "Sing Up",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFA974),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
