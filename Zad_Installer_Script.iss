[Setup]
AppName=زاد - حفظ النعمة وإنقاذ الطعام
AppVersion=1.0.0
AppPublisher=المهندس سلام الأعرجي
DefaultDirName={autopf}\ZadFoodRescue
DefaultGroupName=زاد - حفظ النعمة
OutputBaseFilename=Zad_Food_Rescue_Setup_Salam_AlAaraji
Compression=lzma
SolidCompression=yes

[Languages]
Name: "arabic"; MessagesFile: "compiler:Languages\Arabic.isl"

[Tasks]
Name: "desktopicon"; Description: "إنشاء اختصار على سطح المكتب"; GroupDescription: "اختصارات إضافية:"

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\زاد - حفظ النعمة"; Filename: "{app}\zad_food_rescue.exe"
Name: "{autodesktop}\زاد - حفظ النعمة"; Filename: "{app}\zad_food_rescue.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\zad_food_rescue.exe"; Description: "تشغيل تطبيق زاد الآن"; Flags: nowait postinstall skipifsilent
