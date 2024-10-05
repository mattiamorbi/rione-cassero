import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import 'package:upper/helpers/app_regex.dart';
import 'package:upper/helpers/date_time_helper.dart';
import 'package:upper/routing/routes.dart';
import 'package:upper/theming/styles.dart';
import 'package:upper/helpers/extensions.dart';
import 'package:upper/logic/cubit/auth_cubit.dart';
import 'package:upper/core/widgets/app_text_button.dart';
import 'package:upper/core/widgets/app_text_form_field.dart';
import 'package:upper/core/widgets/password_validations.dart';
import 'package:upper/models/user.dart' as up;

// ignore: must_be_immutable
class EmailAndPassword extends StatefulWidget {
  final bool? isSignUpPage;
  late OAuthCredential? credential;

  EmailAndPassword({
    super.key,
    this.isSignUpPage,
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
  TextEditingController addressController = TextEditingController();
  TextEditingController birthdateController = TextEditingController();
  TextEditingController birthplaceController = TextEditingController();
  TextEditingController capController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController telephoneController = TextEditingController();
  TextEditingController passwordConfirmationController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  final passwordFocusNode = FocusNode();
  final passwordConfirmationFocusNode = FocusNode();

  _EmailAndPasswordState();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          emailField(),
          passwordField(),
          forgetPasswordTextButton(),
          Gap(18.h),
          passwordConfirmationField(),
          Gap(18.h),
          genericField(nameController, 'Nome', 'Inserisci un nome valido'),
          genericField(surnameController, 'Cognome', 'Inserisci un cognome valido'),
          genericField(birthplaceController, 'Luogo di nascita', 'Inserisci un luogo valido'),
          birthPlaceField(),
          genericField(addressController, 'Indirizzo', 'Inserisci un indirizzo valido'),
          genericField(cityController, 'Citta', 'Inserisci una citta valida'),
          capField(),
          genericField(telephoneController, 'Telefono', 'Inserisci un telefono valido'),

          Gap(10.h),
          PasswordValidations(
            hasMinLength: hasMinLength,
            isSignup: widget.isSignUpPage ?? false,
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
    nameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    addressController.dispose();
    birthdateController.dispose();
    birthplaceController.dispose();
    capController.dispose();
    cityController.dispose();
    telephoneController.dispose();
    passwordConfirmationController.dispose();
  }

  Widget emailField() {
    return Column(
      children: [
        AppTextFormField(
          hint: 'Email',
          validator: (value) {
            String email = (value ?? '').trim();
            emailController.text = email;
            if (email.isEmpty) {
              return 'Inserisci un indirizzo email!';
            }

            if (!AppRegex.isEmailValid(email)) {
              return 'Inserisci un indirizzo email valido!';
            }
          },
          controller: emailController,
        ),
        Gap(18.h),
      ],
    );
  }

  Widget capField() {
    if (widget.isSignUpPage == true) {
      return Column(
        children: [
          AppTextFormField(
            hint: 'CAP',
            validator: (value) {
              String cap = (value ?? '').trim();
              capController.text = cap;
              var validCap = cap.isNotEmpty && cap.length == 5;
              try {
                int.parse(cap);
                validCap &= true;
              } on Exception {
                // Nel caso di CAP non valido
                validCap = false;
              }
              if (!validCap) {
                return 'Inserisci un CAP valido!';
              }
            },
            controller: capController,
          ),
          Gap(18.h),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget birthPlaceField() {
    if (widget.isSignUpPage == true) {
      return Column(
        children: [
          AppTextFormField(
            hint: 'Data di nascita (gg/mm/aaaa)',
            validator: (value) {
              String birthDate = (value ?? '').trim();
              birthdateController.text = birthDate;
              bool validDate = false;
              try {
                DateTimeHelper.getDateTime(birthDate);
                validDate = true;
              } on Exception {
                // Formato data inserito non valido
              }

              if (birthDate.isEmpty || !validDate) {
                return 'Inserisci un data di nascita valida valido!';
              }
            },
            controller: birthdateController,
          ),
          Gap(18.h),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget forgetPasswordTextButton() {
    if (widget.isSignUpPage == null) {
      return TextButton(
        onPressed: () {
          context.pushNamed(Routes.forgetScreen);
        },
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Password dimenticata?',
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
      buttonText: "Entra in UPPER",
      textStyle: TextStyles.font16White600Weight,
      buttonWidth: 300,
      buttonHeight: 70,
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
    if (widget.isSignUpPage == null) {
      return loginButton(context);
    }
  }

  Widget genericField(TextEditingController controller, String placeholder, String errorMessage) {
    if (widget.isSignUpPage == true) {
      return Column(
        children: [
          AppTextFormField(
            hint: placeholder,
            validator: (value) {
              String enteredValue = (value ?? '').trim();
              controller.text = enteredValue;
              if (enteredValue.isEmpty) {
                return errorMessage;
              }
            },
            controller: controller,
          ),
          Gap(18.h),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget passwordConfirmationField() {
    if (widget.isSignUpPage == true) {
      return AppTextFormField(
        focusNode: passwordConfirmationFocusNode,
        controller: passwordConfirmationController,
        hint: 'Conferma la password',
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
            isObscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
        ),
        validator: (value) {
          if (value != passwordController.text) {
            return 'Le password non corrispondono!';
          }
          if (value == null || value.isEmpty || !AppRegex.isPasswordValid(value)) {
            return 'Inserisci una password valida!';
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
          isObscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty || !AppRegex.isPasswordValid(value)) {
          return 'Inserisci una password valida!';
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
      buttonText: "Iscriviti",
      textStyle: TextStyles.font16White600Weight,
      onPressed: () async {
        passwordFocusNode.unfocus();
        passwordConfirmationFocusNode.unfocus();
        if (formKey.currentState!.validate()) {
          var user = up.User(
            name: nameController.text,
            surname: surnameController.text,
            address: addressController.text,
            birthplace: birthplaceController.text,
            email: emailController.text,
            birthdate: birthdateController.text,
            cap: capController.text,
            city: cityController.text,
            telephone: telephoneController.text,
            cardNumber: 0,
          );
          context.read<AuthCubit>().signUpWithEmail(
                user,
                passwordController.text,
              );
        }
      },
    );
  }
}
