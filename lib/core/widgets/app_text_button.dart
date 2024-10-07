import 'package:flutter/material.dart';

class AppTextButton extends StatelessWidget {
  final double? borderRadius;
  final Color? backgroundColor;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? buttonWidth;
  final double? buttonHeight;
  final String buttonText;
  final Icon? buttonIcon;
  final TextStyle textStyle;
  final VoidCallback onPressed;

  const AppTextButton(
      {super.key,
      this.borderRadius,
      this.backgroundColor,
      this.horizontalPadding,
      this.verticalPadding,
      this.buttonWidth,
      this.buttonHeight,
      required this.buttonText,
      this.buttonIcon,
      required this.textStyle,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        decoration: BoxDecoration(
          color: Color.fromRGBO(17, 17, 17, 1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Visibility(
            visible: buttonText != "",
            child: Text(buttonText, style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
          Visibility(
              visible: buttonIcon != null,
              child: Icon(
                buttonIcon?.icon ?? Icons.add,
                color: Colors.white,
              )),
        ]),
      ),
    );
  }
}
