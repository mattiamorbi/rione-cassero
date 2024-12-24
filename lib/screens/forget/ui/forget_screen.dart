import '../../../helpers/extensions.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import 'package:rione_cassero/core/widgets/already_have_account_text.dart';
import 'package:rione_cassero/core/widgets/progress_indicator.dart' as pi;
import 'package:rione_cassero/core/widgets/terms_and_conditions_text.dart';
import 'package:rione_cassero/logic/cubit/app/app_cubit.dart';
import 'package:rione_cassero/theming/colors.dart';
import 'package:rione_cassero/screens/forget/ui/widgets/password_reset.dart';

class ForgetScreen extends StatefulWidget {
  const ForgetScreen({super.key});

  @override
  State<ForgetScreen> createState() => _ForgetScreenState();
}

class _ForgetScreenState extends State<ForgetScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.background,
      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.only(left: 30.w, right: 30.w, bottom: 15.h, top: 20.h),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reset',
                              style: TextStyle(fontSize: 24, color: ColorsManager.gray17, fontWeight: FontWeight.bold),
                            ),
                            Gap(10.h),
                            Text(
                              "Inserisci la tua email per resettare la password",
                              style: TextStyle(fontSize: 14, color: ColorsManager.gray17, fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      Gap(20.h),
                      BlocConsumer<AppCubit, AppState>(
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
                              title: 'Error',
                              desc: state.message,
                            ).show();
                          } else if (state is ResetPasswordSent) {
                            context.pop();
                            context.pop();
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.info,
                              animType: AnimType.rightSlide,
                              title: 'Reset Password',
                              desc:
                                  'Il link per resettare la password è stato inviato alla tua e-mail',
                            ).show();
                          }
                        },
                        buildWhen: (previous, current) {
                          return previous != current;
                        },
                        builder: (context, state) {
                          return const PasswordReset();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Ensure minimum height
                  children: [
                    const TermsAndConditionsText(),
                    Gap(24.h),
                    const AlreadyHaveAccountText(),
                  ],
                ),
              ),
            ],
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
