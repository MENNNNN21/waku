import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'stock_screen.dart';
import 'add_item_screen.dart';
import 'report_screen.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../models/item_model.dart';
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
      drawer: _buildModernDrawer(),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF2E3192),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LowStockScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeaderSection(),
              _buildStatsSection(),
              _buildLowStockSection(),
              _buildQuickActionsSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernDrawer() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E3192), Color(0xFF1BCEDF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.inventory_2,
                      color: Color(0xFF2E3192),
                      size: 35,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Waku',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Manajemen Stok Modern',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.dashboard, 'Dashboard', () => Navigator.pop(context)),
            _buildDrawerItem(Icons.inventory_outlined, 'Kelola Stok', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StockScreen()));
            }),
            _buildDrawerItem(Icons.add_circle_outline, 'Tambah Barang', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddItemScreen()));
            }),
            _buildDrawerItem(Icons.analytics_outlined, 'Laporan', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportScreen()));
            }),
            _buildDrawerItem(Icons.warning_amber_outlined, 'Stok Rendah', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LowStockScreen()));
            }),
            const Divider(color: Colors.white30, height: 30),
            _buildDrawerItem(
              _isLoading ? Icons.hourglass_empty : Icons.logout,
              _isLoading ? 'Keluar...' : 'Keluar',
              _isLoading ? null : () => _logout(context),
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback? onTap, {bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.red[300] : Colors.white,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.red[300] : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E3192), Color(0xFF1BCEDF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat Datang!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Dashboard Waku',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.today, color: Colors.white70, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Hari ini: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik Inventory',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('barang').snapshots(),
            builder: (context, snapshot) {
              int totalItems = 0;
              int lowStockCount = 0;
              double totalValue = 0;

              if (snapshot.hasData) {
                final docs = snapshot.data!.docs;
                totalItems = docs.length;

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final stock = data['stok'] ?? 0;
                  final minStock = data['minStock'] ?? 5;
                  final price = (data['harga'] ?? 0).toDouble();

                  if (stock < minStock) {
                    lowStockCount++;
                  }
                  totalValue += stock * price;
                }
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Barang',
                      totalItems.toString(),
                      Icons.inventory_2_outlined,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Stok Rendah',
                      lowStockCount.toString(),
                      Icons.warning_amber_outlined,
                      Colors.orange,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('barang').snapshots(),
            builder: (context, snapshot) {
              double totalValue = 0;
              int uniqueCategories = 0;

              if (snapshot.hasData) {
                final docs = snapshot.data!.docs;
                Set<String> categories = {};

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final stock = data['stok'] ?? 0;
                  final price = (data['harga'] ?? 0).toDouble();
                  final category = data['kategori'] ?? '';

                  totalValue += stock * price;
                  if (category.isNotEmpty) {
                    categories.add(category);
                  }
                }
                uniqueCategories = categories.length;
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Nilai Total',
                      'Rp ${totalValue.toStringAsFixed(0)}',
                      Icons.attach_money,
                      const Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Kategori',
                      uniqueCategories.toString(),
                      Icons.category_outlined,
                      const Color(0xFF9C27B0),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Peringatan Stok Rendah',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LowStockScreen()),
                  );
                },
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                label: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('barang')
                .snapshots(),
            builder: (context, snapshot) {
              // Debug: Print error details
              if (snapshot.hasError) {
                print('Firestore Error: ${snapshot.error}');
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Terjadi kesalahan memuat data',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Show loading indicator
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.info, color: Colors.blue),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Belum Ada Data',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Silakan tambah barang terlebih dahulu',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              final allDocs = snapshot.data!.docs;
              final lowStockItems = allDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final stock = data['stok'] ?? 0;
                final minStock = data['minStock'] ?? 5;
                return stock < minStock;
              }).take(3).toList();

              if (lowStockItems.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.check_circle, color: Colors.green),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Semua Stok Aman',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Tidak ada barang dengan stok rendah',
                              style: TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: lowStockItems.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['nama'] ?? 'Nama tidak tersedia';
                  final stock = data['stok'] ?? 0;
                  final minStock = data['minStock'] ?? 5;
                  final category = data['kategori'] ?? 'Tanpa kategori';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.warning_amber, color: Colors.orange),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Kategori: $category',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Sisa: $stock | Min: $minStock',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aksi Cepat',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[50]!, Colors.purple[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        'Kelola Stok',
                        'Lihat & edit stok barang',
                        Icons.inventory_outlined,
                        const Color(0xFF2196F3),
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StockScreen())),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        'Tambah Barang',
                        'Tambah barang baru',
                        Icons.add_circle_outline,
                        const Color(0xFF4CAF50),
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddItemScreen())),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildQuickActionCard(
                  'Lihat Laporan',
                  'Analisis dan statistik lengkap',
                  Icons.analytics_outlined,
                  const Color(0xFF9C27B0),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportScreen())),
                  isWide: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap, {
        bool isWide = false,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isWide
            ? Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
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
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
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
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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