import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/product_service.dart';
import '../../services/transaction_service.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/empty_state.dart';

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key});

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  late ProductService _productService;
  late TransactionService _transactionService;
  List<Product> _products = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  final TextEditingController _searchController = TextEditingController();
  String _selectedPaymentMethod = AppConstants.paymentCash;

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      _productService = ProductService(token);
      _transactionService = TransactionService(token);
      _loadProducts();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _productService.getProducts();
      setState(() {
        _products = products.where((p) => p.stock > 0).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _processTransaction() async {
    final cart = Provider.of<CartProvider>(context, listen: false);

    if (cart.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final items = cart.items
          .map(
            (item) => {
              'product_id': item.product.id,
              'quantity': item.quantity,
            },
          )
          .toList();

      await _transactionService.createTransaction(
        paymentMethod: _selectedPaymentMethod,
        items: items,
      );

      cart.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      _loadProducts();
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
      child: Row(
        children: [
          // Products List (Left)
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),

                // Products Grid
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildProductsGrid(),
                ),
              ],
            ),
          ),

          // Cart (Right)
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: AppTheme.white,
              border: Border(left: BorderSide(color: AppTheme.grey200)),
            ),
            child: _buildCart(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    final filtered = _products.where((p) {
      final query = _searchController.text.toLowerCase();
      return p.name.toLowerCase().contains(query);
    }).toList();

    if (filtered.isEmpty) {
      return const EmptyState(
        icon: Icons.inventory_outlined,
        title: 'No Products Available',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final product = filtered[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      child: InkWell(
        onTap: () {
          Provider.of<CartProvider>(context, listen: false).addItem(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} added to cart'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                product.isLaptop ? Icons.laptop_mac : Icons.inventory_2,
                size: 48,
                color: AppTheme.grey700,
              ),
              const Spacer(),
              Text(
                product.name,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.format(product.price),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Stock: ${product.stock}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: product.isLowStock
                      ? AppTheme.grey800
                      : AppTheme.grey600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCart() {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Column(
          children: [
            // Cart Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.grey200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Cart', style: Theme.of(context).textTheme.titleLarge),
                  if (cart.isNotEmpty)
                    TextButton(
                      onPressed: cart.clear,
                      child: const Text('Clear'),
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
                      subtitle: 'Add products to get started',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
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
                  border: Border(top: BorderSide(color: AppTheme.grey200)),
                ),
                child: Column(
                  children: [
                    // Payment Method
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPaymentMethod,
                      decoration: const InputDecoration(
                        labelText: 'Payment Method',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
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
                    const SizedBox(height: 16),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          CurrencyFormatter.format(cart.total),
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Checkout Button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Process Transaction',
                        onPressed: _processTransaction,
                        icon: Icons.check_circle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCartItem(CartItem item, CartProvider cart) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(item.product.price),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    cart.updateQuantity(item.product.id, item.quantity - 1);
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 20,
                ),
                Text(
                  item.quantity.toString(),
                  style: Theme.of(context).textTheme.titleMedium,
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
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
