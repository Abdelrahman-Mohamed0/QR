import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr/core/utlis/style.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String labelText;
  final Widget? prefixIcon;
  final Widget? suffix;
  final bool? isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.labelText,
    this.prefixIcon,
    this.isPassword = false,
    this.suffix,
    this.keyboardType,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    isVisible = widget.isPassword ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.labelText,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Styles.kTextColor.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 6.h),
          TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword == true ? isVisible : false,
            keyboardType: widget.keyboardType,
            style: TextStyle(
              fontSize: 15.sp,
              color: Styles.kTextColor,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: Styles.kSubTextColor.withOpacity(0.7),
                fontWeight: FontWeight.normal,
              ),
              filled: true,
              fillColor: Styles.kInputFillColor,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: widget.prefixIcon,
                    )
                  : null,
              prefixIconConstraints: BoxConstraints(
                minWidth: 40.w,
                minHeight: 24.h,
              ),
              suffixIcon: widget.isPassword == true
                  ? IconButton(
                      icon: Icon(
                        isVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Styles.kSubTextColor,
                        size: 20.r,
                      ),
                      onPressed: () {
                        setState(() {
                          isVisible = !isVisible;
                        });
                      },
                    )
                  : widget.suffix,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(
                  color: Styles.kBorderColor,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(
                  color: Styles.kPrimaryColor,
                  width: 1.8,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.8,
                ),
              ),
              errorStyle: TextStyle(
                color: Colors.redAccent,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            validator: widget.validator ??
                (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال ${widget.labelText}';
                  }
                  return null;
                },
          ),
        ],
      ),
    );
  }
}
