import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/address_controller.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final AddressController _addressController = Get.find<AddressController>();
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _houseCtrl = TextEditingController();
  final TextEditingController _areaCtrl = TextEditingController();
  final TextEditingController _thanaCtrl = TextEditingController();
  final TextEditingController _zilaCtrl = TextEditingController();
  final TextEditingController _postalCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();

  static const LatLng _dhaka = LatLng(23.8103, 90.4125);

  GoogleMapController? _controller;
  LatLng _currentCenter = _dhaka;
  bool _mapReady = false;
  bool _fillingFromMap = false;
  bool _isCameraMoving = false;
  bool _searching = false;
  String _selectedType = "Home";
  List<_SearchResult> _results = [];

  @override
  void dispose() {
    _controller?.dispose();
    _searchCtrl.dispose();
    _houseCtrl.dispose();
    _areaCtrl.dispose();
    _thanaCtrl.dispose();
    _zilaCtrl.dispose();
    _postalCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _runSearch() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() {
      _searching = true;
      _results = [];
    });
    try {
      final locations = await locationFromAddress(q);
      final top = locations.take(5).toList();
      final results = <_SearchResult>[];
      for (final item in top) {
        String label = "${item.latitude.toStringAsFixed(4)}, ${item.longitude.toStringAsFixed(4)}";
        try {
          final placemarks = await placemarkFromCoordinates(item.latitude, item.longitude);
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            label = [p.street, p.locality, p.administrativeArea]
                .where((v) => (v ?? "").trim().isNotEmpty)
                .join(", ");
          }
        } catch (_) {
          // fallback label
        }
        results.add(_SearchResult(label: label, latLng: LatLng(item.latitude, item.longitude)));
      }
      if (!mounted) return;
      setState(() => _results = results);
    } catch (_) {
      if (!mounted) return;
      setState(() => _results = []);
      Get.snackbar("Search", "Location not found");
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _applyReverseToFields(LatLng ll) async {
    setState(() => _fillingFromMap = true);
    try {
      final places = await placemarkFromCoordinates(ll.latitude, ll.longitude);
      if (places.isEmpty || !mounted) return;
      final p = places.first;
      setState(() {
        _houseCtrl.text = [p.subThoroughfare, p.thoroughfare]
            .where((v) => (v ?? "").trim().isNotEmpty)
            .join(" ");
        _areaCtrl.text = (p.subLocality ?? "").trim();
        _thanaCtrl.text = (p.locality ?? "").trim();
        _zilaCtrl.text = (p.administrativeArea ?? "").trim();
        _postalCtrl.text = (p.postalCode ?? "").trim();
      });
    } catch (_) {
      Get.snackbar("Address", "Could not fetch details from map");
    } finally {
      if (mounted) setState(() => _fillingFromMap = false);
    }
  }

  Future<void> _goToResult(_SearchResult result) async {
    if (_controller == null) return;
    await _controller!.animateCamera(CameraUpdate.newLatLngZoom(result.latLng, 16));
    setState(() {
      _results = [];
      _currentCenter = result.latLng;
    });
    await _applyReverseToFields(result.latLng);
  }

  Widget _typeChip(String label) {
    final selected = _selectedType == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected ? AppColors.primary : Colors.grey.shade100,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  String _buildDetail() {
    final lines = <String>[];
    if (_houseCtrl.text.trim().isNotEmpty) lines.add("House/Road: ${_houseCtrl.text.trim()}");
    if (_areaCtrl.text.trim().isNotEmpty) lines.add("Area: ${_areaCtrl.text.trim()}");
    if (_thanaCtrl.text.trim().isNotEmpty) lines.add("Thana: ${_thanaCtrl.text.trim()}");
    if (_zilaCtrl.text.trim().isNotEmpty) lines.add("District: ${_zilaCtrl.text.trim()}");
    if (_postalCtrl.text.trim().isNotEmpty) lines.add("Postal: ${_postalCtrl.text.trim()}");
    return lines.join("\n");
  }

  Future<void> _save() async {
    if (!_mapReady) {
      Get.snackbar("Map", "Wait for map to load");
      return;
    }
    final detail = _buildDetail();
    if (detail.isEmpty) {
      Get.snackbar("Address", "Fill at least one field or tap Fill from map pin");
      return;
    }

    final saved = await _addressController.createAddress(
      label: _selectedType,
      fullAddress: detail.replaceAll("\n", ", "),
      note: _noteCtrl.text.trim(),
      latitude: _currentCenter.latitude,
      longitude: _currentCenter.longitude,
      isDefault: _addressController.addresses.isEmpty,
    );

    if (saved == null) {
      Get.snackbar("Error", "Failed to save address");
      return;
    }

    final resultText = _noteCtrl.text.trim().isEmpty
        ? "[$_selectedType] $detail"
        : "[$_selectedType] $detail\nNote: ${_noteCtrl.text.trim()}";
    Get.back(result: resultText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF2C2C2C)),
        ),
        centerTitle: true,
        title: const Text(
          "Delivery address",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(target: _dhaka, zoom: 13),
                  myLocationButtonEnabled: false,
                  onMapCreated: (controller) {
                    _controller = controller;
                    if (mounted) setState(() => _mapReady = true);
                  },
                  onCameraMove: (position) {
                    _currentCenter = position.target;
                    _isCameraMoving = true;
                  },
                  onCameraIdle: () async {
                    if (!_isCameraMoving) return;
                    _isCameraMoving = false;
                    await _applyReverseToFields(_currentCenter);
                  },
                ),
                IgnorePointer(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 36),
                      child: Icon(
                        Icons.location_on,
                        size: 48,
                        color: Colors.red.shade600,
                        shadows: const [Shadow(blurRadius: 4, color: Colors.black26)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  top: 10,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _runSearch(),
                            decoration: const InputDecoration(
                              hintText: "Search area, road, city...",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              isDense: true,
                            ),
                          ),
                        ),
                        if (_searching)
                          const Padding(
                            padding: EdgeInsets.all(10),
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else
                          IconButton(
                            onPressed: _runSearch,
                            icon: const Icon(Icons.search, color: Color(0xFF22C55E)),
                          ),
                      ],
                    ),
                  ),
                ),
                if (_results.isNotEmpty)
                  Positioned(
                    left: 10,
                    right: 10,
                    top: 64,
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 140),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _results.length,
                          separatorBuilder: (context, index) =>
                              Divider(height: 1, color: Colors.grey.shade200),
                          itemBuilder: (context, i) {
                            final result = _results[i];
                            return ListTile(
                              dense: true,
                              title: Text(
                                result.label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12.5),
                              ),
                              onTap: () => _goToResult(result),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FloatingActionButton.small(
                    heroTag: "fill_pin",
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF22C55E),
                    onPressed: _fillingFromMap ? null : () => _applyReverseToFields(_currentCenter),
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Address details (editable)",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      if (_fillingFromMap)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextButton.icon(
                          onPressed: _fillingFromMap || !_mapReady
                              ? null
                              : () => _applyReverseToFields(_currentCenter),
                          icon: const Icon(Icons.sync, color: Color(0xFF22C55E), size: 20),
                          label: const Text(
                            "Fill from map pin",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF22C55E),
                            ),
                          ),
                        ),
                        TextField(
                          controller: _houseCtrl,
                          decoration: _dec("House / Road no.", hint: "e.g. House 20, Road 19"),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 10),
                        TextField(controller: _areaCtrl, decoration: _dec("Area", hint: "Block, sector")),
                        const SizedBox(height: 10),
                        TextField(controller: _thanaCtrl, decoration: _dec("Thana")),
                        const SizedBox(height: 10),
                        TextField(controller: _zilaCtrl, decoration: _dec("District")),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _postalCtrl,
                          decoration: _dec("Postal code"),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _noteCtrl,
                          decoration: _dec("Delivery Instructions (optional)"),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _typeChip("Home"),
                            const SizedBox(width: 10),
                            _typeChip("Office"),
                            const SizedBox(width: 10),
                            _typeChip("Other"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Material(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: !_mapReady ? null : _save,
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              _mapReady ? "Save address" : "Loading map...",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: _mapReady ? 1 : 0.85),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResult {
  final String label;
  final LatLng latLng;

  const _SearchResult({
    required this.label,
    required this.latLng,
  });
}
