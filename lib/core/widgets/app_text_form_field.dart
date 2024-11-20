import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:upper/theming/colors.dart';

class AppTextFormField extends StatelessWidget {
  final String hint;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final bool? isObscureText;
  final bool? isDense;
  final TextEditingController? controller;
  final Function(String?) validator;
  const AppTextFormField({
    super.key,
    required this.hint,
    this.suffixIcon,
    this.prefixIcon,
    this.isObscureText,
    this.isDense,
    this.controller,
    this.onChanged,
    this.focusNode,
    required this.validator,
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,

      validator: (value) {
        return validator(value);
      },
      onChanged: onChanged,
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 30.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black38,
        ),
        isDense: isDense ?? true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 17.h),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 1.3.w,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 1.3.w,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: ColorsManager.coralRed,
            width: 1.3.w,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: ColorsManager.coralRed,
            width: 1.3.w,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      ),
      obscureText: isObscureText ?? false,
      style: TextStyle(
        fontSize: 30.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }
}
