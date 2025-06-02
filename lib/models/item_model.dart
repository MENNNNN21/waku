class ItemModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final int minStock;
  final String? imageUrl;

  ItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.minStock,
    this.imageUrl,
  });

  factory ItemModel.fromMap(String id, Map<String, dynamic> data) {
    return ItemModel(
      id: id,
      name: data['name'],
      category: data['category'],
      price: data['price'].toDouble(),
      stock: data['stock'],
      minStock: data['minStock'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'minStock': minStock,
      'imageUrl': imageUrl,
    };
  }
}
