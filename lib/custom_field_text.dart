import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText; // خاصية جديدة لتحديد ما إذا كان يجب إخفاء النص أم لا
  final Widget? suffixIcon; // خاصية جديدة لإضافة أيقونة في نهاية الحقل

  const CustomTextField({super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.obscureText = false, // القيمة الافتراضية هي false
    this.suffixIcon, // القيمة الافتراضية هي null
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText, // استخدم الخاصية الجديدة هنا
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
        labelStyle: const TextStyle(
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}