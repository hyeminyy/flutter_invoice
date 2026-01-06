import '../models/item.dart';

class Calculator {
  /// 소계 (품목 합계)
  static double subTotal(List<Item> items) {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  /// 부가세 금액
  /// vatRate 예: 0.1 (10%)
  static double vatAmount(List<Item> items, double vatRate) {
    return subTotal(items) * vatRate;
  }

  /// 총 금액 (소계 + 부가세)
  static double totalAmount(List<Item> items, double vatRate) {
    return subTotal(items) + vatAmount(items, vatRate);
  }

  /// 금액 포맷 (₩ 1,234,567)
  static String formatCurrency(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  /// 퍼센트 문자열 (0.1 → 10%)
  static String formatVat(double vatRate) {
    return '${(vatRate * 100).toInt()}%';
  }
}
