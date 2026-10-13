class Validators {
  static String? userName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال اسم المستخدم';
    }
    if (value.trim().length < 3) {
      return 'يجب ألا يقل اسم المستخدم عن 3 أحرف';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'يرجى إدخال بريد إلكتروني صالح';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'يجب ألا تقل كلمة المرور عن 6 أحرف';
    }
    return null;
  }
}
