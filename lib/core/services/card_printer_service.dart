import 'dart:typed_data';
import 'package:intl/intl.dart' as intl;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/beneficiary/models/aid_card_model.dart';

class CardPrinterService {
  static Future<void> printAidCard({
    required AidCardModel card,
  }) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => generateCardPdf(card: card),
      name: 'Qout_Aid_Card_${card.cardId}.pdf',
    );
  }

  static Future<Uint8List> generateCardPdf({
    required AidCardModel card,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.cairoBold();
    final fontRegular = await PdfGoogleFonts.cairoRegular();
    final dateFormatter = intl.DateFormat('yyyy/MM/dd');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Container(
              width: 380,
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
                border: pw.Border.all(color: PdfColors.green900, width: 3),
              ),
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // 1. Header: Brand Title & Official Badge
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'مؤسسة الفجر الخيرية (ALFAJR)',
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 18,
                              color: PdfColors.green900,
                            ),
                          ),
                          pw.Text(
                            'بطاقة الدعم الغذائي والإغاثي الذكي المعتمدة',
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 10,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.green50,
                          borderRadius:
                              const pw.BorderRadius.all(pw.Radius.circular(8)),
                          border: pw.Border.all(color: PdfColors.green800),
                        ),
                        child: pw.Text(
                          'كارت رسمي معتمد',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 10,
                            color: PdfColors.green900,
                          ),
                        ),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 16),
                  pw.Divider(color: PdfColors.grey300, thickness: 1),
                  pw.SizedBox(height: 14),

                  // 2. High-Contrast Printable QR Code
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(16)),
                      border: pw.Border.all(color: PdfColors.black, width: 2),
                    ),
                    child: pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: card.cardId,
                      width: 170,
                      height: 170,
                      color: PdfColors.black,
                    ),
                  ),

                  pw.SizedBox(height: 12),

                  // 3. Card ID & Beneficiary Name
                  pw.Text(
                    card.cardId,
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 16,
                      color: PdfColors.black,
                      letterSpacing: 2,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    card.beneficiaryName,
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 15,
                      color: PdfColors.green900,
                    ),
                  ),

                  pw.SizedBox(height: 14),
                  pw.Divider(color: PdfColors.grey300, thickness: 1),
                  pw.SizedBox(height: 10),

                  // 4. Beneficiary Details Table
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPdfInfoItem(
                        font: font,
                        fontRegular: fontRegular,
                        label: 'رقم البطاقة / الجواز',
                        value: card.nationalId.replaceAll(RegExp(r'\s+'), ''),
                      ),
                      _buildPdfInfoItem(
                        font: font,
                        fontRegular: fontRegular,
                        label: 'أفراد الأسرة',
                        value: '${card.familyCount} أفراد',
                      ),
                      _buildPdfInfoItem(
                        font: font,
                        fontRegular: fontRegular,
                        label: 'تاريخ الانتهاء',
                        value: dateFormatter.format(card.expiresAt),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 12),

                  // 5. Accessible Visual Guidelines for Elderly & Illiterate
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius:
                          pw.BorderRadius.all(pw.Radius.circular(10)),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'إرشادات استخدام البطاقة الورقية عند منفذ الصرف:',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 10,
                            color: PdfColors.grey800,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '1. أظهر هذه الورقة أو رمز الـ QR مباشرة للكاشير في التموينات أو الصيدلية المعتمدة.\n2. يتم مسح الرمز وتأكيد استحقاقك للمواد التموينية والسلال الغذائية فوراً بدون هاتف.\n3. في حال الفقدان، اتصل فوراً بالرقم الموحد المجاني: 8001234567',
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: 9,
                            color: PdfColors.grey700,
                            lineSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfInfoItem({
    required pw.Font font,
    required pw.Font fontRegular,
    required String label,
    required String value,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: fontRegular,
            fontSize: 9,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: font,
            fontSize: 11,
            color: PdfColors.black,
          ),
        ),
      ],
    );
  }
}
