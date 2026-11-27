import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'core/app_config.dart';
import 'models/models.dart';
import 'data/iraq_regions.dart';
import 'services/surplus_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.isCloudEnabled) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }

  runApp(const ZadApp());
}

class ZadApp extends StatelessWidget {
  const ZadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${AppConfig.appName} \vert{}${AppConfig.developerCredit}',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'IQ'),
      supportedLocales: const [Locale('ar', 'IQ')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF047857),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  int _quoteIndex = 0;
  final MapController _mapController = MapController();
  final SurplusRepository _repository = SurplusRepository();

  String _selectedGov = 'بابل';
  String _selectedDistrict = 'الحلة';
  String _selectedSubdistrict = 'المركز';
  String _selectedArea = 'حي الجمعية';

  LatLng _userLocation = const LatLng(32.4705, 44.4300);
  SurplusOffer? _selectedRouteOffer;
  SurplusOffer? _activeReservation;
  String _reservationCode = '';
  List<SurplusOffer> _offers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() => _isLoading = true);
    final data = await _repository.fetchOffersByGovernorate(_selectedGov);
    if (!mounted) return;
    setState(() {
      _offers = data;
      _isLoading = false;
    });
  }

  List<String> get _governorates =>
      IraqData.regions.map((r) => r.governorate).toSet().toList();

  List<String> get _districts => IraqData.regions
      .where((r) => r.governorate == _selectedGov)
      .map((r) => r.district)
      .toSet()
      .toList();

  List<String> get _subdistricts => IraqData.regions
      .where((r) => r.governorate == _selectedGov && r.district == _selectedDistrict)
      .map((r) => r.subdistrict)
      .toSet()
      .toList();

  List<String> get _areas => IraqData.regions
      .where((r) =>
          r.governorate == _selectedGov &&
          r.district == _selectedDistrict &&
          r.subdistrict == _selectedSubdistrict)
      .map((r) => r.area)
      .toSet()
      .toList();

  void _updateMapToSelectedRegion() {
    final match = IraqData.regions.firstWhere(
      (r) =>
          r.governorate == _selectedGov &&
          r.district == _selectedDistrict &&
          r.subdistrict == _selectedSubdistrict &&
          r.area == _selectedArea,
      orElse: () => IraqData.regions.first,
    );
    setState(() {
      _userLocation = LatLng(match.center.latitude - 0.0014, match.center.longitude - 0.0014);
      _selectedRouteOffer = null;
    });
    _mapController.move(match.center, 15.0);
    _loadOffers();
  }

  Future<void> _locateUserGPS() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of
