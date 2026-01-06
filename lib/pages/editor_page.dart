import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/document.dart';
import '../utils/calculator.dart';


class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  // 문서 기본 상태
  late Document document;

  // 입력 컨트롤러
  final sellerNameCtrl = TextEditingController();
  final clientNameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    document = Document(
      type: DocumentType.invoice,
      documentNo: 'INV-001',
      issueDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 7)),
      sellerName: '',
      sellerContact: '',
      sellerAddress: '',
      clientName: '',
      clientContact: '',
      clientAddress: '',
      items: [],
      vatRate: 0.1,
    );
  }

  void addItem() {
    setState(() {
      document.items.add(
        Item(name: '', unitPrice: 0, quantity: 1),
      );
    });
  }

  void removeItem(int index) {
    setState(() {
      document.items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final subTotal = Calculator.subTotal(document.items);
    final vat = Calculator.vatAmount(document.items, document.vatRate);
    final total = Calculator.totalAmount(document.items, document.vatRate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Editor'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/preview', arguments: document);
            },
            child: const Text('미리보기'),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 판매자 / 고객 정보
                Row(
                  children: [
                    Expanded(
                      child: _section(
                        title: '판매자 정보',
                        child: TextField(
                          controller: sellerNameCtrl,
                          decoration: const InputDecoration(labelText: '회사명'),
                          onChanged: (v) => document.sellerName = v,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _section(
                        title: '고객 정보',
                        child: TextField(
                          controller: clientNameCtrl,
                          decoration: const InputDecoration(labelText: '고객명'),
                          onChanged: (v) => document.clientName = v,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                /// 품목 테이블
                _section(
                  title: '품목',
                  child: Column(
                    children: [
                      _itemHeader(),
                      const Divider(),

                      ...document.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;

                        return Row(
                          children: [
                            _cell(
                              flex: 3,
                              child: TextField(
                                decoration:
                                    const InputDecoration(hintText: '품목명'),
                                onChanged: (v) => item.name = v,
                              ),
                            ),
                            _cell(
                              child: TextField(
                                decoration:
                                    const InputDecoration(hintText: '단가'),
                                keyboardType: TextInputType.number,
                                onChanged: (v) =>
                                    item.unitPrice = double.tryParse(v) ?? 0,
                              ),
                            ),
                            _cell(
                              child: TextField(
                                decoration:
                                    const InputDecoration(hintText: '수량'),
                                keyboardType: TextInputType.number,
                                onChanged: (v) =>
                                    item.quantity = int.tryParse(v) ?? 1,
                              ),
                            ),
                            _cell(
                              child: Text(
                                Calculator.formatCurrency(item.total),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => removeItem(index),
                            ),
                          ],
                        );
                      }),

                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: addItem,
                          icon: const Icon(Icons.add),
                          label: const Text('품목 추가'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                /// 금액 요약
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _summaryRow('소계', subTotal),
                      _summaryRow(
                        '부가세 (${Calculator.formatVat(document.vatRate)})',
                        vat,
                      ),
                      const Divider(),
                      _summaryRow('총액', total, isBold: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 공통 UI helpers
  Widget _section({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _itemHeader() {
    return Row(
      children: const [
        _HeaderCell('품목명', flex: 3),
        _HeaderCell('단가'),
        _HeaderCell('수량'),
        _HeaderCell('금액'),
        SizedBox(width: 48),
      ],
    );
  }

  Widget _cell({required Widget child, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: child,
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 16),
          Text(
            '₩ ${Calculator.formatCurrency(value)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  const _HeaderCell(this.text, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
