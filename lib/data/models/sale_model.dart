class SaleModel {
  final String brand;
  final String region;
  final double salesAmount;
  final bool isActiveStore;
  final DateTime date;

  SaleModel({
    required this.brand,
    required this.region,
    required this.salesAmount,
    required this.isActiveStore,
    required this.date,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      brand: json['brand']?.toString().trim() ?? '',
      region: json['region']?.toString().trim() ?? '',
      salesAmount:
      (json['salesAmount'] as num?)?.toDouble() ?? 0,
      isActiveStore: json['isActiveStore'] == true,
      date: DateTime.tryParse(json['date'] ?? '') ??
          DateTime.now(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'region': region,
      'salesAmount': salesAmount,
      'isActiveStore': isActiveStore,
      'date': date.toIso8601String(),
    };
  }
}
