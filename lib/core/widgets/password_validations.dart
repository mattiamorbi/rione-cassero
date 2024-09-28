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
    return buildValidationRow('At least 6 characters', hasMinLength);
  }

  Widget buildValidationRow(String text, bool hasValidated) {
    return isSignup
        ? Row(
            children: [
              const CircleAvatar(
                radius: 2.5,
                backgroundColor: ColorsManager.gray,
              ),
              Gap(6.w),
              Text(
                text,
                style: TextStyles.font14DarkBlue500Weight.copyWith(
                  decoration: hasValidated ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.green,
                  decorationThickness: 2,
                  color: hasValidated
                      ? ColorsManager.gray
                      : ColorsManager.darkBlue,
                ),
              )
            ],
          )
        : const SizedBox.shrink();
  }
}
