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
      title: '${AppConfig.appName} | ${AppConfig.developerCredit}',
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى تفعيل خدمة تحديد المواقع GPS في جهازك')),
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _userLocation = LatLng(pos.latitude, pos.longitude);
    });
    _mapController.move(_userLocation, 15.5);
  }

  double _calculateDistanceKm(LatLng start, LatLng end) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, start, end);
  }

  Future<void> _openTurnByTurnNavigation(LatLng destination) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=${_userLocation.latitude},${_userLocation.longitude}&destination=${destination.latitude},${destination.longitude}&travelmode=walking',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  List<LatLng> _buildRoutePolyline(LatLng start, LatLng end) {
    final midLat = (start.latitude + end.latitude) / 2 + 0.0007;
    final midLng = (start.longitude + end.longitude) / 2 - 0.0006;
    return [start, LatLng(midLat, midLng), end];
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 820;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF047857),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppConfig.appName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            Text(AppConfig.developerCredit, style: TextStyle(fontSize: 11)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث البيانات',
            icon: const Icon(Icons.refresh),
            onPressed: _loadOffers,
          ),
          IconButton(
            tooltip: 'تحديد موقعي الفعلي GPS',
            icon: const Icon(Icons.my_location),
            onPressed: _locateUserGPS,
          ),
        ],
      ),
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) => setState(() => _currentIndex = i),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.map), label: Text('الخريطة والعروض')),
                NavigationRailDestination(icon: Icon(Icons.qr_code_2), label: Text('الاستلام الصامت')),
                NavigationRailDestination(icon: Icon(Icons.add_business), label: Text('نشر طعام زائد')),
                NavigationRailDestination(icon: Icon(Icons.menu_book), label: Text('رسالة زاد والخصوصية')),
              ],
            ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _buildDiscoveryAndMapTab(),
                _buildSilentQrTab(),
                _buildPostSurplusTab(),
                _buildMissionAndPrivacyTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) => setState(() => _currentIndex = i),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.map_outlined), label: 'الخريطة'),
                NavigationDestination(icon: Icon(Icons.qr_code_2), label: 'بطاقتي'),
                NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'نشر فائض'),
                NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'عن زاد'),
              ],
            ),
    );
  }

  Widget _buildDiscoveryAndMapTab() {
    final quote = IraqData.quotes[_quoteIndex];

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Card(
          color: const Color(0xFFECFDF5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFA7F3D0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFF047857), size: 18),
                    const SizedBox(width: 6),
                    Text(quote.source, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF065F46))),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _quoteIndex = (_quoteIndex + 1) % IraqData.quotes.length;
                        });
                      },
                      child: const Text('التالي', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                Text(quote.text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.5)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('اختيار الموقع الإداري للمستلم:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width: 165,
                      child: DropdownButtonFormField<String>(
                        value: _selectedGov,
                        decoration: const InputDecoration(labelText: 'المحافظة', border: OutlineInputBorder(), isDense: true),
                        items: _governorates.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() {
                            _selectedGov = val;
                            _selectedDistrict = _districts.first;
                            _selectedSubdistrict = _subdistricts.first;
                            _selectedArea = _areas.first;
                          });
                          _updateMapToSelectedRegion();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 165,
                      child: DropdownButtonFormField<String>(
                        value: _selectedDistrict,
                        decoration: const InputDecoration(labelText: 'القضاء', border: OutlineInputBorder(), isDense: true),
                        items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() {
                            _selectedDistrict = val;
                            _selectedSubdistrict = _subdistricts.first;
                            _selectedArea = _areas.first;
                          });
                          _updateMapToSelectedRegion();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 165,
                      child: DropdownButtonFormField<String>(
                        value: _selectedSubdistrict,
                        decoration: const InputDecoration(labelText: 'الناحية', border: OutlineInputBorder(), isDense: true),
                        items: _subdistricts.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() {
                            _selectedSubdistrict = val;
                            _selectedArea = _areas.first;
                          });
                          _updateMapToSelectedRegion();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 165,
                      child: DropdownButtonFormField<String>(
                        value: _selectedArea,
                        decoration: const InputDecoration(labelText: 'الحي أو القرية', border: OutlineInputBorder(), isDense: true),
                        items: _areas.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() {
                            _selectedArea = val;
                          });
                          _updateMapToSelectedRegion();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 300,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userLocation,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'iq.zad.foodrescue',
                ),
                if (_selectedRouteOffer != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _buildRoutePolyline(_userLocation, _selectedRouteOffer!.coordinates),
                        strokeWidth: 5.0,
                        color: const Color(0xFF047857),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation,
                      width: 48,
                      height: 48,
                      child: const Tooltip(
                        message: 'موقعك الحالي',
                        child: Icon(Icons.person_pin_circle, color: Colors.blueAccent, size: 44),
                      ),
                    ),
                    ..._offers.map((offer) => Marker(
                          point: offer.coordinates,
                          width: 48,
                          height: 48,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedRouteOffer = offer),
                            child: Icon(
                              offer.isIndividual ? Icons.volunteer_activism : Icons.storefront,
                              color: offer.isIndividual ? Colors.amber[800] : const Color(0xFF047857),
                              size: 40,
                            ),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),

        if (_selectedRouteOffer != null) ...[
          const SizedBox(height: 10),
          Card(
            color: const Color(0xFFECFDF5),
            child: ListTile(
              leading: const Icon(Icons.directions, color: Color(0xFF047857), size: 34),
              title: Text('المسار إلى: ${_selectedRouteOffer!.donorName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'المسافة: ${_calculateDistanceKm(_userLocation, _selectedRouteOffer!.coordinates).toStringAsFixed(2)} كم (${_selectedRouteOffer!.area})',
              ),
              trailing: FilledButton.icon(
                onPressed: () => _openTurnByTurnNavigation(_selectedRouteOffer!.coordinates),
                icon: const Icon(Icons.navigation, size: 18),
                label: const Text('بدء التوجيه GPS'),
              ),
            ),
          ),
        ],

        const SizedBox(height: 14),
        Text('المطاعم والمتبرعون في $_selectedGov (${_offers.length}):',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        if (_isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
        else
          ..._offers.map((offer) {
            final dist = _calculateDistanceKm(_userLocation, offer.coordinates);
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Chip(
                          label: Text(offer.isIndividual ? 'شخص متبرع بطعام زائد' : 'مطعم / مخبز'),
                          backgroundColor: offer.isIndividual ? Colors.amber[100] : Colors.emerald[100],
                        ),
                        const Spacer(),
                        Text('${dist.toStringAsFixed(1)} كم • ${offer.expiresText}',
                            style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                    Text(offer.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${offer.donorName} • قضاء ${offer.district} - ${offer.area}'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() => _selectedRouteOffer = offer);
                            _mapController.move(offer.coordinates, 16.0);
                          },
                          icon: const Icon(Icons.alt_route, size: 18),
                          label: const Text('تحديد المسار'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: offer.remaining > 0
                                ? () async {
                                    final ok = await _repository.reserveOffer(offer);
                                    if (!ok) return;
                                    setState(() {
                                      _activeReservation = offer;
                                      _reservationCode = 'ZAD-${offer.id}-${Random().nextInt(8999) + 1000}';
                                      _currentIndex = 1;
                                    });
                                  }
                                : null,
                            child: Text(offer.discountedPrice == 0
                                ? 'حجز استلام صامت (مجاناً)'
                                : 'حجز (${offer.discountedPrice} د.ع)'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildSilentQrTab() {
    if (_activeReservation == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'لا يوجد حجز نشط حالياً.
اختر مطعماً أو متبرعاً من الخريطة لإصدار بطاقة الاستلام الصامت.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'قال الإمام علي (عليه السلام): «مَاءُ وَجْهِكَ جَامِدٌ يُقْطِرُهُ السُّؤَالُ، فَانْظُرْ عِنْدَ مَنْ تُقْطِرُهُ»',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF047857), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                QrImageView(
                  data: _reservationCode,
                  size: 200,
                ),
                const SizedBox(height: 10),
                Text('رمز الاستلام الموحد: $_reservationCode', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Divider(height: 24),
                Text(_activeReservation!.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                Text('المكان: ${_activeReservation!.donorName} (${_activeReservation!.area})'),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _openTurnByTurnNavigation(_activeReservation!.coordinates),
                  icon: const Icon(Icons.navigation),
                  label: const Text('فتح المسار المباشر في الخرائط'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostSurplusTab() {
    final titleController = TextEditingController();
    final donorController = TextEditingController();
    final qtyController = TextEditingController(text: '4');
    bool isIndividual = true;

    return StatefulBuilder(
      builder: (context, setFormState) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('نشر طعام زائد على الخريطة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('سيظهر الموقع في: $_selectedGov - قضاء $_selectedDistrict - $_selectedArea',
                style: const TextStyle(color: Color(0xFF047857), fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('متبرع فردي (منزل / مناسبة)')),
                ButtonSegment(value: false, label: Text('مطعم / مخبز')),
              ],
              selected: {isIndividual},
              onSelectionChanged: (s) => setFormState(() => isIndividual = s.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: donorController,
              decoration: const InputDecoration(labelText: 'اسم المتبرع أو المطعم', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'وصف الطعام النظيف المتاح', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'عدد الحصص / الصناديق', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                if (titleController.text.isEmpty || donorController.text.isEmpty) return;
                final newOffer = SurplusOffer(
                  id: 'ZAD-${Random().nextInt(900) + 100}',
                  title: titleController.text,
                  category: 'طعام طازج',
                  donorName: donorController.text,
                  isIndividual: isIndividual,
                  governorate: _selectedGov,
                  district: _selectedDistrict,
                  subdistrict: _selectedSubdistrict,
                  area: _selectedArea,
                  originalPrice: 0,
                  discountedPrice: 0,
                  isSilentEligible: true,
                  expiresText: 'متاح الآن لمدة ساعتين',
                  coordinates: LatLng(
                    _userLocation.latitude + 0.0011,
                    _userLocation.longitude + 0.0011,
                  ),
                  remaining: int.tryParse(qtyController.text) ?? 3,
                );
                await _repository.publishOffer(newOffer);
                await _loadOffers();
                setState(() => _currentIndex = 0);
              },
              icon: const Icon(Icons.publish),
              label: const Text('نشر وتثبيت الموقع على الخريطة'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMissionAndPrivacyTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('رسالة مشروع زاد لحفظ النعمة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
        const SizedBox(height: 6),
        const Text(
          AppConfig.developerCredit,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
        ),
        const SizedBox(height: 10),
        const Text(
          'منظومة إنسانية وتقنية تربط فائض الطعام النظيف من المطاعم والمخابز والمنازل بالأسر المتعففة والمستفيدين في نفس الحي أو القرية، مع تحديد المسار عبر GPS وصون كرامة المستلم.',
          style: TextStyle(fontSize: 15, height: 1.6),
        ),
        const SizedBox(height: 16),
        ...IraqData.quotes.map((q) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.source, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                    const SizedBox(height: 6),
                    Text(q.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.6)),
                    const SizedBox(height: 6),
                    Text(q.contextNote, style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            )),
        const Divider(height: 30),
        const Text('سياسة الخصوصية وأمان البيانات', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text(
          '• يستخدم التطبيق الموقع الجغرافي (GPS) فقط لعرض أقرب نقاط توزيع الطعام ورسم المسار للمستلم.
'
          '• نظام الاستلام الصامت (QR) يولّد رمزاً مشفراً مؤقتاً دون كشف هوية المستفيد.
'
          '• لا تتم مشاركة بيانات المستخدمين مع أي طرف إعلاني خارجي.',
          style: TextStyle(fontSize: 13, height: 1.6),
        ),
      ],
    );
  }
}
