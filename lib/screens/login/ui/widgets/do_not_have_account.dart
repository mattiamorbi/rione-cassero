import 'package:flutter/material.dart';
import 'package:upper/core/widgets/app_text_button.dart';
import 'package:upper/helpers/extensions.dart';
import 'package:upper/routing/routes.dart';
import 'package:upper/theming/styles.dart';

class DoNotHaveAccountText extends StatelessWidget {
  const DoNotHaveAccountText({super.key});

  @override
  Widget build(BuildContext context) {
    return AppTextButton(
      buttonText: "Iscriviti",
      textStyle: TextStyles.font16White600Weight,
      buttonWidth: 300,
      buttonHeight: 70,
      onPressed: () => context.pushNamed(Routes.signupScreen),
    );
  }
}
