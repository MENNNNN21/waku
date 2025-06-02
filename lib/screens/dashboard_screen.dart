import 'package:flutter/material.dart';
import 'stock_screen.dart';
import 'add_item_screen.dart';
import 'report_screen.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart'; // Import yang hilang
import '../models/item_model.dart'; // Import yang hilang
import 'login_screen.dart';
import 'low_stock_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = false;

  void _logout(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.inventory_2,
                    color: Colors.white,
                    size: 40,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Waku - Manajemen Stok',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Stok'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StockScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_box),
              title: const Text('Tambah Barang'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddItemScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Laporan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: _isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.logout, color: Colors.red),
              title: Text(
                _isLoading ? 'Logging out...' : 'Logout',
                style: TextStyle(
                  color: _isLoading ? Colors.grey : Colors.red,
                ),
              ),
              enabled: !_isLoading,
              onTap: _isLoading ? null : () => _logout(context),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Ringkasan Hari Ini"),
            const SizedBox(height: 10),
            Row(
              children: [
                _summaryCard(
                  "Barang Masuk",
                  "15",
                  Icons.arrow_downward,
                  Colors.green,
                ),
                const SizedBox(width: 10),
                _summaryCard(
                  "Barang Keluar",
                  "8",
                  Icons.arrow_upward,
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Peringatan Stok Rendah"),
            const SizedBox(height: 10),
            _buildLowStockWarning(),
            const SizedBox(height: 20),
            _buildSectionTitle("Menu Cepat"),
            const SizedBox(height: 10),
            _buildQuickMenu(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildLowStockWarning() {
    return Card(
      color: Colors.orange.shade50,
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.warning, color: Colors.orange),
        ),
        title: const Text(
          "Paracetamol - Sisa 3",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text("Stok minimum: 5"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LowStockScreen()),
          );
        },
      ),
    );
  }

  Widget _buildQuickMenu() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _menuButton(
            context,
            Icons.inventory,
            "Stok",
            const StockScreen(),
            Colors.blue,
          ),
          _menuButton(
            context,
            Icons.add_box,
            "Tambah",
            const AddItemScreen(),
            Colors.green,
          ),
          _menuButton(
            context,
            Icons.bar_chart,
            "Laporan",
            const ReportScreen(),
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuButton(
      BuildContext context,
      IconData icon,
      String label,
      Widget page,
      Color color,
      ) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Fungsi checkLowStock yang diperbaiki
void checkLowStock(List<ItemModel> items) {
  if (items.isEmpty) return;

  final lowStockItems = items.where((item) => item.stock < item.minStock).toList();

  for (var item in lowStockItems) {
    NotificationService.showLocalNotification(
      "Stok Rendah",
      "Stok ${item.name} hanya tersisa ${item.stock}. Minimum: ${item.minStock}",
    );
  }
}