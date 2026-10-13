import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:qr/core/helper/custom_button.dart';
import 'package:qr/core/helper/custom_text_field.dart';
import 'package:qr/core/utlis/router.dart';
import 'package:qr/core/utlis/style.dart';
import 'package:qr/core/utlis/validoter.dart';
import 'package:qr/featuer/login/presentation/widget/heder_login_widget.dart';
import 'package:qr/featuer/register/presentation/widget/register_controol.dart';

class RegisterHome extends StatefulWidget {
  const RegisterHome({super.key});

  @override
  State<RegisterHome> createState() => _RegisterHomeState();
}

class _RegisterHomeState extends State<RegisterHome> {
  final controller = RegisterController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
            key: controller.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                const HederScrenWidget(
                  text: 'إنشاء حساب جديد',
                  subtitle: 'ابدأ الآن لمسح وإدارة أكواد الـ QR بسهولة',
                  showBackButton: true,
                ),
                SizedBox(height: 24.h),

                CustomTextField(
                  controller: controller.userName,
                  hint: 'أدخل اسمك بالكامل',
                  labelText: 'اسم المستخدم',
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    color: Styles.kPrimaryColor,
                  ),
                  validator: Validators.userName,
                ),
                SizedBox(height: 12.h),

                CustomTextField(
                  controller: controller.email,
                  hint: 'أدخل بريدك الإلكتروني',
                  labelText: 'البريد الإلكتروني',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Styles.kPrimaryColor,
                  ),
                  validator: Validators.email,
                ),
                SizedBox(height: 12.h),

                CustomTextField(
                  controller: controller.password,
                  hint: '••••••••',
                  labelText: 'كلمة المرور',
                  isPassword: true,
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: Styles.kPrimaryColor,
                  ),
                  validator: Validators.password,
                ),

                SizedBox(height: 32.h),

                CustomButton(
                  text: "إنشاء حساب",
                  isLoading: controller.isLoading,
                  onPressed: () => controller.register(
                    context,
                    onStateChange: () => setState(() {}),
                  ),
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
                      Text('لديك حساب بالفعل؟ ', style: Styles.textStyle14),
                      GestureDetector(
                        onTap: () {
                          GoRouter.of(context).push(AppRouter.kLoginView);
                        },
                        child: Text(
                          'تسجيل الدخول',
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
