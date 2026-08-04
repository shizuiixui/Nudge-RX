import 'package:flutter/material.dart';

class TogglePassword extends StatelessWidget {
  const TogglePassword({
    super.key,
    required this.obscureText,
    required this.onPressed,
    this.color,
  });

  final bool obscureText;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final isTablet = shortestSide >= 600;
    final iconSize = isTablet ? 20.0 : 22.0;
    final buttonSize = isTablet ? 36.0 : 40.0;

    return IconButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      splashRadius: isTablet ? 18 : 20,
      constraints: BoxConstraints.tightFor(
        width: buttonSize,
        height: buttonSize,
      ),
      icon: Icon(
        obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
        color: color ?? const Color(0xFF9E9E9E),
        size: iconSize,
      ),
    );
  }
}
