import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';
import '../services/database_service.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Elektronik',
    'Pakaian',
    'Makanan',
    'Minuman',
    'Kosmetik',
    'Obat-obatan',
    'Alat Tulis',
    'Lainnya'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Manajemen Stok"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        shadowColor: Colors.grey[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ItemSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari barang...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Category Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: Colors.blue[100],
                          checkmarkColor: Colors.blue[800],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Items List dengan StreamBuilder
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('items')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Terjadi kesalahan: ${snapshot.error}',
                          style: TextStyle(color: Colors.red[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada barang',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tambahkan barang pertama Anda',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                // Filter data berdasarkan pencarian dan kategori
                var filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final category = data['category'] ?? '';

                  bool matchesSearch = _searchQuery.isEmpty ||
                      name.contains(_searchQuery.toLowerCase());
                  bool matchesCategory = _selectedCategory == 'Semua' ||
                      category == _selectedCategory;

                  return matchesSearch && matchesCategory;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64,
                            color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada barang ditemukan',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Coba ubah kata kunci pencarian',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return _buildItemCard(doc.id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddItemDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildItemCard(String id, Map<String, dynamic> data) {
    final name = data['name'] ?? 'Nama tidak tersedia';
    final category = data['category'] ?? 'Kategori tidak tersedia';
    final price = data['price'] ?? 0;
    final stock = data['stock'] ?? 0;
    final minStock = data['minStock'] ?? 0;

    // Tentukan warna berdasarkan stok
    Color stockColor = Colors.green;
    String stockStatus = 'Normal';

    if (stock <= 0) {
      stockColor = Colors.red;
      stockStatus = 'Habis';
    } else if (stock <= minStock) {
      stockColor = Colors.orange;
      stockStatus = 'Stok Rendah';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${price.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]}.',
                        )}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                // Stock Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: stockColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: stockColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        stockStatus,
                        style: TextStyle(
                          fontSize: 12,
                          color: stockColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Stok: $stock',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: stockColor,
                      ),
                    ),
                    Text(
                      'Min: $minStock',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditItemDialog(id, data),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: BorderSide(color: Colors.blue[300]!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showUpdateStockDialog(id, data),
                    icon: const Icon(Icons.inventory, size: 16),
                    label: const Text('Update Stok'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: BorderSide(color: Colors.green[300]!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _deleteItem(id, name),
                  icon: const Icon(Icons.delete, size: 20),
                  color: Colors.red,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red[50],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final minStockController = TextEditingController();
    String selectedCategory = 'Makanan';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Barang Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: _categories.skip(1).map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCategory = value!;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stok Awal',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: minStockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Minimum Stok',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  priceController.text.isEmpty ||
                  stockController.text.isEmpty ||
                  minStockController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semua field harus diisi')),
                );
                return;
              }

              try {
                await FirebaseFirestore.instance.collection('items').add({
                  'name': nameController.text,
                  'category': selectedCategory,
                  'price': int.parse(priceController.text),
                  'stock': int.parse(stockController.text),
                  'minStock': int.parse(minStockController.text),
                  'createdAt': FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Barang berhasil ditambahkan')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menambahkan barang: $e')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(String id, Map<String, dynamic> data) {
    final nameController = TextEditingController(text: data['name'] ?? '');
    final priceController = TextEditingController(text: data['price']?.toString() ?? '');
    final minStockController = TextEditingController(text: data['minStock']?.toString() ?? '');
    String selectedCategory = data['category'] ?? 'Makanan';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Barang'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categories.skip(1).contains(selectedCategory)
                    ? selectedCategory
                    : 'Makanan',
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: _categories.skip(1).map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCategory = value!;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: minStockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Minimum Stok',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stok Saat Ini',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${data['stock'] ?? 0} unit',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Gunakan "Update Stok" untuk mengubah jumlah stok',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  priceController.text.isEmpty ||
                  minStockController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semua field harus diisi')),
                );
                return;
              }

              try {
                await FirebaseFirestore.instance
                    .collection('items')
                    .doc(id)
                    .update({
                  'name': nameController.text,
                  'category': selectedCategory,
                  'price': int.parse(priceController.text),
                  'minStock': int.parse(minStockController.text),
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Barang berhasil diperbarui')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal memperbarui barang: $e')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showUpdateStockDialog(String id, Map<String, dynamic> data) {
    final stockController = TextEditingController();
    String operationType = 'add'; // 'add' atau 'subtract' atau 'set'
    int currentStock = data['stock'] ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Update Stok - ${data['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stok Saat Ini',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currentStock unit',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Jenis Operasi:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Tambah', style: TextStyle(fontSize: 14)),
                      value: 'add',
                      groupValue: operationType,
                      onChanged: (value) {
                        setState(() {
                          operationType = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Kurangi', style: TextStyle(fontSize: 14)),
                      value: 'subtract',
                      groupValue: operationType,
                      onChanged: (value) {
                        setState(() {
                          operationType = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                ],
              ),
              RadioListTile<String>(
                title: const Text('Set Manual', style: TextStyle(fontSize: 14)),
                value: 'set',
                groupValue: operationType,
                onChanged: (value) {
                  setState(() {
                    operationType = value!;
                  });
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: operationType == 'set'
                      ? 'Stok Baru'
                      : 'Jumlah ${operationType == 'add' ? 'Tambahan' : 'Pengurangan'}',
                  border: const OutlineInputBorder(),
                  suffixText: 'unit',
                ),
              ),
              const SizedBox(height: 8),
              if (stockController.text.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getStockPreview(currentStock, stockController.text, operationType),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (stockController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Masukkan jumlah stok')),
                  );
                  return;
                }

                try {
                  int inputValue = int.parse(stockController.text);
                  int newStock;

                  switch (operationType) {
                    case 'add':
                      newStock = currentStock + inputValue;
                      break;
                    case 'subtract':
                      newStock = currentStock - inputValue;
                      if (newStock < 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Stok tidak boleh negatif')),
                        );
                        return;
                      }
                      break;
                    case 'set':
                      newStock = inputValue;
                      if (newStock < 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Stok tidak boleh negatif')),
                        );
                        return;
                      }
                      break;
                    default:
                      newStock = currentStock;
                  }

                  await FirebaseFirestore.instance
                      .collection('items')
                      .doc(id)
                      .update({
                    'stock': newStock,
                    'updatedAt': FieldValue.serverTimestamp(),
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Stok berhasil diperbarui: $currentStock → $newStock unit'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal memperbarui stok: $e')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  String _getStockPreview(int currentStock, String input, String operationType) {
    try {
      int inputValue = int.parse(input);
      int newStock;

      switch (operationType) {
        case 'add':
          newStock = currentStock + inputValue;
          return 'Stok akan menjadi: $currentStock + $inputValue = $newStock unit';
        case 'subtract':
          newStock = currentStock - inputValue;
          return 'Stok akan menjadi: $currentStock - $inputValue = $newStock unit';
        case 'set':
          return 'Stok akan diubah menjadi: $inputValue unit';
        default:
          return '';
      }
    } catch (e) {
      return 'Masukkan angka yang valid';
    }
  }

  void _deleteItem(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text('Apakah Anda yakin ingin menghapus "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('items')
                    .doc(id)
                    .delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$name berhasil dihapus')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menghapus: $e')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class ItemSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('items')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snapshot.data!.docs;

        if (results.isEmpty) {
          return const Center(
            child: Text('Tidak ada hasil ditemukan'),
          );
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final data = results[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['name'] ?? ''),
              subtitle: Text(data['category'] ?? ''),
              trailing: Text('Stok: ${data['stock'] ?? 0}'),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Masukkan nama barang untuk mencari'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('items')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final suggestions = snapshot.data!.docs;

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final data = suggestions[index].data() as Map<String, dynamic>;
            final name = data['name'] ?? '';

            return ListTile(
              leading: const Icon(Icons.search),
              title: Text(name),
              onTap: () {
                query = name;
                showResults(context);
              },
            );
          },
        );
      },
    );
  }
}