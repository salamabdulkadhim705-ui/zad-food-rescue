class AppConfig {
  static const String appName = 'زاد | حفظ النعمة وإنقاذ الطعام';
  static const String appVersion = '1.0.0';
  static const String developerCredit = 'تم التصميم والبرمجة من قبل المهندس سلام الأعرجي';
  static const String supportEmail = 'support@zad-iq.org';
  static const String privacyPolicyUrl = 'https://zad-iq.org/privacy-policy';

  // إعدادات الربط السحابي (Supabase) للتطوير المستقبلي والتزامن الحي بين المستخدمين
  // ضع مفاتيح مشروعك هنا لتفعيل المزامنة السحابية الفورية بدلاً من الوضع المحلي التجريبي
  static const String supabaseUrl = '';
  static const String supabaseAnonKey = '';

  static bool get isCloudEnabled => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
