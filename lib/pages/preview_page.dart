import 'package:flutter/material.dart';
import '../models/document.dart';
import '../utils/calculator.dart';


class PreviewPage extends StatelessWidget {
  const PreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    // EditorPage에서 전달한 Document 받기
    final document =
        ModalRoute.of(context)!.settings.arguments as Document;

    final subTotal = Calculator.subTotal(document.items);
    final vat = Calculator.vatAmount(document.items, document.vatRate);
    final total = Calculator.totalAmount(document.items, document.vatRate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('문서 미리보기'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('수정하기'),
          ),
        ],
      ),

      backgroundColor: const Color(0xFFEFEFEF),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Container(
            width: 794, // A4 width (px 기준)
            padding: const EdgeInsets.all(40),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// ===== 헤더 =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      document.type == DocumentType.invoice
                          ? 'INVOICE'
                          : 'QUOTATION',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('문서번호: ${document.documentNo}'),
                        Text(
                            '발행일: ${_formatDate(document.issueDate)}'),
                        if (document.type == DocumentType.invoice &&
                            document.dueDate != null)
                          Text(
                              '지급기한: ${_formatDate(document.dueDate!)}'),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                /// ===== 판매자 / 고객 =====
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _infoBlock(
                        title: '판매자',
                        lines: [
                          document.sellerName,
                          document.sellerContact,
                          document.sellerAddress,
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: _infoBlock(
                        title: '고객',
                        lines: [
                          document.clientName,
                          document.clientContact,
                          document.clientAddress,
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                /// ===== 품목 테이블 =====
                Table(
                  border: TableBorder.all(color: Colors.grey.shade400),
                  columnWidths: const {
                    0: FlexColumnWidth(4),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(2),
                  },
                  children: [
                    _tableHeader(),
                    ...document.items.map(
                      (item) => TableRow(
                        children: [
                          _cell(item.name),
                          _cell(
                            Calculator.formatCurrency(item.unitPrice),
                            align: TextAlign.right,
                          ),
                          _cell(
                            item.quantity.toString(),
                            align: TextAlign.center,
                          ),
                          _cell(
                            Calculator.formatCurrency(item.total),
                            align: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                /// ===== 금액 요약 =====
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _amountRow('소계', subTotal),
                      _amountRow(
                        '부가세 (${Calculator.formatVat(document.vatRate)})',
                        vat,
                      ),
                      const Divider(),
                      _amountRow('총액', total, bold: true),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                /// ===== 비고 =====
                if (document.note.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '비고',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(document.note),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ===== Helper Widgets =====

  static Widget _infoBlock({
    required String title,
    required List<String> lines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ...lines.where((e) => e.isNotEmpty).map((e) => Text(e)),
      ],
    );
  }

  static TableRow _tableHeader() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade200),
      children: const [
        _HeaderCell('품목명'),
        _HeaderCell('단가'),
        _HeaderCell('수량'),
        _HeaderCell('금액'),
      ],
    );
  }

  static Widget _cell(String text,
      {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(text, textAlign: align),
    );
  }

  static Widget _amountRow(String label, double value,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 24),
          Text(
            '₩ ${Calculator.formatCurrency(value)}',
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
