class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? 'Produto sem nome', // Adaptar conforme sua API (ex: tipoVeiculo)
      price: double.tryParse(json['price'].toString()) ?? 0.0, // Adaptar (ex: ano)
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? 'Geral', // Feature 5: Categoria para filtro
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}