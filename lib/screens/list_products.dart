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
    final width = MediaQuery.of(context).size.width;
    final int columns = width < 600
        ? 1
        : width < 900
        ? 2
        : width < 1200
        ? 3
        : 4;
    final double aspect = width < 600 ? 0.78 : 0.85;
    final double horizontalPadding = width >= 1200 ? 24 : 12;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loja Flutter'),
        actions: [
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterProducts,
                    decoration: const InputDecoration(
                      hintText: 'Pesquisar produto ou categoria',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          childAspectRatio: aspect,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (ctx, i) {
                          final product = _filteredProducts[i];
                          return Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                    child: Image.network(
                                      product.imageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) =>
                                          const Icon(Icons.image, size: 48),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'R\$ ${product.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      FilledButton.icon(
                                        icon: const Icon(
                                          Icons.add_shopping_cart,
                                        ),
                                        label: const Text('Adicionar'),
                                        onPressed: () {
                                          Provider.of<CartProvider>(
                                            context,
                                            listen: false,
                                          ).addItem(product);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${product.name} adicionado!',
                                              ),
                                              duration: const Duration(
                                                seconds: 1,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Cadastrar'),
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
