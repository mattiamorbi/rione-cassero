import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import 'package:rione_cassero/core/widgets/login_and_signup_animated_form.dart';
import 'package:rione_cassero/core/widgets/no_internet.dart';
import 'package:rione_cassero/core/widgets/progress_indicator.dart' as pi;
import 'package:rione_cassero/core/widgets/terms_and_conditions_text.dart';
import 'package:rione_cassero/helpers/extensions.dart';
import 'package:rione_cassero/logic/cubit/app/app_cubit.dart';
import 'package:rione_cassero/routing/routes.dart';
import 'package:rione_cassero/screens/login/ui/widgets/do_not_have_account.dart';
import 'package:rione_cassero/theming/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          color: ColorsManager.background,
          //image: DecorationImage(
              //image: AssetImage("assets/images/upper.jpeg"), fit: BoxFit.cover),
        ),
        child: OfflineBuilder(
          connectivityBuilder: (context, value, child) {
            final bool connected =
                value.any((element) => element != ConnectivityResult.none);
            return connected ? _loginPage(context) : const BuildNoInternet();
          },
          child: const Center(
            child: CircularProgressIndicator(
              color: ColorsManager.mainBlue,
            ),
          ),
        ),
      ),
      extendBody: true,
    );
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AppCubit>(context);
  }

  Widget _loginPage(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: double.infinity,minHeight: double.infinity),
      color: ColorsManager.background,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0, right: 40, left: 40, bottom: 10),
          child: BlocConsumer<AppCubit, AppState>(
            buildWhen: (previous, current) => previous != current,
            listenWhen: (previous, current) => previous != current,
            listener: (context, state) async {
              if (state is AuthLoading) {
                pi.ProgressIndicator.showProgressIndicator(context);
              } else if (state is AuthError) {
                context.pop();
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.error,
                  animType: AnimType.rightSlide,
                  title: 'Errore',
                  desc: "Le credenziali inserite non sono corrette!",
                ).show();
              } else if (state is UserSignIn) {
                if (!context.mounted) return;
                context.pushNamedAndRemoveUntil(
                  Routes.homeScreen,
                  predicate: (route) => false,
                );
              } else if (state is UserNotVerified) {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.info,
                  animType: AnimType.rightSlide,
                  title: 'Email non verificata',
                  desc: 'Controlla la tua casella postale e verifica la tua email.',
                ).show();
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  SizedBox(width: 200, height: 200, child: Image(image: AssetImage("assets/images/cassero.jpeg"), fit: BoxFit.fitHeight ,)),
                  SizedBox(height: 20),
                  EmailAndPassword(),
                  Gap(20.h),
                  const DoNotHaveAccountText(),
                  Gap(10.h),
                  const TermsAndConditionsText(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
