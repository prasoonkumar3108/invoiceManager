import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoicemanager/models/client.dart';
import 'package:invoicemanager/models/invoice.dart';
import 'package:invoicemanager/models/product.dart';

class InvoiceProvider extends ChangeNotifier {
  final Box<Client> _clientBox = Hive.box<Client>('clients');
  final Box<Product> _productBox = Hive.box<Product>('products');
  final Box<Invoice> _invoiceBox = Hive.box<Invoice>('invoices');

  List<Client> get clients => _clientBox.values.toList();
  List<Product> get products => _productBox.values.toList();
  List<Invoice> get invoices => _invoiceBox.values.toList();

  double get totalSales => invoices.fold(0.0, (sum, invoice) => sum + invoice.total);

  Future<void> addClient(Client client) async {
    await _clientBox.put(client.id, client);
    notifyListeners();
  }

  Future<void> updateClient(Client client) async {
    await _clientBox.put(client.id, client);
    notifyListeners();
  }

  Future<void> deleteClient(String id) async {
    await _clientBox.delete(id);
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await _productBox.put(product.id, product);
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    await _productBox.put(product.id, product);
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    await _productBox.delete(id);
    notifyListeners();
  }

  Future<void> addInvoice(Invoice invoice) async {
    await _invoiceBox.put(invoice.id, invoice);
    notifyListeners();
  }

  Future<void> deleteInvoice(String id) async {
    await _invoiceBox.delete(id);
    notifyListeners();
  }
}
