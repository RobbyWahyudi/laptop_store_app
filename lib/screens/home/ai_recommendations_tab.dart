import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/ai_service.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state.dart';

class AIRecommendationsTab extends StatefulWidget {
  const AIRecommendationsTab({super.key});

  @override
  State<AIRecommendationsTab> createState() => _AIRecommendationsTabState();
}

class _AIRecommendationsTabState extends State<AIRecommendationsTab> {
  late AIService _aiService;
  List<Laptop> _recommendations = [];
  bool _isLoading = false;
  String _selectedUseCase = 'gaming';
  double _minBudget = 5000000;
  double _maxBudget = 20000000;

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      _aiService = AIService(token);
    }
  }

  Future<void> _getRecommendations() async {
    setState(() {
      _isLoading = true;
      _recommendations = [];
    });

    try {
      final results = await _aiService.recommendLaptop(
        useCase: _selectedUseCase,
        minBudget: _minBudget,
        maxBudget: _maxBudget,
      );

      setState(() {
        _recommendations = results;
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          // Title
          Text(
            'AI Laptop Recommendations',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Get smart recommendations based on your needs',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.grey600),
          ),
          const SizedBox(height: 24),

          // Use Case Selection
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 0),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What will you use it for?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.useCases.map((useCase) {
                      final isSelected = useCase == _selectedUseCase;
                      return FilterChip(
                        label: Text(useCase.toUpperCase()),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedUseCase = useCase);
                        },
                        backgroundColor: AppTheme.grey100,
                        selectedColor: AppTheme.black,
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.white : AppTheme.grey800,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Budget Range
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 0),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget Range',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Min',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              CurrencyFormatter.format(_minBudget),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ),
                      const Text(' - '),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Max',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              CurrencyFormatter.format(_maxBudget),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: RangeValues(_minBudget, _maxBudget),
                    min: 3000000,
                    max: 50000000,
                    divisions: 47,
                    labels: RangeLabels(
                      CurrencyFormatter.format(_minBudget),
                      CurrencyFormatter.format(_maxBudget),
                    ),
                    onChanged: (values) {
                      setState(() {
                        _minBudget = values.start;
                        _maxBudget = values.end;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Get Recommendations Button
          CustomButton(
            text: 'Get Recommendations',
            onPressed: _getRecommendations,
            isLoading: _isLoading,
            icon: Icons.psychology,
          ),
          const SizedBox(height: 24),

          // Results
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_recommendations.isEmpty && !_isLoading)
            const EmptyState(
              icon: Icons.lightbulb_outline,
              title: 'No Recommendations Yet',
              subtitle: 'Configure your preferences and get recommendations',
            )
          else
            ..._recommendations.map(
              (laptop) => _buildRecommendationCard(laptop),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Laptop laptop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.laptop_mac, size: 32, color: AppTheme.grey700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        laptop.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        laptop.brand,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            _buildSpec('Processor', laptop.processor),
            _buildSpec('RAM', '${laptop.ramGb} GB'),
            _buildSpec('Storage', laptop.storage),
            if (laptop.gpu != null) _buildSpec('GPU', laptop.gpu!),
            _buildSpec('Display', '${laptop.screenResolution}'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price', style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      CurrencyFormatter.format(laptop.price),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      padding: const EdgeInsets.only(top: 10),
                      onPressed: () {
                        // Add to cart functionality
                        Provider.of<CartProvider>(
                          context,
                          listen: false,
                        ).addItem(laptop);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${laptop.name} added to cart'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      tooltip: 'Add to Cart',
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

  Widget _buildSpec(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
