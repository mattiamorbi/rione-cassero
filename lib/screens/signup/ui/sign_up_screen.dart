import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:rione_cassero/core/widgets/already_have_account_text.dart';
import 'package:rione_cassero/core/widgets/login_and_signup_animated_form.dart';
import 'package:rione_cassero/core/widgets/progress_indicator.dart' as pi;
import 'package:rione_cassero/core/widgets/terms_and_conditions_text.dart';
import 'package:rione_cassero/helpers/extensions.dart';
import 'package:rione_cassero/logic/cubit/app/app_cubit.dart';
import 'package:rione_cassero/routing/routes.dart';
import 'package:rione_cassero/theming/styles.dart';
import 'package:rione_cassero/theming/colors.dart';

import '../../../helpers/server_date.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  //DateTime? _currentDateTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: ColorsManager.background,
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
                  style: TextStyle(color: ColorsManager.gray17, fontSize: 20),
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
                        desc: "Le credenziali inserite non sono valide",
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
                          //currentDate: _currentDateTime,
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
  //  if (_currentDateTime == null) _loadServerDate();
  }

  //void _loadServerDate() async {
  //  await fetchCurrentDateTime().then((dateTime) {
  //    setState(() {
  //      _currentDateTime = dateTime;
  //      print(_currentDateTime.toString());
  //    });
  //  });
  //}
}
