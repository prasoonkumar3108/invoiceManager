import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import 'package:invoicemanager/models/invoice.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final Invoice invoice;

  const InvoicePreviewScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Preview & Export'),
        backgroundColor: Colors.indigo.shade900,
        foregroundColor: Colors.white,
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format),
        maxPageWidth: 750,
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();
    final formatCurrency = NumberFormat.simpleCurrency(decimalDigits: 2);
    final shortId = invoice.id.length > 8 ? invoice.id.substring(0, 8) : invoice.id;

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header (Company Name & INVOICE title)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'INVOICE MANAGER',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.indigo900,
                          ),
                        ),
                        pw.Text('Offline billing simplified.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'INVOICE',
                          style: pw.TextStyle(
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.indigo900,
                          ),
                        ),
                        pw.Text('Invoice ID: #$shortId', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Divider(thickness: 1, color: PdfColors.indigo900),
                pw.SizedBox(height: 24),

                // Client Details & Dates
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BILL TO:',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(invoice.client.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                        pw.Text(invoice.client.email),
                        pw.Text(invoice.client.phone),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          width: 250,
                          child: pw.Text(invoice.client.address, maxLines: 3, style: const pw.TextStyle(fontSize: 10)),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Row(
                          children: [
                            pw.Text('Date Issued: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text(DateFormat.yMMMd().format(invoice.issueDate)),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          children: [
                            pw.Text('Due Date: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text(DateFormat.yMMMd().format(invoice.dueDate)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 32),

                // Table Header
                pw.Table(
                  border: const pw.TableBorder(
                    bottom: pw.BorderSide(color: PdfColors.grey400, width: 1),
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(1.5),
                    3: const pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.indigo900),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Item Description', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Qty', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Unit Price', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Total', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                        ),
                      ],
                    ),
                    ...invoice.lineItems.map((item) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(item.productName),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(item.quantity.toString(), textAlign: pw.TextAlign.right),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(formatCurrency.format(item.unitPrice), textAlign: pw.TextAlign.right),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(formatCurrency.format(item.total), style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                pw.SizedBox(height: 32),

                // Calculations / Total Summary
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 250,
                      child: pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Subtotal:'),
                              pw.Text(formatCurrency.format(invoice.subtotal)),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          if (invoice.tax != null && invoice.tax! > 0) ...[
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('Tax (${invoice.tax}%):'),
                                pw.Text(formatCurrency.format(invoice.subtotal * (invoice.tax! / 100))),
                              ],
                            ),
                            pw.SizedBox(height: 4),
                          ],
                          if (invoice.discount != null && invoice.discount! > 0) ...[
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('Discount (${invoice.discount}%):'),
                                pw.Text('-${formatCurrency.format(invoice.subtotal * (invoice.discount! / 100))}'),
                              ],
                            ),
                            pw.SizedBox(height: 4),
                          ],
                          pw.Divider(thickness: 1, color: PdfColors.indigo900),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Total Due:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                              pw.Text(
                                formatCurrency.format(invoice.total),
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16, color: PdfColors.indigo900),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),

                // Footer
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Column(
                    children: [
                      pw.Text('Thank you for your business!', style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text('Invoice generated offline via Flutter Invoice Manager.', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    return pdf.save();
  }
}
