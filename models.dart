import 'package:latlong2/latlong.dart';

class AdminRegion {
  final String governorate;
  final String district;
  final String subdistrict;
  final String area;
  final LatLng center;

  const AdminRegion({
    required this.governorate,
    required this.district,
    required this.subdistrict,
    required this.area,
    required this.center,
  });

  String get fullLabel => '$governorate - قضاء $district - ناحية $subdistrict - $area';
}

class SurplusOffer {
  final String id;
  final String title;
  final String category;
  final String donorName;
  final bool isIndividual;
  final String governorate;
  final String district;
  final String subdistrict;
  final String area;
  final int originalPrice;
  final int discountedPrice;
  final bool isSilentEligible;
  final String expiresText;
  final LatLng coordinates;
  int remaining;

  SurplusOffer({
    required this.id,
    required this.title,
    required this.category,
    required this.donorName,
    required this.isIndividual,
    required this.governorate,
    required this.district,
    required this.subdistrict,
    required this.area,
    required this.originalPrice,
    required this.discountedPrice,
    required this.isSilentEligible,
    required this.expiresText,
    required this.coordinates,
    required this.remaining,
  });

  factory SurplusOffer.fromJson(Map<String, dynamic> json) {
    return SurplusOffer(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      category: json['category'] ?? 'عام',
      donorName: json['donor_name'] ?? '',
      isIndividual: json['is_individual'] ?? false,
      governorate: json['governorate'] ?? 'بابل',
      district: json['district'] ?? 'الحلة',
      subdistrict: json['subdistrict'] ?? 'المركز',
      area: json['area_name'] ?? '',
      originalPrice: json['original_price'] ?? 0,
      discountedPrice: json['discounted_price'] ?? 0,
      isSilentEligible: json['is_silent_eligible'] ?? true,
      expiresText: json['expires_text'] ?? 'متاح الآن',
      coordinates: LatLng(
        (json['lat'] as num).toDouble(),
        (json['lng'] as num).toDouble(),
      ),
      remaining: json['quantity_remaining'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'donor_name': donorName,
      'is_individual': isIndividual,
      'governorate': governorate,
      'district': district,
      'subdistrict': subdistrict,
      'area_name': area,
      'original_price': originalPrice,
      'discounted_price': discountedPrice,
      'is_silent_eligible': isSilentEligible,
      'lat': coordinates.latitude,
      'lng': coordinates.longitude,
      'quantity_remaining': remaining,
    };
  }
}

class SpiritualQuote {
  final String source;
  final String text;
  final String contextNote;

  const SpiritualQuote({
    required this.source,
    required this.text,
    required this.contextNote,
  });
}
