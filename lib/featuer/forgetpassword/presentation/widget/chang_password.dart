import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr/core/helper/custom_button.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _changePassword() async {
    final newPass = passwordController.text.trim();
    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يجب ألا تقل كلمة المرور عن 6 أحرف")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.currentUser!.updatePassword(newPass);
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تغيير كلمة المرور بنجاح")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل تغيير كلمة المرور: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تعيين كلمة مرور جديدة"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "كلمة المرور الجديدة",
                hintText: "••••••••",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24.h),
            CustomButton(
              text: 'حفظ كلمة المرور',
              isLoading: _isLoading,
              onPressed: _changePassword,
            ),
          ],
        ),
      ),
    );
  }
}
