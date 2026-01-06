import 'item.dart';

enum DocumentType {
  quotation, // 견적서
  invoice,   // 인보이스
}

class Document {
  // 문서 기본 정보
  final DocumentType type;
  final String documentNo;
  final DateTime issueDate;
  final DateTime? dueDate; // 인보이스만 사용

  // 판매자 정보
  String sellerName;
  String sellerContact;
  String sellerAddress;

  // 고객 정보
  String clientName;
  String clientContact;
  String clientAddress;

  // 품목
  List<Item> items;

  // 세금
  double vatRate; // 예: 0.1 (10%)

  // 비고
  String note;

  Document({
    required this.type,
    required this.documentNo,
    required this.issueDate,
    this.dueDate,
    required this.sellerName,
    required this.sellerContact,
    required this.sellerAddress,
    required this.clientName,
    required this.clientContact,
    required this.clientAddress,
    required this.items,
    this.vatRate = 0.1,
    this.note = '',
  });

  /// 소계
  double get subTotal {
    return items.fold(0, (sum, item) => sum + item.total);
  }

  /// 부가세
  double get vatAmount {
    return subTotal * vatRate;
  }

  /// 총 금액
  double get totalAmount {
    return subTotal + vatAmount;
  }

  /// JSON 변환
  Map<String, dynamic> toJson() => {
        'type': type.name,
        'documentNo': documentNo,
        'issueDate': issueDate.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'sellerName': sellerName,
        'sellerContact': sellerContact,
        'sellerAddress': sellerAddress,
        'clientName': clientName,
        'clientContact': clientContact,
        'clientAddress': clientAddress,
        'vatRate': vatRate,
        'note': note,
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      type: DocumentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DocumentType.quotation,
      ),
      documentNo: json['documentNo'] ?? '',
      issueDate: DateTime.parse(json['issueDate']),
      dueDate:
          json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      sellerName: json['sellerName'] ?? '',
      sellerContact: json['sellerContact'] ?? '',
      sellerAddress: json['sellerAddress'] ?? '',
      clientName: json['clientName'] ?? '',
      clientContact: json['clientContact'] ?? '',
      clientAddress: json['clientAddress'] ?? '',
      vatRate: (json['vatRate'] ?? 0.1).toDouble(),
      note: json['note'] ?? '',
      items: (json['items'] as List<dynamic>)
          .map((e) => Item.fromJson(e))
          .toList(),
    );
  }
}
