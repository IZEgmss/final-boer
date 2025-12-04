import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finalboer/providers/cart_provider.dart';
import 'package:finalboer/services/notification_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Future<void> _checkout(double total) async {
    if (total <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Carrinho vazio!')));
      return;
    }

    // Simular processamento
    await Future.delayed(const Duration(seconds: 2));
    try {
      await NotificationService().showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Compra Finalizada!',
        body:
            'Seu pedido de R\$ ${total.toStringAsFixed(2)} foi confirmado no Windows.',
        payload: 'pedido_confirmado',
      );
      debugPrint('Notificação enviada com sucesso.');
    } catch (e) {
      debugPrint('Erro ao enviar notificação: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Compra de R\$ ${total.toStringAsFixed(2)} finalizada!',
            ),
          ),
        );
      }
    }

    // Limpar carrinho
    if (mounted) {
      Provider.of<CartProvider>(context, listen: false).clear();
      Navigator.pop(context);
    }
  }

  // Feature 3: Campos para frete e desconto [cite: 566, 567]
  double _shippingCost = 0.0;
  double _discount = 0.0;
  final _couponController = TextEditingController();
  final _cepController = TextEditingController();

  void _applyCoupon() {
    // Lógica simples de cupom
    if (_couponController.text == 'DESC10') {
      setState(() {
        _discount = 10.0; // Desconto fixo de exemplo
      });
    }
  }

  void _calculateShipping() {
    // Simulação de frete baseado no CEP
    if (_cepController.text.isNotEmpty) {
      setState(() {
        _shippingCost = 15.00; // Valor fixo simulado
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    // Feature 3: Cálculo total [cite: 564]
    final total = cart.subtotal + _shippingCost - _discount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho'),
        actions: [
          // Feature 4: Limpar Carrinho [cite: 569]
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              cart.clear();
            },
            tooltip: 'Limpar Tudo',
          ),
        ],
      ),
      body: Column(
        children: [
          // Lista de Itens
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) {
                final item = cart.items.values.toList()[i];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(item.product.imageUrl),
                    ),
                    title: Text(item.product.name),
                    subtitle: Text(
                      'Total: R\$ ${(item.product.price * item.quantity).toStringAsFixed(2)}',
                    ),
                    trailing: SizedBox(
                      width: 120,
                      child: Row(
                        children: [
                          // Feature 1: Decrementar [cite: 558]
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => cart.removeSingleItem(item.id),
                          ),
                          Text('${item.quantity}'),
                          // Feature 1: Incrementar [cite: 558]
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => cart.addItem(item.product),
                          ),
                          // Feature 2: Remover Item [cite: 562]
                          Expanded(
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => cart.removeItem(item.id),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Painel de Totais e Cupons (Feature 3) [cite: 563]
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _cepController,
                          decoration: const InputDecoration(labelText: 'CEP'),
                        ),
                      ),
                      TextButton(
                        onPressed: _calculateShipping,
                        child: const Text('Calcular Frete'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _couponController,
                          decoration: const InputDecoration(
                            labelText: 'Cupom (DESC10)',
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _applyCoupon,
                        child: const Text('Aplicar'),
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildSummaryLine('Subtotal', cart.subtotal),
                  _buildSummaryLine('Frete', _shippingCost),
                  _buildSummaryLine('Desconto', -_discount, isDiscount: true),
                  const Divider(),
                  _buildSummaryLine(
                    'TOTAL',
                    total > 0 ? total : 0.0,
                    isBold: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _checkout(total > 0 ? total : 0.0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'FINALIZAR COMPRA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(
    String label,
    double value, {
    bool isBold = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 14,
            ),
          ),
          Text(
            'R\$ ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 14,
              color: isDiscount ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
