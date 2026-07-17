import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:invoicemanager/providers/invoice_provider.dart';
import 'package:invoicemanager/screens/clients_view.dart';
import 'package:invoicemanager/screens/products_view.dart';
import 'package:invoicemanager/screens/invoices_view.dart';
import 'package:invoicemanager/screens/invoice_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Financial Overview',
    'Manage Invoices',
    'Manage Clients',
    'Manage Products',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InvoiceProvider>(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    // Dynamic views list
    final List<Widget> _views = [
      _buildOverview(context, provider, screenWidth),
      const InvoicesView(),
      const ClientsView(),
      const ProductsView(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.grey.shade50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar / Header Container
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: isMobile ? 12 : 20,
                ),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Expanded wrapper to enforce wrap/truncation rather than pushing items off-screen
                    Expanded(
                      child: Text(
                        _titles[_selectedIndex],
                        style: (isMobile
                                ? Theme.of(context).textTheme.titleLarge
                                : Theme.of(context).textTheme.headlineMedium)
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade900,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_selectedIndex == 0)
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InvoiceFormScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(
                          isMobile ? 'Create' : 'Create Invoice',
                          style: TextStyle(fontSize: isMobile ? 12 : 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 20,
                            vertical: isMobile ? 8 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Current View Body
              Expanded(
                child: _views[_selectedIndex],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.indigo.shade900,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white60,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Invoices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(BuildContext context, InvoiceProvider provider, double screenWidth) {
    final formatCurrency = NumberFormat.simpleCurrency(decimalDigits: 2);
    final totalSalesVal = provider.totalSales;
    final invoicesCount = provider.invoices.length;
    final clientsCount = provider.clients.length;
    final productsCount = provider.products.length;

    // Build KPI widget using direct MediaQuery width checks instead of LayoutBuilder
    Widget kpiWidget;
    if (screenWidth > 950) {
      // Large desktop view: all 4 in a row
      kpiWidget = Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Total Revenue',
              value: formatCurrency.format(totalSalesVal),
              icon: Icons.attach_money,
              color: Colors.green.shade600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: 'Invoices Issued',
              value: invoicesCount.toString(),
              icon: Icons.receipt,
              color: Colors.indigo.shade600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: 'Total Clients',
              value: clientsCount.toString(),
              icon: Icons.people,
              color: Colors.purple.shade600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: 'Products Inventory',
              value: productsCount.toString(),
              icon: Icons.grid_view,
              color: Colors.amber.shade700,
            ),
          ),
        ],
      );
    } else if (screenWidth > 550) {
      // Medium view: 2x2 grid representation
      kpiWidget = Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total Revenue',
                  value: formatCurrency.format(totalSalesVal),
                  icon: Icons.attach_money,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Invoices Issued',
                  value: invoicesCount.toString(),
                  icon: Icons.receipt,
                  color: Colors.indigo.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total Clients',
                  value: clientsCount.toString(),
                  icon: Icons.people,
                  color: Colors.purple.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Products Inventory',
                  value: productsCount.toString(),
                  icon: Icons.grid_view,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Small / Mobile view: stacked column
      kpiWidget = Column(
        children: [
          _buildStatCard(
            title: 'Total Revenue',
            value: formatCurrency.format(totalSalesVal),
            icon: Icons.attach_money,
            color: Colors.green.shade600,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            title: 'Invoices Issued',
            value: invoicesCount.toString(),
            icon: Icons.receipt,
            color: Colors.indigo.shade600,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            title: 'Total Clients',
            value: clientsCount.toString(),
            icon: Icons.people,
            color: Colors.purple.shade600,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            title: 'Products Inventory',
            value: productsCount.toString(),
            icon: Icons.grid_view,
            color: Colors.amber.shade700,
          ),
        ],
      );
    }

    final recentInvoicesWidget = Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Invoices',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade900,
                  ),
            ),
            const SizedBox(height: 16),
            if (provider.invoices.isEmpty)
              Container(
                height: 150,
                alignment: Alignment.center,
                child: const Text(
                  'No invoices generated yet. Click "Create" to start.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.invoices.length > 5 ? 5 : provider.invoices.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final sortedInvoices = List<dynamic>.from(provider.invoices)
                    ..sort((a, b) => b.issueDate.compareTo(a.issueDate));
                  final invoice = sortedInvoices[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade50,
                      child: Icon(Icons.receipt_outlined, color: Colors.indigo.shade700),
                    ),
                    title: Text(
                      invoice.client.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Issued: ${DateFormat.yMMMd().format(invoice.issueDate)}',
                    ),
                    trailing: Text(
                      formatCurrency.format(invoice.total),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade900,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );

    final quickActionsWidget = Column(
      children: [
        _buildQuickActionCard(
          context,
          title: 'Add New Client',
          subtitle: 'Register a client and setup contact billing info.',
          icon: Icons.person_add,
          color: Colors.indigo,
          onTap: () {
            setState(() {
              _selectedIndex = 2; // Navigate to Clients view
            });
          },
        ),
        const SizedBox(height: 16),
        _buildQuickActionCard(
          context,
          title: 'Add New Product',
          subtitle: 'Add items and services to select on your invoices.',
          icon: Icons.add_shopping_cart,
          color: Colors.amber.shade800,
          onTap: () {
            setState(() {
              _selectedIndex = 3; // Navigate to Products view
            });
          },
        ),
      ],
    );

    Widget actionsAndInvoicesWidget;
    if (screenWidth > 850) {
      // Wide View: Side-by-side Row
      actionsAndInvoicesWidget = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: recentInvoicesWidget,
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: quickActionsWidget,
          ),
        ],
      );
    } else {
      // Narrow View: Vertical Stack
      actionsAndInvoicesWidget = Column(
        children: [
          quickActionsWidget,
          const SizedBox(height: 24),
          recentInvoicesWidget,
        ],
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          kpiWidget,
          const SizedBox(height: 32),
          actionsAndInvoicesWidget,
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                radius: 26,
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
