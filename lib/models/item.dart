class Item {
  String name;      // 품목명
  double unitPrice; // 단가
  int quantity;     // 수량

  Item({
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  /// 품목 금액 = 단가 × 수량
  double get total => unitPrice * quantity;

  /// JSON 변환 (나중에 저장/불러오기용)
  Map<String, dynamic> toJson() => {
        'name': name,
        'unitPrice': unitPrice,
        'quantity': quantity,
      };

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'] ?? '',
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
    );
  }
}
