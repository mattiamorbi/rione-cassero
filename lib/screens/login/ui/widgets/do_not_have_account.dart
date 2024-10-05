import 'package:flutter/material.dart';
import 'package:upper/core/widgets/app_text_button.dart';
import 'package:upper/helpers/extensions.dart';
import 'package:upper/routing/routes.dart';
import 'package:upper/theming/styles.dart';

class DoNotHaveAccountText extends StatelessWidget {
  const DoNotHaveAccountText({super.key});

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      child: Container(
        width: 200,
        height: 40,
        decoration: BoxDecoration(
          color: Color.fromRGBO(17, 17, 17, 1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(child: Text("Iscriviti", style: TextStyle(color: Colors.white, fontSize: 20))),

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
