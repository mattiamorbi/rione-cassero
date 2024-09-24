import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import 'package:upper/core/widgets/login_and_signup_animated_form.dart';
import 'package:upper/core/widgets/no_internet.dart';
import 'package:upper/core/widgets/progress_indicator.dart' as pi;
import 'package:upper/core/widgets/sign_in_with_google_text.dart';
import 'package:upper/core/widgets/terms_and_conditions_text.dart';
import 'package:upper/helpers/extensions.dart';
import 'package:upper/helpers/rive_controller.dart';
import 'package:upper/logic/cubit/auth_cubit.dart';
import 'package:upper/routing/routes.dart';
import 'package:upper/theming/colors.dart';
import 'package:upper/theming/styles.dart';
import 'package:upper/screens/login/ui/widgets/do_not_have_account.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final RiveAnimationControllerHelper riveHelper =
      RiveAnimationControllerHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OfflineBuilder(
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
    );
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthCubit>(context);
  }

  SafeArea _loginPage(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(left: 30.w, right: 30.w, bottom: 15.h, top: 5.h),
        child: SingleChildScrollView(
          child: BlocConsumer<AuthCubit, AuthState>(
            buildWhen: (previous, current) => previous != current,
            listenWhen: (previous, current) => previous != current,
            listener: (context, state) async {
              if (state is AuthLoading) {
                pi.ProgressIndicator.showProgressIndicator(context);
              } else if (state is AuthError) {
                context.pop();
                riveHelper.addFailController();
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.error,
                  animType: AnimType.rightSlide,
                  title: 'Error',
                  desc: state.message,
                ).show();
              } else if (state is UserSignIn) {
                riveHelper.addSuccessController();
                await Future.delayed(const Duration(seconds: 2));
                riveHelper.dispose();
                if (!context.mounted) return;
                context.pushNamedAndRemoveUntil(
                  Routes.homeScreen,
                  predicate: (route) => false,
                );
              } else if (state is UserNotVerified) {
                riveHelper.addFailController();
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.info,
                  animType: AnimType.rightSlide,
                  title: 'Email Not Verified',
                  desc: 'Please check your email and verify your email.',
                ).show();
              } else if (state is IsNewUser) {
                context.pushNamedAndRemoveUntil(
                  Routes.createPassword,
                  predicate: (route) => false,
                  arguments: [state.googleUser, state.credential],
                );
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Login',
                          style: TextStyles.font24Blue700Weight,
                        ),
                        Gap(10.h),
                        Text(
                          "Login To Continue Using The App",
                          style: TextStyles.font14Grey400Weight,
                        ),
                      ],
                    ),
                  ),
                  EmailAndPassword(),
                  Gap(10.h),
                  const SigninWithGoogleText(),
                  Gap(5.h),
                  InkWell(
                    radius: 50.r,
                    onTap: () {
                      context.read<AuthCubit>().signInWithGoogle();
                    },
                    child: SvgPicture.asset(
                      'assets/svgs/google_logo.svg',
                      width: 40.w,
                      height: 40.h,
                    ),
                  ),
                  const TermsAndConditionsText(),
                  Gap(15.h),
                  const DoNotHaveAccountText(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
