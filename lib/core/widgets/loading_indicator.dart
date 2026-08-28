import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final Color color;
  final double strokeWidth;

  const LoadingIndicator({
    super.key,
    this.color = const Color(0xFF808080),
    this.strokeWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }
}
