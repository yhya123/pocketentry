import 'package:pocketentry/core/errors/failures.dart';

class Validators {
  Validators._();

  static String? requiredField(
    String? value, {
    String fieldName = 'هذا الحقل',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  static String? name(String? value) {
    final required = requiredField(value, fieldName: 'الاسم');
    if (required != null) return required;
    if (value!.trim().length < 2) {
      return 'الاسم قصير جداً';
    }
    return null;
  }

  static String? phone(String? value) {
    final required = requiredField(value, fieldName: 'رقم الهاتف');
    if (required != null) return required;
    final cleaned = value!.replaceAll(RegExp(r'[\s\-+]'), '');
    if (!RegExp(r'^\d{7,15}$').hasMatch(cleaned)) {
      return 'رقم الهاتف غير صالح';
    }
    return null;
  }

  static String? amount(String? value) {
    final required = requiredField(value, fieldName: 'المبلغ');
    if (required != null) return required;
    final parsed = double.tryParse(value!.replaceAll(',', ''));
    if (parsed == null || parsed <= 0) {
      return 'أدخل مبلغاً صحيحاً أكبر من صفر';
    }
    return null;
  }

  static double parseAmount(String value) {
    return double.parse(value.replaceAll(',', ''));
  }

  static void throwIfEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      throw ValidationFailure('$fieldName مطلوب');
    }
  }
}
