import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:rione_cassero/theming/styles.dart';

class TermsAndConditionsText extends StatelessWidget {
  const TermsAndConditionsText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Iscrivendoti al Rione Cassero, accetti i nostri',
            style: TextStyles.font11White400Weight,
          ),
          TextSpan(
            text: ' Termini e condizioni',
            style: TextStyles.font11Blue600Weight,
          ),
          TextSpan(
            text: ' e',
            style: TextStyles.font11White400Weight
                .copyWith(height: 4.h),
          ),
          TextSpan(
            text: ' PrivacyPolicy.',
            style: TextStyles.font11Blue600Weight,
          ),
        ],
      ),
    );
  }
}
