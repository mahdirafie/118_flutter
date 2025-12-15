import 'package:basu_118/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  const PasswordField({super.key, this.controller, this.validator});

  @override
  State<PasswordField> createState() => PasswordFieldState();
}

class PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      controller: widget.controller,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: 'رمز عبور',
        hintText: 'رمز عبور خود را وارد کنید...',
        labelStyle: TextStyle(
          color: AppColors.neutral[1000],
          backgroundColor: AppColors.neutral[50],
        ),
        hintStyle: TextStyle(color: AppColors.neutral[600]),
        filled: true,
        fillColor: AppColors.neutral[0],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutral[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.neutral[400]!),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? CupertinoIcons.eye : CupertinoIcons.eye_slash),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}