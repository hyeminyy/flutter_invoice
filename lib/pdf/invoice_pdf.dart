import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/document.dart';
import '../utils/calculator.dart';

class InvoicePdf {
  /// PDF 생성 (Uint8List 반환)
  static Future<Uint8List> generate(Document document) async {
    final pdf = pw.Document();

    final subTotal = Calculator.subTotal(document.items);
    final vat = Calculator.vatAmount(document.items, document.vatRate);
    final total = Calculator.totalAmount(document.items, document.vatRate);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              /// ===== 헤더 =====
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    document.type == DocumentType.invoice
                        ? 'INVOICE'
                        : 'QUOTATION',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('문서번호: ${document.documentNo}'),
                      pw.Text(
                        '발행일: ${_formatDate(document.issueDate)}',
                      ),
                      if (document.type == DocumentType.invoice &&
                          document.dueDate != null)
                        pw.Text(
                          '지급기한: ${_formatDate(document.dueDate!)}',
                        ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 32),

              /// ===== 판매자 / 고객 =====
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: _infoBlock(
                      title: '판매자',
                      lines: [
                        document.sellerName,
                        document.sellerContact,
                        document.sellerAddress,
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 40),
                  pw.Expanded(
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

              pw.SizedBox(height: 32),

              /// ===== 품목 테이블 =====
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  _tableHeader(),
                  ...document.items.map(
                    (item) => pw.TableRow(
                      children: [
                        _cell(item.name),
                        _cell(
                          Calculator.formatCurrency(item.unitPrice),
                          align: pw.TextAlign.right,
                        ),
                        _cell(
                          item.quantity.toString(),
                          align: pw.TextAlign.center,
                        ),
                        _cell(
                          Calculator.formatCurrency(item.total),
                          align: pw.TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 24),

              /// ===== 금액 요약 =====
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _amountRow('소계', subTotal),
                    _amountRow(
                      '부가세 (${Calculator.formatVat(document.vatRate)})',
                      vat,
                    ),
                    pw.Divider(),
                    _amountRow('총액', total, bold: true),
                  ],
                ),
              ),

              pw.SizedBox(height: 32),

              /// ===== 비고 =====
              if (document.note.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '비고',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(document.note),
                  ],
                ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// ===== PDF 다운로드 =====
  static Future<void> download(Document document) async {
    final data = await generate(document);
    await Printing.sharePdf(
      bytes: data,
      filename: '${document.documentNo}.pdf',
    );
  }

  /// ===== 브라우저 프린트 =====
  static Future<void> print(Document document) async {
    final data = await generate(document);
    await Printing.layoutPdf(onLayout: (_) => data);
  }

  /// ===== Helper =====

  static pw.Widget _infoBlock({
    required String title,
    required List<String> lines,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 16,
          ),
        ),
        pw.SizedBox(height: 8),
        ...lines.where((e) => e.isNotEmpty).map((e) => pw.Text(e)),
      ],
    );
  }

  static pw.TableRow _tableHeader() {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
      children: [
        _headerCell('품목명'),
        _headerCell('단가'),
        _headerCell('수량'),
        _headerCell('금액'),
      ],
    );
  }

  static pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _cell(String text,
      {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, textAlign: align),
    );
  }

  static pw.Widget _amountRow(String label, double value,
      {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(label),
          pw.SizedBox(width: 24),
          pw.Text(
            '₩ ${Calculator.formatCurrency(value)}',
            style: pw.TextStyle(
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
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
