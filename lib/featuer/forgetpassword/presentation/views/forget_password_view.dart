import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:qr/core/helper/custom_button.dart';
import 'package:qr/core/utlis/router.dart';
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

    final email = _emailController.text.trim();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String message = 'حدث خطأ أثناء إرسال الرابط';
        if (e.code == 'user-not-found') {
          message = 'لا يوجد حساب مسجل بهذا البريد الإلكتروني.';
        } else if (e.code == 'invalid-email') {
          message = 'صيغة البريد الإلكتروني غير صحيحة.';
        } else if (e.code == 'network-request-failed') {
          message = 'يرجى التأكد من الاتصال بالإنترنت.';
        } else if (e.message != null) {
          message = e.message!;
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
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
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
                  subtitle: 'أدخل بريدك الإلكتروني وسنرسل لك رابط التعيين فوراً',
                  showBackButton: true,
                ),
                SizedBox(height: 36.h),

                if (!_emailSent) ...[
                  // حقل إدخال الإيميل
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
                          borderSide: const BorderSide(
                            color: Styles.kPrimaryColor,
                            width: 1.5,
                          ),
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
                  // شاشة النجاح والإرشاد
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: Column(
                      children: [
                        Container(
                          width: 86.r,
                          height: 86.r,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.mark_email_read_rounded,
                            size: 46.r,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'تم إرسال الرابط بنجاح! 🎉',
                          style: TextStyle(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.bold,
                            color: Styles.kTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'أرسلنا رابط إعادة تعيين كلمة المرور إلى:\n${_emailController.text.trim()}\n\n1. افتح رسالة Gmail.\n2. اضغط على الرابط واكتب كلمة المرور الجديدة.\n3. ارجع هنا وسجل دخولك بكلمة المرور الجديدة.',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Styles.kSubTextColor,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 32.h),
                        CustomButton(
                          text: 'العودة لتسجيل الدخول',
                          onPressed: () {
                            context.go(AppRouter.kLoginView,
                                extra: _emailController.text.trim());
                          },
                        ),
                        SizedBox(height: 16.h),
                        TextButton(
                          onPressed: () {
                            setState(() => _emailSent = false);
                          },
                          child: Text(
                            'إعادة الإرسال أو تغيير البريد',
                            style: TextStyle(
                              color: Styles.kPrimaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp,
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
