import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/cart_provider.dart';
import '../../services/transaction_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/empty_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late TransactionService _transactionService;
  bool _isProcessing = false;
  String _selectedPaymentMethod = AppConstants.paymentCash;
  final TextEditingController _customerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      _transactionService = TransactionService(token);
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    super.dispose();
  }

  Future<void> _processTransaction() async {
    final cart = Provider.of<CartProvider>(context, listen: false);

    if (cart.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    if (_customerNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter customer name')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final items = cart.items.map((item) {
        return {
          'product_type': item.product.type,
          'product_id': int.parse(item.product.id),
          'qty': item.quantity,
          'price': item.product.price,
        };
      }).toList();

      await _transactionService.createTransaction(
        customerName: _customerNameController.text,
        paymentMethod: _selectedPaymentMethod,
        items: items,
      );

      cart.clear();
      _customerNameController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to products
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isProcessing,
      message: 'Processing transaction...',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shopping Cart'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Consumer<CartProvider>(
            builder: (context, cart, _) {
              return Column(
                children: [
                  // Customer Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.grey50,
                      border: Border(
                        bottom: BorderSide(color: AppTheme.grey200),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customer Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _customerNameController,
                          decoration: const InputDecoration(
                            labelText: 'Customer Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Payment Method',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedPaymentMethod,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: AppConstants.paymentCash,
                              child: Row(
                                children: const [
                                  Icon(Icons.money, size: 20),
                                  SizedBox(width: 8),
                                  Text('Cash'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: AppConstants.paymentQris,
                              child: Row(
                                children: const [
                                  Icon(Icons.qr_code, size: 20),
                                  SizedBox(width: 8),
                                  Text('QRIS'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: AppConstants.paymentTransfer,
                              child: Row(
                                children: const [
                                  Icon(Icons.account_balance, size: 20),
                                  SizedBox(width: 8),
                                  Text('Transfer'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedPaymentMethod = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  // Cart Items
                  Expanded(
                    child: cart.isEmpty
                        ? const EmptyState(
                            icon: Icons.shopping_cart_outlined,
                            title: 'Cart Empty',
                            subtitle: 'Your cart is empty',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: cart.items.length,
                            itemBuilder: (context, index) {
                              final item = cart.items[index];
                              return _buildCartItem(item, cart);
                            },
                          ),
                  ),

                  // Total & Checkout
                  if (cart.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        border: Border(
                          top: BorderSide(color: AppTheme.grey200),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(cart.total),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: 'Process Transaction',
                              onPressed: _processTransaction,
                              icon: Icons.check_circle,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: 'Continue Shopping',
                              onPressed: () => Navigator.pop(context),
                              isOutlined: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item, CartProvider cart) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  item.product.isLaptop ? Icons.laptop_mac : Icons.inventory_2,
                  color: AppTheme.grey700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(CurrencyFormatter.format(item.product.price)),
                Text('Qty: ${item.quantity}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal: ${CurrencyFormatter.format(item.subtotal)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (item.quantity > 1) {
                          cart.updateQuantity(
                            item.product.id,
                            item.quantity - 1,
                          );
                        } else {
                          cart.removeItem(item.product.id);
                        }
                      },
                      icon: const Icon(Icons.remove),
                      iconSize: 20,
                    ),
                    IconButton(
                      onPressed: item.quantity < item.product.stock
                          ? () {
                              cart.updateQuantity(
                                item.product.id,
                                item.quantity + 1,
                              );
                            }
                          : null,
                      icon: const Icon(Icons.add),
                      iconSize: 20,
                    ),
                    IconButton(
                      onPressed: () => cart.removeItem(item.product.id),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      iconSize: 20,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
