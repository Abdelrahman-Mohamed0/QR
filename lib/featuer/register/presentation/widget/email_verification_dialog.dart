import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:qr/core/utlis/router.dart';
import 'package:qr/core/utlis/style.dart';

class EmailVerificationWaitingDialog extends StatefulWidget {
  final User user;
  final String email;

  const EmailVerificationWaitingDialog({
    super.key,
    required this.user,
    required this.email,
  });

  @override
  State<EmailVerificationWaitingDialog> createState() =>
      _EmailVerificationWaitingDialogState();
}

class _EmailVerificationWaitingDialogState
    extends State<EmailVerificationWaitingDialog> {
  Timer? _timer;
  bool _isVerified = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  void _startVerificationCheck() {
    // فحص دوري كل ثانيتين ونصف للتأكد من قيام المستخدم بالضغط على الرابط في Gmail
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (timer) async {
      try {
        await widget.user.reload();
        final freshUser = FirebaseAuth.instance.currentUser;

        if (freshUser != null && freshUser.emailVerified) {
          timer.cancel();

          if (mounted) {
            setState(() {
              _isVerified = true;
            });

            // إعطاء فرصة نصف ثانية للمستخدم لرؤية علامة النجاح
            await Future.delayed(const Duration(milliseconds: 700));

            if (mounted) {
              Navigator.of(context, rootNavigator: true).pop();

              // تسجيل الخروج حتى يسجل دخوله من شاشة تسجيل الدخول
              await FirebaseAuth.instance.signOut();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم تأكيد الحساب بنجاح! 🎉 يرجى تسجيل الدخول الآن.'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              );

              // التوجيه تلقائياً إلى شاشة تسجيل الدخول مع تمرير الإيميل
              context.go(AppRouter.kLoginView, extra: widget.email);
            }
          }
        }
      } catch (e) {
        debugPrint("Error reloading user: $e");
      }
    });
  }

  Future<void> _resendVerification() async {
    setState(() => _isResending = true);
    try {
      await widget.user.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت إعادة إرسال رابط التفعيل، تفقد بريدك (وصندوق Spam).'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر إعادة الإرسال: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _isVerified
                ? Container(
                    key: const ValueKey('success'),
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 54.r,
                    ),
                  )
                : Container(
                    key: const ValueKey('waiting'),
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Styles.kPrimaryColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mark_email_unread_rounded,
                      color: Styles.kPrimaryColor,
                      size: 54.r,
                    ),
                  ),
          ),
          SizedBox(height: 18.h),
          Text(
            _isVerified ? 'تم تأكيد الحساب بنجاح!' : 'بانتظار تأكيد البريد',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Styles.kTextColor,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            _isVerified
                ? 'جاري نقلك إلى صفحة تسجيل الدخول...'
                : 'أرسلنا رابط تفعيل إلى بريدك:\n${widget.email}\n\nيرجى فتح بريد Gmail والضغط على الرابط، وستختفي هذه الرسالة تلقائياً فور التأكيد.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: Styles.kSubTextColor,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20.h),
          if (!_isVerified) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(Styles.kPrimaryColor),
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  'جاري التحقق تلقائياً...',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Styles.kPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () async {
                    _timer?.cancel();
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                  },
                  child: Text(
                    'إلغاء',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey,
                    ),
                  ),
                ),
                _isResending
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton(
                        onPressed: _resendVerification,
                        child: Text(
                          'إعادة إرسال الرابط',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: Styles.kPrimaryColor,
                          ),
                        ),
                      ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

