import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:qr/core/helper/custom_button.dart';
import 'package:qr/core/utlis/router.dart';
import 'package:qr/core/utlis/style.dart';
import 'package:qr/featuer/forgetpassword/presentation/widget/text_forget_password.dart';
import 'package:qr/featuer/login/presentation/components/login_form_component.dart';
import 'package:qr/featuer/login/presentation/widget/heder_login_widget.dart';

class LoginHome extends StatefulWidget {
  final String? initialEmail;
  const LoginHome({super.key, this.initialEmail});

  @override
  State<LoginHome> createState() => _LoginHomeState();
}

class _LoginHomeState extends State<LoginHome> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      email.text = widget.initialEmail!;
    }
    _checkLogin();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void _checkLogin() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified && mounted) {
        context.go(AppRouter.kScanqr);
      } else if (user != null && !user.emailVerified) {
        await FirebaseAuth.instance.signOut();
      }
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      User? user = credential.user;

      if (user != null) {
        // تحديث بيانات المستخدم للتحقق من حالة تفعيل الإيميل
        await user.reload();
        user = FirebaseAuth.instance.currentUser;

        // إذا لم يكن الإيميل مفعلاً
        if (user != null && !user.emailVerified) {
          await FirebaseAuth.instance.signOut();

          if (mounted) {
            setState(() => _isLoading = false);

            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 28),
                    SizedBox(width: 8),
                    Text('الحساب غير مفعّل'),
                  ],
                ),
                content: const Text(
                  'هذا الحساب غير مفعّل، يجب إنشاء حساب أولاً.',
                  style: TextStyle(fontSize: 15, height: 1.5),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      GoRouter.of(context).push(AppRouter.kRegister);
                    },
                    child: const Text(
                      'إنشاء حساب الآن',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Styles.kPrimaryColor,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('حسناً'),
                  ),
                ],
              ),
            );
          }
          return;
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
        context.go(AppRouter.kScanqr);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String message = "حدث خطأ أثناء تسجيل الدخول";
        if (e.code == 'user-not-found') {
          message = 'هذا الحساب غير موجود، يجب إنشاء حساب أولاً.';
        } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          message = 'بيانات الدخول غير صحيحة، أو الحساب غير مسجل. يجب إنشاء حساب أولاً.';
        } else if (e.code == 'invalid-email') {
          message = 'صيغة البريد الإلكتروني غير صحيحة.';
        } else if (e.code == 'network-request-failed') {
          message = 'يرجى التأكد من اتصال الهاتف بالإنترنت.';
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
                  text: 'تسجيل الدخول',
                  subtitle: 'أهلاً بك مجدداً! يرجى إدخال بياناتك للمتابعة',
                ),
                SizedBox(height: 24.h),

                Login(email: email, password: password),

                SizedBox(height: 8.h),
                const ForgetPassword(),

                SizedBox(height: 32.h),
                CustomButton(
                  text: 'تسجيل الدخول',
                  isLoading: _isLoading,
                  onPressed: _login,
                ),

                SizedBox(height: 28.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Styles.kInputFillColor,
                    borderRadius: BorderRadius.circular(25.r),
                    border: Border.all(color: Styles.kBorderColor.withOpacity(0.6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ليس لديك حساب؟ ',
                        style: Styles.textStyle14,
                      ),
                      GestureDetector(
                        onTap: () {
                          GoRouter.of(context).push(AppRouter.kRegister);
                        },
                        child: Text(
                          'إنشاء حساب جديد',
                          style: Styles.textStyle14.copyWith(
                            color: Styles.kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
