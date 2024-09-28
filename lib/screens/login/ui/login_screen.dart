import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:upper/core/widgets/login_and_signup_animated_form.dart';
import 'package:upper/core/widgets/no_internet.dart';
import 'package:upper/core/widgets/progress_indicator.dart' as pi;
import 'package:upper/core/widgets/terms_and_conditions_text.dart';
import 'package:upper/helpers/extensions.dart';
import 'package:upper/logic/cubit/auth_cubit.dart';
import 'package:upper/routing/routes.dart';
import 'package:upper/screens/login/ui/widgets/do_not_have_account.dart';
import 'package:upper/theming/colors.dart';

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
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/upper.jpeg"), fit: BoxFit.cover),
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
    BlocProvider.of<AuthCubit>(context);
  }

  SafeArea _loginPage(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: BlocConsumer<AuthCubit, AuthState>(
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
                title: 'Error',
                desc: state.message,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
    );
  }
}
