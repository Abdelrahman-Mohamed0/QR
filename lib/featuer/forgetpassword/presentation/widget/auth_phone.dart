import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr/core/helper/custom_button.dart';
import 'package:qr/featuer/forgetpassword/presentation/widget/chang_password.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String verificationId = "";
  bool codeSent = false;
  bool _isLoading = false;

  String formatPhoneNumber(String phone) {
    phone = phone.trim();
    if (phone.startsWith("0")) {
      return "+2$phone";
    } else if (!phone.startsWith("+")) {
      return "+2$phone";
    }
    return phone;
  }

  Future<void> _sendCode() async {
    String phone = formatPhoneNumber(phoneController.text);
    setState(() => _isLoading = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "فشل إرسال كود التحقق")),
        );
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
          codeSent = true;
          _isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
  }

  Future<void> _verifyCode() async {
    setState(() => _isLoading = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text.trim(),
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      setState(() => _isLoading = false);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("كود التحقق غير صحيح")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("استعادة كلمة المرور"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            if (!codeSent) ...[
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: "رقم الهاتف",
                  hintText: "010xxxxxxxx",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 24.h),
              CustomButton(
                text: 'إرسال كود التحقق',
                isLoading: _isLoading,
                onPressed: _sendCode,
              ),
            ] else ...[
              TextField(
                controller: otpController,
                decoration: InputDecoration(
                  labelText: "أدخل كود التحقق",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24.h),
              CustomButton(
                text: 'تأكيد الكود',
                isLoading: _isLoading,
                onPressed: _verifyCode,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
