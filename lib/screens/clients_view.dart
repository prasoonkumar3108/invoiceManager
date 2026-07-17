import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:invoicemanager/models/client.dart';
import 'package:invoicemanager/providers/invoice_provider.dart';

class ClientsView extends StatefulWidget {
  const ClientsView({super.key});

  @override
  State<ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends State<ClientsView> {
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth <= 700;

    final filteredClients = provider.clients.where((client) {
      final query = _searchQuery.toLowerCase();
      return client.name.toLowerCase().contains(query) ||
          client.email.toLowerCase().contains(query) ||
          client.phone.contains(query) ||
          client.address.toLowerCase().contains(query);
    }).toList();

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
                    hintText: 'Search clients by name, email, phone or address...',
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
                onPressed: () => _showClientFormDialog(context, provider),
                icon: const Icon(Icons.add),
                label: const Text('Add Client'),
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
          // Clients Table/List
          Expanded(
            child: filteredClients.isEmpty
                ? Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Center(
                      child: Text(
                        _searchQuery.isEmpty ? 'No clients added yet.' : 'No clients match your search.',
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  )
                : isMobile
                    ? ListView.builder(
                        itemCount: filteredClients.length,
                        itemBuilder: (context, index) {
                          final client = filteredClients[index];
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
                                      Expanded(
                                        child: Text(
                                          client.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.indigo.shade900,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _showClientFormDialog(context, provider, client: client),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _showDeleteConfirmation(context, provider, client),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 16),
                                  Row(
                                    children: [
                                      const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(client.email, style: const TextStyle(fontSize: 14))),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(client.phone, style: const TextStyle(fontSize: 14)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          client.address,
                                          style: const TextStyle(fontSize: 13, color: Colors.black87),
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
                                DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Address', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: filteredClients.map((client) {
                                return DataRow(cells: [
                                  DataCell(Text(client.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                                  DataCell(Text(client.email)),
                                  DataCell(Text(client.phone)),
                                  DataCell(
                                    SizedBox(
                                      width: 250,
                                      child: Text(
                                        client.address,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () => _showClientFormDialog(context, provider, client: client),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _showDeleteConfirmation(context, provider, client),
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

  void _showClientFormDialog(BuildContext context, InvoiceProvider provider, {Client? client}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: client?.name ?? '');
    final phoneController = TextEditingController(text: client?.phone ?? '');
    final emailController = TextEditingController(text: client?.email ?? '');
    final addressController = TextEditingController(text: client?.address ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(client == null ? 'Add Client' : 'Edit Client'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name *', border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email *', border: OutlineInputBorder()),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone Number *', border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'Billing Address *', border: OutlineInputBorder()),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  if (client == null) {
                    final newClient = Client(
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      phone: phoneController.text.trim(),
                      address: addressController.text.trim(),
                    );
                    await provider.addClient(newClient);
                  } else {
                    client.name = nameController.text.trim();
                    client.email = emailController.text.trim();
                    client.phone = phoneController.text.trim();
                    client.address = addressController.text.trim();
                    await provider.updateClient(client);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(client == null ? 'Save' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, InvoiceProvider provider, Client client) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Client'),
          content: Text('Are you sure you want to delete client "${client.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await provider.deleteClient(client.id);
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
