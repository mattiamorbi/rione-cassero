import 'package:flutter/material.dart';
import 'package:rione_cassero/helpers/extensions.dart';
import 'package:rione_cassero/routing/routes.dart';
import 'package:rione_cassero/theming/colors.dart';

class DoNotHaveAccountText extends StatelessWidget {
  const DoNotHaveAccountText({super.key});

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      child: Container(
        width: 200,
        height: 40,
        decoration: BoxDecoration(
          color: ColorsManager.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorsManager.gray17, width: 2),
        ),
        child: Center(child: Text("Iscriviti", style: TextStyle(color: ColorsManager.gray17, fontSize: 20))),

      ),
      onTap: () => context.pushNamed(Routes.signupScreen),
    );


//    return AppTextButton(
//      buttonText: "Iscriviti",
//      textStyle: TextStyles.font16White600Weight,
//      buttonWidth: 300,
//      buttonHeight: 70,
//      onPressed: () => context.pushNamed(Routes.signupScreen),
//    );
  }
}
