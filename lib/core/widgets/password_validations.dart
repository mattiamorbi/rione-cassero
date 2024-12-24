import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:rione_cassero/theming/colors.dart';
import 'package:rione_cassero/theming/styles.dart';

class PasswordValidations extends StatelessWidget {
  final bool hasMinLength;
  final bool isSignup;

  const PasswordValidations(
      {super.key, required this.hasMinLength, required this.isSignup});

  @override
  Widget build(BuildContext context) {
    return buildValidationRow('La tua password deve essere di almeno 6 caratteri', hasMinLength);
  }

  Widget buildValidationRow(String text, bool hasValidated) {
    return isSignup && hasValidated == false
        ? Row(
            children: [
              CircleAvatar(
                radius: 3.5,
                backgroundColor: hasValidated ? Colors.green : Colors.red,
              ),
              Gap(6.w),
              Text(
                text,
                style: TextStyles.font14White500Weight.copyWith(
                  //decoration: hasValidated ? TextDecoration.lineThrough : null,
                  //decorationColor: Colors.green,
                  //decorationThickness: 2,
                  color: hasValidated
                      ? Colors.green
                      : Colors.red,
                ),
              )
            ],
          )
        : const SizedBox.shrink();
  }
}
