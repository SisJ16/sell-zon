class PaymentMethodField {
  final String key;
  final String label;
  final String type;
  final bool required;

  PaymentMethodField({
    required this.key,
    required this.label,
    required this.type,
    required this.required,
  });

  factory PaymentMethodField.fromJson(Map<String, dynamic> json) {
    return PaymentMethodField(
      key: (json["key"] ?? "").toString(),
      label: (json["label"] ?? "").toString(),
      type: (json["type"] ?? "text").toString(),
      required: (json["required"] as bool?) ?? false,
    );
  }
}

class PaymentMethodModel {
  final String id;
  final String name;
  final String description;
  final bool requiresAction;
  final List<PaymentMethodField> fields;

  PaymentMethodModel({
    required this.id,
    required this.name,
    required this.description,
    required this.requiresAction,
    required this.fields,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    final list = (json["fields"] as List<dynamic>? ?? [])
        .map((e) => PaymentMethodField.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return PaymentMethodModel(
      id: (json["id"] ?? "").toString(),
      name: (json["name"] ?? "").toString(),
      description: (json["description"] ?? "").toString(),
      requiresAction: (json["requiresAction"] as bool?) ?? false,
      fields: list,
    );
  }
}
