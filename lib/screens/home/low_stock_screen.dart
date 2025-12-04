import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../models/stock_alert.dart';
import '../../services/analytics_service.dart';
import '../../services/api_service.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/empty_state.dart';

class LowStockScreen extends StatefulWidget {
  final String token;

  const LowStockScreen({super.key, required this.token});

  @override
  State<LowStockScreen> createState() => _LowStockScreenState();
}

class _LowStockScreenState extends State<LowStockScreen> {
  late AnalyticsService _analyticsService;
  StockAlertData? _stockData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _analyticsService = AnalyticsService(widget.token);
    _loadStockAlerts();
  }

  Future<void> _loadStockAlerts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stockAlertData = await _analyticsService.getDetailedStockAlerts();
      setState(() {
        _stockData = stockAlertData;
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
      appBar: AppBar(
        title: const Text('Low Stock Items'),
        backgroundColor: AppTheme.black, // Changed to black to match theme
        foregroundColor: AppTheme.white, // Set text color to white
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _loadStockAlerts,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? EmptyState(
                icon: Icons.error_outline,
                title: 'Error Loading Data',
                subtitle: _error!,
                action: ElevatedButton.icon(
                  onPressed: _loadStockAlerts,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              )
            : _stockData == null ||
                  (_stockData!.laptops.isEmpty &&
                      _stockData!.accessories.isEmpty)
            ? const EmptyState(
                icon: Icons.inventory_outlined,
                title: 'No Low Stock Items',
                subtitle: 'All products have sufficient stock',
              )
            : RefreshIndicator(
                onRefresh: _loadStockAlerts,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Summary Card - Full width
                      Card(
                        margin: EdgeInsets.zero, // Remove default margin
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stock Alert Summary',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Total Alerts: ${_stockData!.totalAlerts}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Laptops: ${_stockData!.laptops.length} items',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Accessories: ${_stockData!.accessories.length} items',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Laptops Section
                      if (_stockData!.laptops.isNotEmpty) ...[
                        Text(
                          'Low Stock Laptops',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _stockData!.laptops.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final laptop = _stockData!.laptops[index];
                            return _buildStockItemCard(laptop, true);
                          },
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Accessories Section
                      if (_stockData!.accessories.isNotEmpty) ...[
                        Text(
                          'Low Stock Accessories',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _stockData!.accessories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final accessory = _stockData!.accessories[index];
                            return _buildStockItemCard(accessory, false);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStockItemCard(StockAlertItem item, bool isLaptop) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.grey100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isLaptop ? Icons.laptop_mac : Icons.inventory_2,
            color: AppTheme.black,
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.brand}${item.category.isNotEmpty ? ' • ${item.category}' : ''}',
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.grey800.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Stock: ${item.stock}',
                style: const TextStyle(
                  color: AppTheme.grey800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(item.price),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              isLaptop ? 'Laptop' : 'Accessory',
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
