class AddressModel {
  final String id;
  final String label;
  final String fullAddress;
  final String note;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.note,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: (json["_id"] ?? json["id"] ?? "").toString(),
      label: (json["label"] ?? "Home").toString(),
      fullAddress: (json["fullAddress"] ?? "").toString(),
      note: (json["note"] ?? "").toString(),
      latitude: (json["latitude"] as num?)?.toDouble(),
      longitude: (json["longitude"] as num?)?.toDouble(),
      isDefault: (json["isDefault"] as bool?) ?? false,
    );
  }
}
