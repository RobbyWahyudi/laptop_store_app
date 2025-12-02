import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/analytics.dart';
import '../../providers/auth_provider.dart';
import '../../services/analytics_service.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/empty_state.dart';
import '../../screens/cart/cart_screen.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  late AnalyticsService _analyticsService;
  DashboardStats? _stats;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      _analyticsService = AnalyticsService(token);
      _loadDashboardData();
    }
  }

  Future<void> _openCart() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );

    // Refresh dashboard if transaction was completed
    if (result == true) {
      _loadDashboardData();
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await _analyticsService.getDashboardStats();

      setState(() {
        _stats = stats;
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Error Loading Dashboard',
        subtitle: _error,
        action: ElevatedButton.icon(
          onPressed: _loadDashboardData,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      );
    }

    if (_stats == null) {
      return const EmptyState(
        icon: Icons.dashboard_outlined,
        title: 'No Data Available',
        subtitle: 'Dashboard data will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with refresh button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _loadDashboardData,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh Dashboard',
                    ),
                    IconButton(
                      onPressed: _openCart,
                      icon: const Icon(Icons.shopping_cart),
                      tooltip: 'Open Cart',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats Grid
            GridView.count(
              padding: EdgeInsets.zero,
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                StatCard(
                  title: "Today's Sales",
                  value: CurrencyFormatter.format(_stats!.today.totalSales),
                  icon: Icons.attach_money,
                  iconColor: AppTheme.black,
                ),
                StatCard(
                  title: "Today's Transactions",
                  value: _stats!.today.totalTransactions.toString(),
                  icon: Icons.receipt_long,
                  iconColor: AppTheme.grey700,
                ),
                StatCard(
                  title: 'Low Stock Items',
                  value: _stats!.lowStock.totalAlerts.toString(),
                  icon: Icons.warning_amber,
                  iconColor: _stats!.lowStock.totalAlerts > 0
                      ? AppTheme.grey800
                      : AppTheme.grey500,
                ),
                StatCard(
                  title: 'Monthly Revenue',
                  value: CurrencyFormatter.format(_stats!.thisMonth.totalSales),
                  icon: Icons.trending_up,
                  iconColor: AppTheme.black,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Best Sellers Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Best Sellers',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_stats!.topProducts.isEmpty)
              const EmptyState(
                icon: Icons.inventory_outlined,
                title: 'No Best Sellers',
                subtitle: 'Sales data will appear here',
              )
            else
              ..._stats!.topProducts.map(
                (product) => _buildTopProductCard(product),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductCard(TopProduct product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.grey100,
          child: Icon(
            product.productType == 'laptop'
                ? Icons.laptop_mac
                : Icons.inventory_2,
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
