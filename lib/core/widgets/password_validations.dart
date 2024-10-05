import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:upper/theming/colors.dart';
import 'package:upper/theming/styles.dart';

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
    return isSignup
        ? Row(
            children: [
              const CircleAvatar(
                radius: 3.5,
                backgroundColor: Colors.white,
              ),
              Gap(6.w),
              Text(
                text,
                style: TextStyles.font14White500Weight.copyWith(
                  decoration: hasValidated ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.green,
                  decorationThickness: 2,
                  color: hasValidated
                      ? ColorsManager.gray
                      : Colors.white,
                ),
              )
            ],
          )
        : const SizedBox.shrink();
  }
}
