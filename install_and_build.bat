@echo off
chcp 65001 >nul
echo =====================================================================
echo   تطبيق زاد (Zad) - حفظ النعمة وإنقاذ الطعام
echo   تم التصميم والبرمجة من قبل المهندس سلام الأعرجي
echo =====================================================================
flutter create . --org iq.zad --project-name zad_food_rescue
flutter pub get
flutter build windows --release
echo اكتمل البناء بنجاح في: build\windows\x64\runner\Release
pause
