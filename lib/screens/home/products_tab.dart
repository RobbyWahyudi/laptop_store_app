import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../screens/products/add_product_screen.dart';
import '../../screens/products/edit_product_screen.dart';
import '../../services/product_service.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/custom_button.dart';

class ProductsTab extends StatefulWidget {
  const ProductsTab({super.key});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  late ProductService _productService;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String _selectedType = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    // Initialize product provider with token
    if (authProvider.token != null) {
      productProvider.initialize(authProvider.token!);
      _productService = ProductService(authProvider.token!);
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
      final products = await _productService.getProducts(
        type: _selectedType == 'all' ? null : _selectedType,
        limit: 1000, // Request all products (increase limit)
      );
      setState(() {
        _products = products;
        _filteredProducts = products;
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

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products
            .where(
              (product) =>
                  product.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _navigateToAddProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );

    // Reload products if a new one was added
    if (result == true) {
      _loadProducts();
    }
  }

  void _navigateToEditProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: product),
      ),
    );

    // Reload products if one was updated
    if (result == true) {
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            color: AppTheme.white,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Produk',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _searchController,
                  onChanged: _filterProducts,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterProducts('');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Laptops', 'laptop'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Accessories', 'accessory'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_outlined,
                          size: 64,
                          color: AppTheme.grey400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(color: AppTheme.grey600),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadProducts,
                    child: ListView.builder(
                      itemCount: _filteredProducts.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return _buildProductCard(product);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: authProvider.isAdmin
          ? FloatingActionButton(
              onPressed: _navigateToAddProduct,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedType = value);
        _loadProducts();
      },
      backgroundColor: AppTheme.grey100,
      selectedColor: AppTheme.black,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.white : AppTheme.grey800,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showProductDetails(product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    product.isLaptop ? Icons.laptop_mac : Icons.inventory_2,
                    size: 20,
                    color: AppTheme.grey700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: product.isOutOfStock
                          ? AppTheme.grey800
                          : product.isLowStock
                          ? AppTheme.grey500
                          : AppTheme.grey200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${product.stock} pcs',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: product.isOutOfStock || product.isLowStock
                            ? AppTheme.white
                            : AppTheme.grey800,
                      ),
                    ),
                  ),
                ],
              ),
              if (product is Laptop) ...[
                const SizedBox(height: 8),
                Text(
                  product.specs,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (product.category != null) ...[
                const SizedBox(height: 4),
                Text(
                  product.category!,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    CurrencyFormatter.format(product.price),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (product.isLowStock)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.grey100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Low Stock',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.grey700,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            24,
          ).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                product.name,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                CurrencyFormatter.format(product.price),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoRow('Stock', '${product.stock} units'),
              _buildInfoRow('Category', product.category ?? '-'),
              _buildInfoRow('Type', product.type.toUpperCase()),
              if (product is Laptop) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Specifications',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Brand', product.brand),
                _buildInfoRow('Processor', product.processor),
                _buildInfoRow('RAM', '${product.ramGb} GB'),
                _buildInfoRow('Storage', product.storage),
                if (product.gpu != null) _buildInfoRow('GPU', product.gpu!),
              ],
              const SizedBox(height: 24),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Row(
                    children: [
                      if (authProvider.isAdmin) ...[
                        Expanded(
                          child: CustomButton(
                            text: 'Edit Product',
                            onPressed: () {
                              Navigator.pop(context);
                              _navigateToEditProduct(product);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: CustomButton(
                          text: 'Close',
                          onPressed: () => Navigator.pop(context),
                          isOutlined: true,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
