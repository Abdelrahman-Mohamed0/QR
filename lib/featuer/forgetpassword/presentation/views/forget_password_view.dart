import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr/core/helper/custom_button.dart';
import 'package:qr/core/utlis/style.dart';
import 'package:qr/featuer/login/presentation/widget/heder_login_widget.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String message = 'حدث خطأ، يرجى المحاولة مرة أخرى.';
        if (e.code == 'user-not-found') {
          message = 'لا يوجد حساب بهذا البريد الإلكتروني.';
        } else if (e.code == 'invalid-email') {
          message = 'صيغة البريد الإلكتروني غير صحيحة.';
        } else if (e.code == 'network-request-failed') {
          message = 'يرجى التأكد من الاتصال بالإنترنت.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const HederScrenWidget(
                  text: 'استعادة كلمة المرور',
                  subtitle: 'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين',
                  showBackButton: true,
                ),
                SizedBox(height: 40.h),

                if (!_emailSent) ...[
                  // Email field
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'يرجى إدخال البريد الإلكتروني';
                        }
                        if (!v.contains('@')) {
                          return 'صيغة البريد غير صحيحة';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        hintText: 'example@email.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: Styles.kInputFillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(color: Styles.kBorderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(color: Styles.kBorderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(
                              color: Styles.kPrimaryColor, width: 1.5),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 32.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: CustomButton(
                      text: 'إرسال رابط الاستعادة',
                      isLoading: _isLoading,
                      onPressed: _sendResetEmail,
                    ),
                  ),
                ] else ...[
                  // Success state
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Column(
                      children: [
                        Container(
                          width: 90.r,
                          height: 90.r,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.mark_email_read_outlined,
                            size: 48.r,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          'تم إرسال الرابط! 🎉',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'تم إرسال رابط إعادة تعيين كلمة المرور إلى:\n${_emailController.text.trim()}\n\nافتح بريدك الإلكتروني واضغط على الرابط لتعيين كلمة مرور جديدة.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 32.h),
                        CustomButton(
                          text: 'العودة لتسجيل الدخول',
                          onPressed: () => Navigator.pop(context),
                        ),
                        SizedBox(height: 16.h),
                        TextButton(
                          onPressed: () {
                            setState(() => _emailSent = false);
                          },
                          child: Text(
                            'إعادة الإرسال',
                            style: TextStyle(
                              color: Styles.kPrimaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

