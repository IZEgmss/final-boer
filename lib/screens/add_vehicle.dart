import 'package:flutter/material.dart';
import 'package:finalboer/services/vehicle_service.dart';
 
class AddVehicleScreen extends StatefulWidget {
  final Map<String, dynamic>? existingData;
  final String? id;
 
  const AddVehicleScreen({super.key, this.existingData, this.id});
 
  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}
 
class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = VehicleService();
 
  final tipoController = TextEditingController();
  final proprietarioController = TextEditingController();
  final marcaController = TextEditingController();
  final anoController = TextEditingController();
  // NOVO: Adicione o controller para a imagem
  final imagemController = TextEditingController();
 
  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      tipoController.text = widget.existingData!['tipoVeiculo'];
      proprietarioController.text = widget.existingData!['proprietario'];
      marcaController.text = widget.existingData!['marca'];
      anoController.text = widget.existingData!['ano'].toString();
      // NOVO: Preencha o campo da imagem se ela existir
      imagemController.text = widget.existingData!['imagemUrl'] ?? '';
    }
  }
 
  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'tipoVeiculo': tipoController.text,
        'proprietario': proprietarioController.text,
        'marca': marcaController.text,
        'ano': int.parse(anoController.text),
        // NOVO: Adicione o campo da imagem ao mapa de dados
        'imagemUrl': imagemController.text,
      };
 
      try {
        if (widget.id == null) {
          await _service.addVehicle(data);
        } else {
          await _service.updateVehicle(widget.id!, data);
        }
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'Adicionar Veículo' : 'Editar Veículo'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          // Envolva a Column com SingleChildScrollView para evitar overflow
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: tipoController,
                  decoration: const InputDecoration(labelText: 'Tipo de Veículo'),
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                TextFormField(
                  controller: proprietarioController,
                  decoration: const InputDecoration(labelText: 'Proprietário'),
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                TextFormField(
                  controller: marcaController,
                  decoration: const InputDecoration(labelText: 'Marca'),
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                TextFormField(
                  controller: anoController,
                  decoration: const InputDecoration(labelText: 'Ano'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                // NOVO: Adicione o TextFormField para o URL da imagem
                TextFormField(
                  controller: imagemController,
                  decoration: const InputDecoration(labelText: 'URL da Imagem'),
                  // Validação opcional, pois a imagem pode não ser obrigatória
                  // validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}