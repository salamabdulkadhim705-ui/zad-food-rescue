# إعداد التوقيع الرقمي لرفع التطبيق على Google Play Console

1. أنشئ مفتاح التوقيع الرقمي لمرة واحدة:
   keytool -genkey -v -keystore zad-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias zad_key

2. أنشئ ملف android/key.properties وضع فيه:
   storePassword=كلمة_المرور_الخاصة_بك
   keyPassword=كلمة_المرور_الخاصة_بك
   keyAlias=zad_key
   storeFile=../zad-release-key.jks

3. ابنِ حزمة المتجر المعتمدة (AAB):
   flutter build appbundle --release
