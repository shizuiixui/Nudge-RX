import 'package:flutter/material.dart';

InputDecoration textInputField(
  String hintText, {

  IconData? prefixIcon,
  IconData? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: const Color(0XFFB0B0B0)),

    prefixIcon: prefixIcon != null
        ? Icon(prefixIcon, color: const Color(0XFFB0B0B0))
        : null,

    suffixIcon: suffixIcon != null
        ? Icon(suffixIcon, color: const Color(0XFFB0B0B0))
        : null,

    // Border
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),

    // Enabled Border
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0XFFB0B0B0), width: 1),
      borderRadius: BorderRadius.circular(30),
    ),

    // Focused Border
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFF0C8CE9), width: 2),
      borderRadius: BorderRadius.circular(30),
    ),

    // Error Border
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0XFFDC3545), width: 1),
      borderRadius: BorderRadius.circular(30),
    ),

    // Focused Error Border
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0XFFDC3545), width: 2),
      borderRadius: BorderRadius.circular(30),
    )
  );
}
