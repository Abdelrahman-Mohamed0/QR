import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qr/core/utlis/assets.dart';
import 'package:qr/core/utlis/style.dart';

class HederScrenWidget extends StatefulWidget {
  final String text;
  final String? subtitle;
  final bool showBackButton;

  const HederScrenWidget({
    super.key,
    required this.text,
    this.subtitle,
    this.showBackButton = false,
  });

  @override
  State<HederScrenWidget> createState() => _HederScrenWidgetState();
}

class _HederScrenWidgetState extends State<HederScrenWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.subtitle != null ? 230.h : 200.h,
      width: double.infinity,
      child: Stack(
        children: [
          // الخلفية الزخرفية العلوية اليسرى
          Positioned(
            top: -15.h,
            left: -20.w,
            child: Opacity(
              opacity: 0.9,
              child: SvgPicture.asset(
                AssetsData.tap1,
                width: 250.w,
                height: 170.h,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // الخلفية الزخرفية العلوية اليمنى
          Positioned(
            top: -10.h,
            right: -15.w,
            child: Opacity(
              opacity: 0.85,
              child: SvgPicture.asset(
                AssetsData.tap2,
                height: 130.h,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // زر الرجوع إذا كان مطلوباً
          if (widget.showBackButton)
            Positioned(
              top: 40.h,
              right: 16.w,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18.r,
                      color: Styles.kTextColor,
                    ),
                  ),
                ),
              ),
            ),

          // النصوص الرئيسية مع حركة انسيابية مريحة
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // أيقونة شارة صغيرة وجميلة
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: Styles.kPrimaryLight,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Styles.kPrimaryColor.withOpacity(0.18),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Styles.kPrimaryColor,
                          size: 24.r,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // العنوان الرئيسي
                      Text(
                        widget.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: Styles.kTextColor,
                          letterSpacing: 0.3,
                        ),
                      ),

                      // النص التوضيحي المساعد (إذا وُجد)
                      if (widget.subtitle != null) ...[
                        SizedBox(height: 6.h),
                        Text(
                          widget.subtitle!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Styles.kSubTextColor,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                      ],
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
