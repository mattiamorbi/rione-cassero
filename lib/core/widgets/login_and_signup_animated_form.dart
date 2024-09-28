import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:upper/helpers/app_regex.dart';
import 'package:upper/routing/routes.dart';
import 'package:upper/theming/styles.dart';
import 'package:upper/helpers/extensions.dart';
import 'package:upper/logic/cubit/auth_cubit.dart';
import 'package:upper/core/widgets/app_text_button.dart';
import 'package:upper/core/widgets/app_text_form_field.dart';
import 'package:upper/core/widgets/password_validations.dart';

// ignore: must_be_immutable
class EmailAndPassword extends StatefulWidget {
  final bool? isSignUpPage;
  final bool? isPasswordPage;
  late GoogleSignInAccount? googleUser;
  late OAuthCredential? credential;

  EmailAndPassword({
    super.key,
    this.isSignUpPage,
    this.isPasswordPage,
    this.googleUser,
    this.credential,
  });

  @override
  State<EmailAndPassword> createState() => _EmailAndPasswordState();
}

class _EmailAndPasswordState extends State<EmailAndPassword> {
  bool isObscureText = true;
  bool hasMinLength = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmationController =
      TextEditingController();

  final formKey = GlobalKey<FormState>();

  final passwordFocusNode = FocusNode();
  final passwordConfirmationFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          const Image(image: AssetImage("assets/images/upper.jpeg")),
          nameField(),
          surnameField(),
          emailField(),
          passwordField(),
          Gap(18.h),
          passwordConfirmationField(),
          forgetPasswordTextButton(),
          Gap(10.h),
          PasswordValidations(
            hasMinLength: hasMinLength,
          ),
          Gap(20.h),
          loginOrSignUpOrPasswordButton(context),
        ],
      ),
    );
  }


  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    nameController.dispose();
    surnameController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
    passwordFocusNode.dispose();
    passwordConfirmationFocusNode.dispose();
  }

  Widget emailField() {
    if (widget.isPasswordPage == null) {
      return Column(
        children: [
          AppTextFormField(
            hint: 'Email',
            validator: (value) {
              String email = (value ?? '').trim();

              emailController.text = email;

              if (email.isEmpty) {
                return 'Please enter an email address';
              }

              if (!AppRegex.isEmailValid(email)) {
                return 'Please enter a valid email address';
              }
            },
            controller: emailController,
          ),
          Gap(18.h),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget forgetPasswordTextButton() {
    if (widget.isSignUpPage == null && widget.isPasswordPage == null) {
      return TextButton(
        onPressed: () {
          context.pushNamed(Routes.forgetScreen);
        },
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            'forget password?',
            style: TextStyles.font14Blue400Weight,
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  void initState() {
    super.initState();
    setupPasswordControllerListener();
  }

  AppTextButton loginButton(BuildContext context) {
    return AppTextButton(
      buttonText: "Login",
      textStyle: TextStyles.font16White600Weight,
      onPressed: () async {
        passwordFocusNode.unfocus();
        if (formKey.currentState!.validate()) {
          context.read<AuthCubit>().signInWithEmail(
                emailController.text,
                passwordController.text,
              );
        }
      },
    );
  }

  loginOrSignUpOrPasswordButton(BuildContext context) {
    if (widget.isSignUpPage == true) {
      return signUpButton(context);
    }
    if (widget.isSignUpPage == null && widget.isPasswordPage == null) {
      return loginButton(context);
    }
    if (widget.isPasswordPage == true) {
      return passwordButton(context);
    }
  }

  Widget nameField() {
    if (widget.isSignUpPage == true) {
      return Column(
        children: [
          AppTextFormField(
            hint: 'Name',
            validator: (value) {
              String name = (value ?? '').trim();
              nameController.text = name;
              if (name.isEmpty) {
                return 'Please enter a valid name';
              }
            },
            controller: nameController,
          ),
          Gap(18.h),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget surnameField() {
    if (widget.isSignUpPage == true) {
      return Column(
        children: [
          AppTextFormField(
            hint: 'Surname',
            validator: (value) {
              String surname = (value ?? '').trim();
              surnameController.text = surname;
              if (surname.isEmpty) {
                return 'Please enter a valid surname';
              }
            },
            controller: surnameController,
          ),
          Gap(18.h),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  AppTextButton passwordButton(BuildContext context) {
    return AppTextButton(
      buttonText: "Create Password",
      textStyle: TextStyles.font16White600Weight,
      onPressed: () async {
        passwordFocusNode.unfocus();
        passwordConfirmationFocusNode.unfocus();
        if (formKey.currentState!.validate()) {
          context.read<AuthCubit>().createAccountAndLinkItWithGoogleAccount(
                nameController.text,
                passwordController.text,
                widget.googleUser!,
                widget.credential!,
              );
        }
      },
    );
  }

  Widget passwordConfirmationField() {
    if (widget.isSignUpPage == true || widget.isPasswordPage == true) {
      return AppTextFormField(
        focusNode: passwordConfirmationFocusNode,
        controller: passwordConfirmationController,
        hint: 'Password Confirmation',
        isObscureText: isObscureText,
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              if (isObscureText) {
                isObscureText = false;
              } else {
                isObscureText = true;
              }
            });
          },
          child: Icon(
            isObscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
        validator: (value) {
          if (value != passwordController.text) {
            return 'Enter a matched passwords';
          }
          if (value == null ||
              value.isEmpty ||
              !AppRegex.isPasswordValid(value)) {
            return 'Please enter a valid password';
          }
        },
      );
    }
    return const SizedBox.shrink();
  }

  AppTextFormField passwordField() {
    return AppTextFormField(
      focusNode: passwordFocusNode,
      controller: passwordController,
      hint: 'Password',
      isObscureText: isObscureText,
      suffixIcon: GestureDetector(
        onTap: () {
          setState(() {
            if (isObscureText) {
              isObscureText = false;
            } else {
              isObscureText = true;
            }
          });
        },
        child: Icon(
          isObscureText
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
        ),
      ),
      validator: (value) {
        if (value == null ||
            value.isEmpty ||
            !AppRegex.isPasswordValid(value)) {
          return 'Please enter a valid password';
        }
      },
    );
  }

  void setupPasswordControllerListener() {
    passwordController.addListener(() {
      setState(() {
        hasMinLength = AppRegex.isPasswordValid(passwordController.text);
      });
    });
  }

  AppTextButton signUpButton(BuildContext context) {
    return AppTextButton(
      buttonText: "Create Account",
      textStyle: TextStyles.font16White600Weight,
      onPressed: () async {
        passwordFocusNode.unfocus();
        passwordConfirmationFocusNode.unfocus();
        if (formKey.currentState!.validate()) {
          context.read<AuthCubit>().signUpWithEmail(
                nameController.text,
                emailController.text,
                passwordController.text,
              );
        }
      },
    );
  }
}
