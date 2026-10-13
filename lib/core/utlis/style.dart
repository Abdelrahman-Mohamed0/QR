import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class Styles {
  // Colors
  static const kPrimaryColor = Color(0xffFE7D55);
  static const kPrimaryLight = Color(0xffFFF0EB);
  static const kBackgroundColor = Color(0xffF8F9FD);
  static const kSurfaceColor = Colors.white;
  static const kTextColor = Color(0xff1C1E21);
  static const kSubTextColor = Color(0xff8A9099);
  static const kBorderColor = Color(0xffE8EAEF);
  static const kInputFillColor = Color(0xffF7F8FA);

  // Text Styles (with responsive support)
  static TextStyle get textStyle24 => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        color: kTextColor,
      );

  static TextStyle get textStyle16 => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: kTextColor,
      );

  static TextStyle get textStyle14 => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: kSubTextColor,
      );

  static TextStyle get textStyle12 => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xffB9B9B9),
      );

  // Box Shadows for cards & buttons
  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: kPrimaryColor.withOpacity(0.35),
          offset: const Offset(0, 6),
          blurRadius: 16,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          offset: const Offset(0, 4),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ];
}
