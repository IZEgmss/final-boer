import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finalboer/models/product.dart';
import 'package:finalboer/services/product_service.dart';
import 'package:finalboer/providers/cart_provider.dart';
import 'package:finalboer/screens/cart_screen.dart';
import 'package:finalboer/screens/add_product.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _service = ProductService();
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;

  // Feature 5: Controlador de Pesquisa [cite: 570]
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _service.getProducts();
      setState(() {
        _allProducts = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Feature 5: Lógica de Filtro [cite: 571]
  void _filterProducts(String query) {
    final filtered = _allProducts.where((product) {
      final nameLower = product.name.toLowerCase();
      final categoryLower = product.category.toLowerCase();
      final searchLower = query.toLowerCase();
      return nameLower.contains(searchLower) ||
          categoryLower.contains(searchLower);
    }).toList();

    setState(() {
      _filteredProducts = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loja Flutter'),
        backgroundColor:
            Colors.blue, // Mudou de verde para azul conforme imagem do doc
        actions: [
          // Ícone do carrinho com contador
          Consumer<CartProvider>(
            builder: (_, cart, ch) => Badge(
              label: Text(cart.itemCount.toString()),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => const CartScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Feature 5: Barra de Pesquisa
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterProducts,
              decoration: const InputDecoration(
                labelText: 'Pesquisar produto ou categoria',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (ctx, i) {
                      final product = _filteredProducts[i];
                      return ListTile(
                        leading: Image.network(
                          product.imageUrl,
                          width: 50,
                          errorBuilder: (context, error, stack) =>
                              const Icon(Icons.image),
                        ),
                        title: Text(product.name),
                        subtitle: Text(
                          'R\$ ${product.price.toStringAsFixed(2)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.add_shopping_cart,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            // Funcionalidade: Adicionar ao carrinho [cite: 555]
                            Provider.of<CartProvider>(
                              context,
                              listen: false,
                            ).addItem(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} adicionado!'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      // Botão para cadastrar produtos (Mantendo a funcionalidade original)
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(builder: (ctx) => const AddVehicleScreen()),
              )
              .then((res) {
                if (res == true) {
                  _loadProducts();
                }
              });
        },
      ),
    );
  }
}
