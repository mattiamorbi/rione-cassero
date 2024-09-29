import 'package:flutter/material.dart';

import 'package:upper/helpers/extensions.dart';
import 'package:upper/routing/routes.dart';
import 'package:upper/theming/styles.dart';

class AlreadyHaveAccountText extends StatelessWidget {
  const AlreadyHaveAccountText({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamedAndRemoveUntil(
          Routes.loginScreen,
          predicate: (route) => false,
        );
      },
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Hai già un account?',
              style: TextStyles.font11DarkBlue400Weight,
            ),
            TextSpan(
              text: ' Entra in UPPER',
              style: TextStyles.font11Blue600Weight,
            ),
          ],
        ),
      ),
    );
  }
}
