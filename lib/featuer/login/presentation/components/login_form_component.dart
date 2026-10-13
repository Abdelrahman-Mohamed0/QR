import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr/core/helper/custom_text_field.dart';
import 'package:qr/core/utlis/style.dart';

class Login extends StatelessWidget {
  final TextEditingController email;
  final TextEditingController password;

  const Login({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: email,
          hint: 'أدخل بريدك الإلكتروني',
          labelText: 'البريد الإلكتروني',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(
            Icons.email_outlined,
            color: Styles.kPrimaryColor,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'يرجى إدخال البريد الإلكتروني';
            }
            const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
            if (!RegExp(pattern).hasMatch(value.trim())) {
              return 'صيغة البريد الإلكتروني غير صحيحة';
            }
            return null;
          },
        ),
        SizedBox(height: 12.h),
        CustomTextField(
          controller: password,
          hint: '••••••••',
          labelText: 'كلمة المرور',
          isPassword: true,
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: Styles.kPrimaryColor,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال كلمة المرور';
            }
            if (value.length < 6) {
              return 'يجب ألا تقل كلمة المرور عن 6 أحرف';
            }
            return null;
          },
        ),
      ],
    );
  }
}
