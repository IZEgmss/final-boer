import 'package:flutter/material.dart';
import 'package:finalboer/services/product_service.dart';

class AddVehicleScreen extends StatefulWidget {
  final Map<String, dynamic>? existingData;
  final String? id;

  const AddVehicleScreen({super.key, this.existingData, this.id});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ProductService();

  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final priceController = TextEditingController();
  final imageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      nameController.text = widget.existingData!['name'] ?? '';
      categoryController.text = widget.existingData!['category'] ?? '';
      priceController.text = widget.existingData!['price']?.toString() ?? '';
      imageController.text = widget.existingData!['imageUrl'] ?? '';
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': nameController.text,
        'category': categoryController.text,
        'price': double.tryParse(priceController.text) ?? 0.0,
        'imageUrl': imageController.text,
      };

      try {
        if (widget.id == null) {
          await _service.addProduct(data);
        } else {
          await _service.updateProduct(widget.id!, data);
        }
        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'Adicionar Produto' : 'Editar Produto'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Preço'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                TextFormField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: 'URL da Imagem'),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
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
