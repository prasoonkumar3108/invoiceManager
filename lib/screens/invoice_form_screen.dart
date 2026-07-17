import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:invoicemanager/models/invoice.dart';
import 'package:invoicemanager/models/client.dart';
import 'package:invoicemanager/models/product.dart';
import 'package:invoicemanager/models/line_item.dart';
import 'package:invoicemanager/providers/invoice_provider.dart';

class InvoiceFormScreen extends StatefulWidget {
  const InvoiceFormScreen({super.key});

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  Client? _selectedClient;
  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 14));

  final List<LineItem> _lineItems = [];

  final _taxController = TextEditingController(text: '0.0');
  final _discountController = TextEditingController(text: '0.0');

  // Controllers for adding an item
  Product? _selectedProduct;
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  final _customItemNameController = TextEditingController();

  bool _isCustomItem = false;

  @override
  void dispose() {
    _taxController.dispose();
    _discountController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _customItemNameController.dispose();
    super.dispose();
  }

  double get _subtotal => _lineItems.fold(0.0, (sum, item) => sum + item.total);

  double get _total {
    double total = _subtotal;
    final tax = double.tryParse(_taxController.text) ?? 0.0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;

    total += total * (tax / 100);
    total -= total * (discount / 100);
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InvoiceProvider>(context);
    final formatCurrency = NumberFormat.simpleCurrency(decimalDigits: 2);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 900;

    final clientCard = Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Select Client',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade900,
                  ),
            ),
            const SizedBox(height: 12),
            if (provider.clients.isEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No clients registered. Create a client first:',
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Go to Clients tab'),
                  )
                ],
              )
            else
              DropdownButtonFormField<Client>(
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Choose Client',
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: _selectedClient,
                selectedItemBuilder: (BuildContext context) {
                  return provider.clients.map<Widget>((client) {
                    return Text(
                      client.name,
                      overflow: TextOverflow.ellipsis,
                    );
                  }).toList();
                },
                items: provider.clients.map((client) {
                  return DropdownMenuItem<Client>(
                    value: client,
                    child: Text('${client.name} (${client.email})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClient = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a client';
                  }
                  return null;
                },
              ),
          ],
        ),
      ),
    );

    final datesCard = Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2. Invoice Dates',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade900,
                  ),
            ),
            const SizedBox(height: 12),
            // Flex row/column depending on wide view
            isWide
                ? Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('Issue Date'),
                          subtitle: Text(DateFormat.yMMMd().format(_issueDate)),
                          trailing: const Icon(Icons.calendar_today),
                          tileColor: Colors.grey.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _issueDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setState(() {
                                _issueDate = picked;
                                if (_dueDate.isBefore(_issueDate)) {
                                  _dueDate = _issueDate.add(const Duration(days: 14));
                                }
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ListTile(
                          title: const Text('Due Date'),
                          subtitle: Text(DateFormat.yMMMd().format(_dueDate)),
                          trailing: const Icon(Icons.calendar_today),
                          tileColor: Colors.grey.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _dueDate,
                              firstDate: _issueDate,
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setState(() {
                                _dueDate = picked;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      ListTile(
                        title: const Text('Issue Date'),
                        subtitle: Text(DateFormat.yMMMd().format(_issueDate)),
                        trailing: const Icon(Icons.calendar_today),
                        tileColor: Colors.grey.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _issueDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() {
                              _issueDate = picked;
                              if (_dueDate.isBefore(_issueDate)) {
                                _dueDate = _issueDate.add(const Duration(days: 14));
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        title: const Text('Due Date'),
                        subtitle: Text(DateFormat.yMMMd().format(_dueDate)),
                        trailing: const Icon(Icons.calendar_today),
                        tileColor: Colors.grey.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dueDate,
                            firstDate: _issueDate,
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() {
                              _dueDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );

    final lineItemsCard = Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '3. Line Items',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade900,
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddItemDialog(context, provider),
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_lineItems.isEmpty)
              Container(
                height: 150,
                alignment: Alignment.center,
                child: const Text(
                  'No items added to invoice yet.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _lineItems.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final item = _lineItems[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Qty: ${item.quantity}  ×  ${formatCurrency.format(item.unitPrice)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatCurrency.format(item.total),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _lineItems.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );

    final summaryCard = Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Invoice Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade900,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal', style: TextStyle(fontSize: 16)),
                Text(formatCurrency.format(_subtotal), style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            // Tax Input
            Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text('Tax Rate (%)', style: TextStyle(fontSize: 16)),
                ),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _taxController,
                    decoration: const InputDecoration(
                      suffixText: '%',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (val) {
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Discount Input
            Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text('Discount Rate (%)', style: TextStyle(fontSize: 16)),
                ),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _discountController,
                    decoration: const InputDecoration(
                      suffixText: '%',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (val) {
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            const Divider(height: 32, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL DUE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  formatCurrency.format(_total),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.indigo.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _lineItems.isEmpty || _selectedClient == null ? null : _saveInvoice,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Save & Issue Invoice', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Invoice'),
        backgroundColor: Colors.indigo.shade900,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Panel - Invoice Details & Line Items
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            clientCard,
                            const SizedBox(height: 16),
                            datesCard,
                            const SizedBox(height: 16),
                            lineItemsCard,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Right Panel - Invoice Summary & Calculations
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        child: summaryCard,
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      clientCard,
                      const SizedBox(height: 16),
                      datesCard,
                      const SizedBox(height: 16),
                      lineItemsCard,
                      const SizedBox(height: 16),
                      summaryCard,
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, InvoiceProvider provider) {
    _selectedProduct = null;
    _isCustomItem = false;
    _quantityController.text = '1';
    _priceController.text = '';
    _customItemNameController.text = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Line Item'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('From Products'),
                          selected: !_isCustomItem,
                          onSelected: (val) {
                            setDialogState(() {
                              _isCustomItem = !val;
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Custom Item'),
                          selected: _isCustomItem,
                          onSelected: (val) {
                            setDialogState(() {
                              _isCustomItem = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!_isCustomItem) ...[
                      if (provider.products.isEmpty)
                        const Text(
                          'No products registered. Use "Custom Item" or add products to inventory first.',
                          style: TextStyle(color: Colors.red),
                        )
                      else
                        DropdownButtonFormField<Product>(
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Choose Product', border: OutlineInputBorder()),
                          value: _selectedProduct,
                          selectedItemBuilder: (BuildContext context) {
                            return provider.products.map<Widget>((prod) {
                              return Text(
                                prod.name,
                                overflow: TextOverflow.ellipsis,
                              );
                            }).toList();
                          },
                          items: provider.products.map((prod) {
                            return DropdownMenuItem<Product>(
                              value: prod,
                              child: Text('${prod.name} (\$${prod.unitPrice.toStringAsFixed(2)})'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setDialogState(() {
                              _selectedProduct = val;
                              _priceController.text = val?.unitPrice.toString() ?? '';
                            });
                          },
                        ),
                    ] else ...[
                      TextFormField(
                        controller: _customItemNameController,
                        decoration: const InputDecoration(labelText: 'Item Name *', border: OutlineInputBorder()),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(labelText: 'Quantity *', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Unit Price *',
                              prefixText: '\$ ',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            enabled: _isCustomItem || _selectedProduct != null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final qty = int.tryParse(_quantityController.text) ?? 1;
                    final price = double.tryParse(_priceController.text) ?? 0.0;
                    String name = '';

                    if (!_isCustomItem && _selectedProduct != null) {
                      name = _selectedProduct!.name;
                    } else if (_isCustomItem && _customItemNameController.text.trim().isNotEmpty) {
                      name = _customItemNameController.text.trim();
                    }

                    if (name.isNotEmpty && qty > 0 && price >= 0) {
                      setState(() {
                        _lineItems.add(
                          LineItem(
                            productName: name,
                            quantity: qty,
                            unitPrice: price,
                          ),
                        );
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add to Invoice'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveInvoice() async {
    if (_formKey.currentState!.validate() && _selectedClient != null && _lineItems.isNotEmpty) {
      final provider = Provider.of<InvoiceProvider>(context, listen: false);
      final tax = double.tryParse(_taxController.text) ?? 0.0;
      final discount = double.tryParse(_discountController.text) ?? 0.0;

      final invoice = Invoice(
        client: _selectedClient!,
        lineItems: _lineItems,
        issueDate: _issueDate,
        dueDate: _dueDate,
        tax: tax,
        discount: discount,
      );

      await provider.addInvoice(invoice);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice saved successfully!')),
        );
      }
    }
  }
}
