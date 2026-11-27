import 'package:latlong2/latlong.dart';
import '../models/models.dart';

class IraqData {
  static const List<SpiritualQuote> quotes = [
    SpiritualQuote(
      source: 'القرآن الكريم - سورة الأعراف (31)',
      text: '﴿وَكُلُوا وَاشْرَبُوا وَلَا تُسْرِفُوا ۚ إِنَّهُ لَا يُحِبُّ الْمُسْرِفِينَ﴾',
      contextNote: 'حفظ النعمة ومنع هدر الطعام واجب إنساني وشرعي.',
    ),
    SpiritualQuote(
      source: 'القرآن الكريم - سورة الإنسان (8)',
      text: '﴿وَيُطْعِمُونَ الطَّعَامَ عَلَىٰ حُبِّهِ مِسْكِينًا وَيَتِيمًا وَأَسِيرًا﴾',
      contextNote: 'بذل الطعام الطيب النظيف للمحتاجين.',
    ),
    SpiritualQuote(
      source: 'الإمام علي بن أبي طالب (عليه السلام)',
      text: '«مَاءُ وَجْهِكَ جَامِدٌ يُقْطِرُهُ السُّؤَالُ، فَانْظُرْ عِنْدَ مَنْ تُقْطِرُهُ»',
      contextNote: 'الاستلام الصامت عبر رمز QR يحفظ كرامة المتعففين دون إحراج.',
    ),
    SpiritualQuote(
      source: 'الإمام جعفر الصادق (عليه السلام)',
      text: '«إِنَّ اللَّهَ يُحِبُّ إِطْعَامَ الطَّعَامِ وَإِرَاقَةَ الدِّمَاءِ (الأضاحي)»',
      contextNote: 'التكافل الاجتماعي وإيصال الفائض لمستحقيه.',
    ),
  ];

  static const List<AdminRegion> regions = [
    AdminRegion(governorate: 'بابل', district: 'الحلة', subdistrict: 'المركز', area: 'حي الجمعية', center: LatLng(32.4722, 44.4328)),
    AdminRegion(governorate: 'بابل', district: 'الحلة', subdistrict: 'المركز', area: 'حي الجزائر', center: LatLng(32.4650, 44.4210)),
    AdminRegion(governorate: 'بابل', district: 'الحلة', subdistrict: 'أبي غرق', area: 'قرية الطهمازية', center: LatLng(32.4910, 44.3650)),
    AdminRegion(governorate: 'بابل', district: 'المحاويل', subdistrict: 'المركز', area: 'حي الشهداء', center: LatLng(32.6580, 44.4050)),
    AdminRegion(governorate: 'بابل', district: 'المسيب', subdistrict: 'سدة الهندية', area: 'حي المعلمين', center: LatLng(32.7150, 44.2780)),

    AdminRegion(governorate: 'بغداد', district: 'الكرادة', subdistrict: 'المركز', area: 'حي العرصات', center: LatLng(33.2985, 44.4265)),
    AdminRegion(governorate: 'بغداد', district: 'المنصور', subdistrict: 'المركز', area: 'حي اليرموك', center: LatLng(33.3015, 44.3420)),
    AdminRegion(governorate: 'بغداد', district: 'الأعظمية', subdistrict: 'المركز', area: 'حي السفينة', center: LatLng(33.3710, 44.3640)),

    AdminRegion(governorate: 'كربلاء المقدسة', district: 'المركز', subdistrict: 'الحر', area: 'حي الحسين', center: LatLng(32.6027, 44.0197)),
    AdminRegion(governorate: 'كربلاء المقدسة', district: 'الهندية', subdistrict: 'المركز', area: 'حي الزهراء', center: LatLng(32.5460, 44.2230)),

    AdminRegion(governorate: 'النجف الأشرف', district: 'المركز', subdistrict: 'المركز', area: 'حي الأمير', center: LatLng(32.0120, 44.3450)),
    AdminRegion(governorate: 'النجف الأشرف', district: 'الكوفة', subdistrict: 'المركز', area: 'حي ميسان', center: LatLng(32.0350, 44.3980)),

    AdminRegion(governorate: 'البصرة', district: 'المركز', subdistrict: 'العشار', area: 'حي الجزائر', center: LatLng(30.5085, 47.8210)),
  ];

  static List<SurplusOffer> initialOffers() {
    return [
      SurplusOffer(
        id: 'ZAD-101',
        title: 'صندوق معجنات وخبز ساخن (8 قطع)',
        category: 'مخبوزات',
        donorName: 'مخبز الفرات',
        isIndividual: false,
        governorate: 'بابل',
        district: 'الحلة',
        subdistrict: 'المركز',
        area: 'حي الجمعية',
        originalPrice: 8000,
        discountedPrice: 2500,
        isSilentEligible: true,
        expiresText: 'ينتهي خلال 45 دقيقة',
        coordinates: const LatLng(32.4742, 44.4355),
        remaining: 4,
      ),
      SurplusOffer(
        id: 'ZAD-102',
        title: 'وجبات غداء نظيفة غير ملموسة (فائض وليمة)',
        category: 'وجبات مطبوخة',
        donorName: 'متبرع كريم - أبو علي',
        isIndividual: true,
        governorate: 'بابل',
        district: 'الحلة',
        subdistrict: 'المركز',
        area: 'حي الجمعية',
        originalPrice: 0,
        discountedPrice: 0,
        isSilentEligible: true,
        expiresText: 'ينتهي خلال ساعة',
        coordinates: const LatLng(32.4710, 44.4372),
        remaining: 6,
      ),
      SurplusOffer(
        id: 'ZAD-103',
        title: 'وجبة دجاج مشوي مع أرز وسلطة',
        category: 'وجبات مطبوخة',
        donorName: 'مطعم النخيل',
        isIndividual: false,
        governorate: 'بابل',
        district: 'الحلة',
        subdistrict: 'المركز',
        area: 'حي الجمعية',
        originalPrice: 12000,
        discountedPrice: 3500,
        isSilentEligible: true,
        expiresText: 'ينتهي خلال 30 دقيقة',
        coordinates: const LatLng(32.4758, 44.4308),
        remaining: 3,
      ),
      SurplusOffer(
        id: 'ZAD-104',
        title: 'صندوق فواكه وخضار طازجة نهاية اليوم',
        category: 'فواكه وخضار',
        donorName: 'أسواق الكرادة الطازجة',
        isIndividual: false,
        governorate: 'بغداد',
        district: 'الكرادة',
        subdistrict: 'المركز',
        area: 'حي العرصات',
        originalPrice: 10000,
        discountedPrice: 3000,
        isSilentEligible: true,
        expiresText: 'ينتهي خلال ساعة',
        coordinates: const LatLng(33.3002, 44.4288),
        remaining: 5,
      ),
    ];
  }
}
