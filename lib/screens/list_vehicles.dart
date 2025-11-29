import 'package:flutter/material.dart';
import 'package:finalboer/screens/add_vehicle.dart';
import 'package:finalboer/services/vehicle_service.dart';
 
class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});
 
  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}
 
class _VehicleListScreenState extends State<VehicleListScreen> {
  final _service = VehicleService();
  late Future<List<Map<String, dynamic>>> _vehicles;
 
  @override
  void initState() {
    super.initState();
    _vehicles = _service.getVehicles();
  }
 
  Future<void> _refresh() async {
    setState(() {
      _vehicles = _service.getVehicles();
    });
  }
 
  Future<void> _delete(String id) async {
    await _service.deleteVehicle(id);
    _refresh();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veículos'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _vehicles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar veículos.'));
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('Nenhum veículo cadastrado.'));
          }
 
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, i) {
                final v = data[i];
                // NOVO: Variável para o URL da imagem
                final imageUrl = v['imagemUrl'];
 
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    // NOVO: Widget para exibir a imagem
                    leading: Container(
                      width: 50, // Defina um tamanho para a imagem
                      height: 50,
                      alignment: Alignment.center,
                      // Verifica se o URL é nulo ou vazio
                      child: (imageUrl != null && imageUrl.isNotEmpty)
                          // Exibe a imagem da rede
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              // Mostra um ícone de carregamento enquanto a imagem baixa
                              loadingBuilder: (context, child, progress) {
                                return progress == null
                                    ? child
                                    : const CircularProgressIndicator(strokeWidth: 2);
                              },
                              // Mostra um ícone de erro se o URL falhar
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image_not_supported, color: Colors.grey);
                              },
                            )
                          // Mostra um ícone padrão se não houver URL
                          : const Icon(Icons.directions_car, color: Colors.grey),
                    ),
                    title: Text('${v['tipoVeiculo']} - ${v['marca']}'),
                    subtitle: Text(
                      'Proprietário: ${v['proprietario']} | Ano: ${v['ano']}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddVehicleScreen(
                                  id: v['id'].toString(),
                                  existingData: v,
                                ),
                              ),
                            );
                            if (result == true) _refresh();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _delete(v['id'].toString()),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
          );
          if (result == true) _refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}