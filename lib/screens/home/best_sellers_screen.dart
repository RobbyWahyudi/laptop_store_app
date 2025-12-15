import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/analytics.dart';
import '../../services/analytics_service.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/empty_state.dart';
import '../../providers/auth_provider.dart';

class BestSellersScreen extends StatefulWidget {
  const BestSellersScreen({super.key});

  @override
  State<BestSellersScreen> createState() => _BestSellersScreenState();
}

class _BestSellersScreenState extends State<BestSellersScreen> {
  late AnalyticsService _analyticsService;
  List<TopProduct> _bestSellers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      _analyticsService = AnalyticsService(token);
      _fetchBestSellers();
    }
  }

  Future<void> _fetchBestSellers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bestSellers = await _analyticsService.getBestSellersByType(
        limit: 10,
        type: 'all',
      );
      setState(() {
        _bestSellers = bestSellers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Best Sellers')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? EmptyState(
                icon: Icons.error_outline,
                title: 'Error Loading Best Sellers',
                subtitle: _error,
                action: ElevatedButton.icon(
                  onPressed: _fetchBestSellers,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              )
            : _bestSellers.isEmpty
            ? const EmptyState(
                icon: Icons.inventory_outlined,
                title: 'No Best Sellers',
                subtitle: 'Sales data will appear here',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _bestSellers.length,
                itemBuilder: (context, index) {
                  final product = _bestSellers[index];
                  return _buildProductCard(product);
                },
              ),
      ),
    );
  }

  Widget _buildProductCard(TopProduct product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: AppTheme.grey100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            product.productType == 'laptop'
                ? Icons.laptop_mac
                : Icons.headphones,
            color: AppTheme.black,
          ),
        ),
        title: Text(product.details.name),
        subtitle: Text(
          '${product.totalQty} sold • ${product.productType}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(product.totalRevenue),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Revenue',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.grey600),
            ),
          ],
        ),
      ),
    );
  }
}
