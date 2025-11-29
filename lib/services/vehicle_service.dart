import 'dart:convert';
import 'package:http/http.dart' as http;
 
class VehicleService {
  final String baseUrl = 'https://690e92f7bd0fefc30a04d297.mockapi.io';
  
  Future<List<Map<String, dynamic>>> getVehicles() async {
    final response = await http.get(Uri.parse('$baseUrl/veiculos'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Erro ao buscar veículos');
    }
  }
 
  Future<void> addVehicle(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/veiculos'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao adicionar veículo');
    }
  }
 
  Future<void> updateVehicle(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/veiculos/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar veículo');
    }
  }
 
  Future<void> deleteVehicle(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/veiculos/$id'));
    if (response.statusCode != 200) {
      throw Exception('Erro ao excluir veículo');
    }
  }
}