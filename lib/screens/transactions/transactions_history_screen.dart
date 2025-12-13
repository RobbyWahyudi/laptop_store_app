import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/transaction.dart';
import '../../providers/auth_provider.dart';
import '../../services/transaction_service.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/empty_state.dart';

class TransactionsHistoryScreen extends StatefulWidget {
  const TransactionsHistoryScreen({super.key});

  @override
  State<TransactionsHistoryScreen> createState() =>
      _TransactionsHistoryScreenState();
}

class _TransactionsHistoryScreenState extends State<TransactionsHistoryScreen> {
  late TransactionService _transactionService;
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  final int _limit = 20;
  DateTime? _selectedDateFrom;
  final TextEditingController _dateController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      _transactionService = TransactionService(token);
      _loadTransactions();
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore &&
        _hasMore) {
      _loadTransactions(loadMore: true);
    }
  }

  Future<void> _loadTransactions({bool loadMore = false}) async {
    if (loadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() => _isLoading = true);
      _currentPage = 1;
    }

    try {
      final transactions = await _transactionService.getTransactions(
        page: loadMore ? _currentPage + 1 : 1,
        limit: _limit,
        dateFrom: _selectedDateFrom != null
            ? DateFormatter.formatForApi(_selectedDateFrom!)
            : null,
      );

      setState(() {
        if (loadMore) {
          _transactions.addAll(transactions);
          _currentPage++;
        } else {
          _transactions = transactions;
        }
        _hasMore = transactions.length == _limit;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading transactions: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateFrom ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDateFrom = picked;
        _dateController.text = DateFormatter.formatDisplay(picked);
      });
      _loadTransactions();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDateFrom = null;
      _dateController.clear();
    });
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Date Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Filter by date from...',
                      prefixIcon: const Icon(Icons.calendar_today),
                      suffixIcon: _selectedDateFrom != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearDateFilter,
                            )
                          : null,
                    ),
                    onTap: _selectDate,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Transactions List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildTransactionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (_transactions.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No Transactions Found',
        subtitle: 'Transactions will appear here once completed.',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _transactions.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final transaction = _transactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction #${transaction.id}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    transaction.paymentMethod.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.grey800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Customer and Cashier
            Row(
              children: [
                Icon(Icons.person, size: 16, color: AppTheme.grey600),
                const SizedBox(width: 4),
                Text(
                  transaction.customerName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                Icon(Icons.account_circle, size: 16, color: AppTheme.grey600),
                const SizedBox(width: 4),
                Text(
                  transaction.cashierName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Date and Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormatter.formatDisplay(transaction.createdAt),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.grey600),
                ),
                Text(
                  CurrencyFormatter.format(transaction.totalPrice),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Items Summary
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.grey50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Items (${transaction.totalItems})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...transaction.transactionItems
                      .take(2)
                      .map(
                        (item) => Text(
                          '${item.quantity}x ${item.productName}',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  if (transaction.transactionItems.length > 2)
                    Text(
                      '...and ${transaction.transactionItems.length - 2} more',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppTheme.grey600),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
