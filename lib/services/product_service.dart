import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:finalboer/models/product.dart';

class ProductService {
  final String baseUrl =
      'https://690e92f7bd0fefc30a04d297.mockapi.io'; // Mantenha sua URL base

  Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
    ); // Ajuste o endpoint se necessário
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao buscar produtos');
    }
  }

  Future<void> addProduct(Map<String, dynamic> data) async {
    final payload = {...data, 'price': data['price']};

    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
        'Erro ao adicionar produto: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao atualizar produto: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<void> deleteProduct(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erro ao excluir produto');
    }
  }
}
