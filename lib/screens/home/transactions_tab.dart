import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/product_service.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/empty_state.dart';
import '../../screens/cart/cart_screen.dart';
import '../../screens/transactions/transactions_history_screen.dart';

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key});

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  late ProductService _productService;
  List<Product> _products = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all'; // all, laptop, accessory

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      _productService = ProductService(token);
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
      List<Product> products;

      switch (_selectedFilter) {
        case 'laptop':
          products = await _productService.getLaptops(limit: 1000);
          break;
        case 'accessory':
          products = await _productService.getAccessories(limit: 1000);
          break;
        default: // 'all'
          products = await _productService.getProducts(
            type: 'all',
            limit: 1000,
          );
          break;
      }

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

  Future<void> _openCart() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );

    // Refresh products if transaction was completed
    if (result == true) {
      _loadProducts();
    }
  }

  Future<void> _openTransactionHistory() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransactionsHistoryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Column(
          children: [
            // Header with cart and history buttons, search, and filters
            Container(
              padding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: 12,
              ),
              decoration: BoxDecoration(
                color: AppTheme.white,
                // border: Border(bottom: BorderSide(color: AppTheme.grey200)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaksi',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _openTransactionHistory,
                            icon: const Icon(Icons.history),
                            label: const Text(
                              'History',
                              style: TextStyle(fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _openCart,
                            icon: const Icon(Icons.shopping_cart),
                            label: Text(
                              'Cart (${cart.itemCount})',
                              style: TextStyle(fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  // Filter Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: Text('All'),
                        selected: _selectedFilter == 'all',
                        labelStyle: TextStyle(
                          fontWeight: _selectedFilter == 'all'
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: _selectedFilter == 'all'
                              ? Colors.white
                              : AppTheme.grey800,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedFilter = 'all';
                              _loadProducts();
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('Laptops'),
                        selected: _selectedFilter == 'laptop',
                        labelStyle: TextStyle(
                          fontWeight: _selectedFilter == 'laptop'
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: _selectedFilter == 'laptop'
                              ? Colors.white
                              : AppTheme.grey800,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedFilter = 'laptop';
                              _loadProducts();
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('Accessories'),
                        selected: _selectedFilter == 'accessory',
                        labelStyle: TextStyle(
                          fontWeight: _selectedFilter == 'accessory'
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: _selectedFilter == 'accessory'
                              ? Colors.white
                              : AppTheme.grey800,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedFilter = 'accessory';
                              _loadProducts();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Products Grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildProductsGrid(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductsGrid() {
    final filtered = _products.where((p) {
      final query = _searchController.text.toLowerCase();

      // Apply search filter
      if (query.isNotEmpty && !p.name.toLowerCase().contains(query)) {
        return false;
      }

      // Apply type filter
      switch (_selectedFilter) {
        case 'laptop':
          return p.isLaptop;
        case 'accessory':
          return !p.isLaptop;
        default: // 'all'
          return true;
      }
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
        childAspectRatio: 0.9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
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
      margin: const EdgeInsets.symmetric(horizontal: 0),
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
              const SizedBox(height: 12),
              Center(
                child: Icon(
                  product.isLaptop ? Icons.laptop_mac : Icons.headphones,
                  size: 56,
                  color: AppTheme.grey700,
                ),
              ),
              const SizedBox(height: 12),
              Spacer(),
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
}
