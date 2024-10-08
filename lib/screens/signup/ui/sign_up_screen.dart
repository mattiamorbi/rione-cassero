import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:upper/core/widgets/already_have_account_text.dart';
import 'package:upper/core/widgets/login_and_signup_animated_form.dart';
import 'package:upper/core/widgets/progress_indicator.dart' as pi;
import 'package:upper/core/widgets/terms_and_conditions_text.dart';
import 'package:upper/helpers/extensions.dart';
import 'package:upper/logic/cubit/app/app_cubit.dart';
import 'package:upper/routing/routes.dart';
import 'package:upper/theming/styles.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(17, 17, 17, 1),
          //image: DecorationImage(image: AssetImage("assets/images/upper.jpeg"), fit: BoxFit.cover),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0, right: 40, left: 40, bottom: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Partecipa ad UPPER',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Gap(2.h),
                Text(
                  'Iscriviti ora per conoscere in anteprima i nostri eventi!',
                  style: TextStyles.font14White400Weight,
                ),
                Gap(20.h),
                BlocConsumer<AppCubit, AppState>(
                  buildWhen: (previous, current) => previous != current,
                  listenWhen: (previous, current) => previous != current,
                  listener: (context, state) async {
                    if (state is AuthLoading) {
                      pi.ProgressIndicator.showProgressIndicator(context);
                    } else if (state is AuthError) {
                      context.pop();
                      context.pop();
                      await AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.rightSlide,
                        title: 'Errore',
                        desc: state.message,
                      ).show();
                    } else if (state is UserSignIn) {
                      if (!context.mounted) return;
                      context.pushNamedAndRemoveUntil(
                        Routes.homeScreen,
                        predicate: (route) => false,
                      );
                    } else if (state is UserSignupButNotVerified) {
                      context.pop();
                      await AwesomeDialog(
                        context: context,
                        dialogType: DialogType.success,
                        animType: AnimType.rightSlide,
                        title: 'Iscrizione avvenuta con successo!',
                        desc: 'Non dimenticarti di controllare la tua casella di posta per verificare l\'email!',
                      ).show();
                      await Future.delayed(const Duration(seconds: 2));
                      if (!context.mounted) return;
                      context.pushNamedAndRemoveUntil(
                        Routes.loginScreen,
                        predicate: (route) => false,
                      );
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      children: [
                        EmailAndPassword(
                          isSignUpPage: true,
                        ),
                        Gap(10.h),
                        const TermsAndConditionsText(),
                        Gap(15.h),
                        const AlreadyHaveAccountText(),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AppCubit>(context);
  }
}
