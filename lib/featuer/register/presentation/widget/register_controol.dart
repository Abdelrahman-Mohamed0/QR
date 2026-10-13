import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr/featuer/register/presentation/widget/email_verification_dialog.dart';

class RegisterController {
  final formKey = GlobalKey<FormState>();
  final userName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool isLoading = false;

  void dispose() {
    userName.dispose();
    email.dispose();
    password.dispose();
  }

  Future<void> register(BuildContext context, {VoidCallback? onStateChange}) async {
    if (formKey.currentState!.validate()) {
      isLoading = true;
      onStateChange?.call();

      try {
        final emailAddress = email.text.trim();
        final pass = password.text.trim();
        final name = userName.text.trim();

        // 1. إنشاء الحساب في Firebase Auth
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailAddress,
          password: pass,
        );

        final user = credential.user;

        if (user != null) {
          // 2. إرسال رابط التفعيل فوراً إلى بريد الـ Gmail
          try {
            await user.sendEmailVerification();
          } catch (e) {
            debugPrint("sendEmailVerification error: $e");
          }

          // 3. حفظ بيانات المستخدم في Firestore
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'uid': user.uid,
              'name': name,
              'email': emailAddress,
              'createdAt': FieldValue.serverTimestamp(),
            });
          } catch (e) {
            debugPrint("Firestore save error: $e");
          }
        }

        isLoading = false;
        onStateChange?.call();

        // 4. إظهار نافذة التحقق التفاعلية التي تفحص الرابط تلقائياً
        if (context.mounted && user != null) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => EmailVerificationWaitingDialog(
              user: user,
              email: emailAddress,
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        isLoading = false;
        onStateChange?.call();

        String message = "حدث خطأ أثناء إنشاء الحساب";
        if (e.code == 'weak-password') {
          message = "كلمة المرور ضعيفة جداً (يجب أن تكون 6 أحرف على الأقل)";
        } else if (e.code == 'email-already-in-use') {
          message = "هذا البريد الإلكتروني مسجل بالفعل! يرجى تسجيل الدخول به.";
        } else if (e.code == 'invalid-email') {
          message = "صيغة البريد الإلكتروني غير صحيحة";
        } else if (e.code == 'network-request-failed') {
          message = "فشل الاتصال بالإنترنت، يرجى التحقق من اتصالك بالشبكة.";
        } else if (e.code == 'too-many-requests') {
          message = "تم إجراء طلبات كثيرة جداً، يرجى الانتظار دقيقة والمحاولة ثانية.";
        } else if (e.message != null) {
          message = e.message!;
        }

        if (context.mounted) {
          _showError(context, message);
        }
      } catch (e) {
        isLoading = false;
        onStateChange?.call();
        if (context.mounted) {
          _showError(context, "خطأ: ${e.toString()}");
        }
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
