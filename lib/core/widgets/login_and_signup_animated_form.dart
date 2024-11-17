import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:upper/core/widgets/app_text_form_field.dart';
import 'package:upper/core/widgets/password_validations.dart';
import 'package:upper/helpers/app_regex.dart';
import 'package:upper/helpers/extensions.dart';
import 'package:upper/logic/cubit/app/app_cubit.dart';
import 'package:upper/models/user.dart' as up;
import 'package:upper/routing/routes.dart';
import 'package:upper/theming/styles.dart';

import '../../helpers/server_date.dart';

// ignore: must_be_immutable
class EmailAndPassword extends StatefulWidget {
  final bool? isSignUpPage;
  late OAuthCredential? credential;
  DateTime? currentDate;

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
  TextEditingController passwordConfirmationController =
      TextEditingController();

  final formKey = GlobalKey<FormState>();

  final passwordFocusNode = FocusNode();
  final passwordConfirmationFocusNode = FocusNode();

  bool terms1Approval = false;
  bool terms1ApprovalError = false;
  bool terms2Approval = false;
  bool terms2ApprovalError = false;
  bool terms3Approval = false;
  bool terms3ApprovalError = false;

  _EmailAndPasswordState();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          genericField(nameController, 'Nome', 'Inserisci un nome valido'),
          genericField(
              surnameController, 'Cognome', 'Inserisci un cognome valido'),
          emailField(),
          passwordField(),
          forgetPasswordTextButton(),
          Gap(18.h),
          passwordConfirmationField(),
          Gap(18.h),
          genericField(birthplaceController, 'Luogo di nascita',
              'Inserisci un luogo valido'),
          birthPlaceField(),
          genericField(
              addressController, 'Indirizzo', 'Inserisci un indirizzo valido'),
          genericField(cityController, 'Citta', 'Inserisci una citta valida'),
          capField(),
          genericField(
              telephoneController, 'Telefono', 'Inserisci un telefono valido'),
          Gap(20.h),
          termsFields(),
          Gap(20.h),
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

  Widget termsFields() {
    if (widget.isSignUpPage == true) {
      return Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                terms1Approval = !terms1Approval;
                if (terms1Approval) terms1ApprovalError = false;
              });
            },
            child: Row(
              children: [
                Row(children: [
                  Icon(
                    terms1Approval == false
                        ? Icons.circle_outlined
                        : Icons.check_circle,
                    color: terms1ApprovalError == false
                        ? Colors.white
                        : Colors.red,
                    size: 18,
                  ),
                  Gap(15.w),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 140,
                    child: Text(
                      maxLines: 3,
                      "Acconsento al trattamento dei miei dati personali e delle categorie particolari di dati personali (Art.2) per finalità connesse al tesseramento alla FEDERITALIA (Art. 1 - lettere a,b,c,d)",
                      style: TextStyle(
                          fontSize: 8,
                          color: terms1ApprovalError == false
                              ? Colors.white
                              : Colors.red),
                    ),
                  )
                ]),
              ],
            ),
          ),
          Gap(15.h),
          GestureDetector(
            onTap: () {
              setState(() {
                terms2Approval = !terms2Approval;
                if (terms2Approval) terms2ApprovalError = false;
              });
            },
            child: Row(
              children: [
                Row(children: [
                  Icon(
                    terms2Approval == false
                        ? Icons.circle_outlined
                        : Icons.check_circle,
                    color: terms2ApprovalError == false
                        ? Colors.white
                        : Colors.red,
                    size: 18,
                  ),
                  Gap(15.w),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 140,
                    child: Text(
                      maxLines: 3,
                      "Acconsento al trattamento dei miei dati personali, in particolare immagini e video riprese, per il perseguimento delle finalità (Art. 1 - lettera e)",
                      style: TextStyle(
                          fontSize: 8,
                          color: terms2ApprovalError == false
                              ? Colors.white
                              : Colors.red),
                    ),
                  )
                ]),
              ],
            ),
          ),
          Gap(15.h),
          GestureDetector(
            onTap: () {
              setState(() {
                terms3Approval = !terms3Approval;
                if (terms3Approval) terms3ApprovalError = false;
              });
            },
            child: Row(
              children: [
                //"Acconsento al trattamento dei miei dati personali a soggetti terzi, per finalità promozionali e informaztive (Art. 1 - lettera f)",
                Row(children: [
                  Icon(
                    terms3Approval == false
                        ? Icons.circle_outlined
                        : Icons.check_circle,
                    color: terms3ApprovalError == false
                        ? Colors.white
                        : Colors.red,
                    size: 18,
                  ),
                  Gap(15.w),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 140,
                    child: Text(
                      maxLines: 3,
                      "Acconsento al trattamento dei miei dati personali a soggetti terzi, per finalità promozionali e informaztive (Art. 1 - lettera f)",
                      style: TextStyle(
                          fontSize: 8,
                          color: terms3ApprovalError == false
                              ? Colors.white
                              : Colors.red),
                    ),
                  )
                ]),
              ],
            ),
          ),
        ],
      );
    } else
      return SizedBox.shrink();
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
              if (value == null || value.isEmpty) {
                return 'Inserisci una data';
              }

              // Controllo che sia nel formato gg/mm/aaaa usando regex
              final RegExp dateRegex = RegExp(r'^(\d{2})\/(\d{2})\/(\d{4})$');
              if (!dateRegex.hasMatch(value)) {
                return 'Formato data non valido. Usa gg/mm/aaaa';
              }

              // Estrai giorno, mese e anno
              final Match? match = dateRegex.firstMatch(value);
              final int day = int.parse(match!.group(1)!);
              final int month = int.parse(match.group(2)!);
              final int year = int.parse(match.group(3)!);

              // Usa DateTime per validare
              try {
                final parsedDate = DateTime(year, month, day);
                if (parsedDate.day != day ||
                    parsedDate.month != month ||
                    parsedDate.year != year) {
                  return 'Data non valida';
                }
              } catch (e) {
                return 'Data non valida';
              }

              return null; // Data valida
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
    _setupPasswordControllerListener();

    if (widget.currentDate == null) _loadServerDate();

    if (kDebugMode) {
      nameController.text = "Mattia";
      surnameController.text = "Morbidelli";
      emailController.text = "mattia.morbidelli@gmail.com";
      passwordController.text = "Mattia1998";
      addressController.text = "Via dei Beroardi, 83";
      birthdateController.text = "15/07/1998";
      birthplaceController.text = "Arezzo";
      capController.text = "52043";
      cityController.text = "Castiglion Fiorentino";
      telephoneController.text = "3496880713";
      passwordConfirmationController.text = "Mattia1998";
    }
  }

  void _loadServerDate() async {
    await fetchCurrentDateTime().then((dateTime) {
      setState(() {
        widget.currentDate = dateTime;
      });
    });
  }

  Widget loginButton(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 200,
        height: 40,
        decoration: BoxDecoration(
          color: Color.fromRGBO(17, 17, 17, 1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
            child: Text("Entra in UPPER",
                style: TextStyle(color: Colors.white, fontSize: 20))),
      ),
      onTap: () async {
        passwordFocusNode.unfocus();
        if (formKey.currentState!.validate()) {
          context
              .read<AppCubit>()
              .signInWithEmail(emailController.text, passwordController.text);
        }
      },
    );

//    return AppTextButton(
//      buttonText: "Entra in UPPER",
//
//      textStyle: TextStyles.font16White600Weight,
//      buttonWidth: 300,
//      buttonHeight: 70,
//      onPressed: () async {
//        passwordFocusNode.unfocus();
//        if (formKey.currentState!.validate()) {
//          context.read<AuthCubit>().signInWithEmail(
//                emailController.text,
//                passwordController.text,
//              );
//        }
//      },
//    );
  }

  loginOrSignUpOrPasswordButton(BuildContext context) {
    if (widget.isSignUpPage == true) {// && widget.currentDate != null) {
      return signUpButton(context);
    }
    //if (widget.isSignUpPage == true && widget.currentDate == null) {
    //  return SizedBox.shrink();
    //}
    if (widget.isSignUpPage == null) {
      return loginButton(context);
    }
  }

  Widget genericField(TextEditingController controller, String placeholder,
      String errorMessage) {
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
            isObscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
        validator: (value) {
          if (value != passwordController.text) {
            return 'Le password non corrispondono!';
          }
          if (value == null ||
              value.isEmpty ||
              !AppRegex.isPasswordValid(value)) {
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
          isObscureText
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
        ),
      ),
      validator: (value) {
        if (value == null ||
            value.isEmpty ||
            !AppRegex.isPasswordValid(value)) {
          return 'Inserisci una password valida!';
        }
      },
    );
  }

  void _setupPasswordControllerListener() {
    passwordController.addListener(() {
      setState(() {
        hasMinLength = AppRegex.isPasswordValid(passwordController.text);
      });
    });
  }

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  Widget signUpButton(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 200,
        height: 40,
        decoration: BoxDecoration(
          color: Color.fromRGBO(17, 17, 17, 1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
            child: Text("Iscriviti",
                style: TextStyle(color: Colors.white, fontSize: 20))),
      ),
      onTap: () async {
        passwordFocusNode.unfocus();
        passwordConfirmationFocusNode.unfocus();
        if (formKey.currentState!.validate()) {
          setState(() {
            terms1ApprovalError = !terms1Approval;
            terms2ApprovalError = !terms2Approval;
            terms3ApprovalError = !terms3Approval;
          });

          if (!terms1Approval || !terms2Approval || !terms3Approval) return;

          if (widget.currentDate == null) return;

          var user = up.User(
            name: capitalize(nameController.text),
            surname: capitalize(surnameController.text),
            address: capitalize(addressController.text),
            birthplace: capitalize(birthplaceController.text),
            email: emailController.text,
            birthdate: birthdateController.text,
            cap: capController.text,
            city: capitalize(cityController.text),
            telephone: telephoneController.text,
            signUpDate: widget.currentDate.toString(),
            cardNumber: 0,
          );

          //if (user.getAge() >= 18) {
          //    user.cardNumber = await context
          //        .read<AppCubit>().getNewIndex();
          //}

          context
              .read<AppCubit>()
              .signUpWithEmail(user, passwordController.text);
        }
      },
    );
  }
}
