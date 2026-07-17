import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:invoicemanager/providers/invoice_provider.dart';
import 'package:invoicemanager/screens/invoice_form_screen.dart';
import 'package:invoicemanager/screens/invoice_preview_screen.dart';
import 'package:invoicemanager/models/invoice.dart';

class InvoicesView extends StatefulWidget {
  const InvoicesView({super.key});

  @override
  State<InvoicesView> createState() => _InvoicesViewState();
}

class _InvoicesViewState extends State<InvoicesView> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InvoiceProvider>(context);
    final formatCurrency = NumberFormat.simpleCurrency(decimalDigits: 2);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth <= 700;

    final filteredInvoices = provider.invoices.where((invoice) {
      final query = _searchQuery.toLowerCase();
      return invoice.client.name.toLowerCase().contains(query) ||
          invoice.id.toLowerCase().contains(query);
    }).toList()
      ..sort((a, b) => b.issueDate.compareTo(a.issueDate)); // Sort by issue date descending

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search invoices by client name or invoice ID...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InvoiceFormScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('New Invoice'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.indigo.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Invoices Table/List
          Expanded(
            child: filteredInvoices.isEmpty
                ? Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Center(
                      child: Text(
                        _searchQuery.isEmpty ? 'No invoices created yet.' : 'No invoices match your search.',
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  )
                : isMobile
                    ? ListView.builder(
                        itemCount: filteredInvoices.length,
                        itemBuilder: (context, index) {
                          final invoice = filteredInvoices[index];
                          final shortId = invoice.id.length > 8 ? invoice.id.substring(0, 8) : invoice.id;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '#$shortId',
                                        style: const TextStyle(
                                          fontFamily: 'Courier',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.picture_as_pdf, color: Colors.indigo),
                                            tooltip: 'View & Print PDF',
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => InvoicePreviewScreen(invoice: invoice),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            tooltip: 'Delete Invoice',
                                            onPressed: () => _showDeleteConfirmation(context, provider, invoice),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 16),
                                  Text(
                                    invoice.client.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.indigo.shade900,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Issued: ${DateFormat.yMMMd().format(invoice.issueDate)}',
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Due: ${DateFormat.yMMMd().format(invoice.dueDate)}',
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        formatCurrency.format(invoice.total),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.indigo.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Invoice ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Client', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Issued Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Due Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: filteredInvoices.map((invoice) {
                                final shortId = invoice.id.length > 8 ? invoice.id.substring(0, 8) : invoice.id;
                                return DataRow(cells: [
                                  DataCell(
                                    Text(
                                      '#$shortId',
                                      style: const TextStyle(
                                        fontFamily: 'Courier',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(invoice.client.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                                  DataCell(Text(DateFormat.yMMMd().format(invoice.issueDate))),
                                  DataCell(Text(DateFormat.yMMMd().format(invoice.dueDate))),
                                  DataCell(Text(formatCurrency.format(invoice.total))),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.picture_as_pdf, color: Colors.indigo),
                                          tooltip: 'View & Print PDF',
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => InvoicePreviewScreen(invoice: invoice),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          tooltip: 'Delete Invoice',
                                          onPressed: () => _showDeleteConfirmation(context, provider, invoice),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, InvoiceProvider provider, Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Invoice'),
          content: Text('Are you sure you want to delete invoice for "${invoice.client.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await provider.deleteInvoice(invoice.id);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
