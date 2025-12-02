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
          products = await _productService.getLaptops();
          break;
        case 'accessory':
          products = await _productService.getAccessories();
          break;
        default: // 'all'
          products = await _productService.getProducts();
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

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Column(
          children: [
            // Header with cart button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                border: Border(bottom: BorderSide(color: AppTheme.grey200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Products',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _openCart,
                    icon: const Icon(Icons.shopping_cart),
                    label: Text('Cart (${cart.itemCount})'),
                  ),
                ],
              ),
            ),
            // Filter Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _selectedFilter == 'all',
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
                    label: const Text('Laptops'),
                    selected: _selectedFilter == 'laptop',
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
                    label: const Text('Accessories'),
                    selected: _selectedFilter == 'accessory',
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
            ),
            const SizedBox(height: 16),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            const SizedBox(height: 16),
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
}
