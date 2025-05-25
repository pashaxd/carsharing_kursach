import 'package:carsharing_kursach/features/auth_feature%20copy/presentation/controller/auth_controller.dart';
import 'package:carsharing_kursach/features/auth_feature%20copy/presentation/widgets/auth_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class AuthScreen extends StatelessWidget {
  AuthScreen({super.key}) {
    Get.put(AuthController());
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(
            () => Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.circular(40),
                ),
                width: 300,
                height: AuthController.to.isRegister.value ? 350 : 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AuthField(hintText: 'Email', controller: emailController),
                    AuthField(
                      hintText: 'Password',
                      controller: passwordController,
                    ),
                    Obx(
                      () =>
                          AuthController.to.isRegister.value
                              ? AuthField(
                                hintText: 'Confirm Password',
                                controller: confirmPasswordController,
                              )
                              : SizedBox.shrink(),
                    ),
                    Obx(
                      () => TextButton(
                        onPressed: () {
                          AuthController.to.isRegister.value =
                              !AuthController.to.isRegister.value;
                        },
                        child: Text(
                          '${AuthController.to.isRegister.value ? 'Already have an account? Sign in' : 'Don\'t have an account? Sign up'}',
                        ),
                      ),
                    ),
                    Obx(
                      () => SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          onPressed: () {
                            if (AuthController.to.isRegister.value) {
                              AuthController.to.register(
                                email: emailController.text,
                                password: passwordController.text,
                                confirmPassword: confirmPasswordController.text,
                              );
                              AuthController.to.isRegister.value = false;
                              emailController.clear();
                              passwordController.clear();
                              confirmPasswordController.clear();
                            } else {
                              AuthController.to.login(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                            }
                          },
                          child: Text(
                            '${AuthController.to.isRegister.value ? 'Sign up' : 'Sign in'}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
