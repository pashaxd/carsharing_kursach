import 'package:carsharing_kursach/features/auth_feature/presentation/controller/auth_controller.dart';
import 'package:carsharing_kursach/features/auth_feature/presentation/widgets/auth_field.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                borderRadius: BorderRadius.circular(40),
              ),
              width: 300,
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AuthField(
                    hintText: 'Email',
                    controller: TextEditingController(),
                  ),
                  AuthField(
                    hintText: 'Password',
                    controller: TextEditingController(),
                  ),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      onPressed: () {
                        AuthController().register(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                      },
                      child: Text(
                        'Sign in',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
