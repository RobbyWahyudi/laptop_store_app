import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'dashboard_tab.dart';
import 'products_tab.dart';
import 'transactions_tab.dart';
import 'ai_recommendations_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    final List<Widget> tabs = _getTabs(authProvider);
    final List<BottomNavigationBarItem> navItems = _getNavItems(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LaptopStore+'),
        actions: [
          // User info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  user?.fullName ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  user?.role.toUpperCase() ?? '',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: navItems,
      ),
    );
  }

  List<Widget> _getTabs(AuthProvider authProvider) {
    if (authProvider.isAdmin) {
      return const [
        DashboardTab(),
        ProductsTab(),
        TransactionsTab(),
        AIRecommendationsTab(),
      ];
    } else if (authProvider.isKasir) {
      return const [TransactionsTab(), ProductsTab(), AIRecommendationsTab()];
    } else {
      // Owner
      return const [DashboardTab(), TransactionsTab()];
    }
  }

  List<BottomNavigationBarItem> _getNavItems(AuthProvider authProvider) {
    if (authProvider.isAdmin) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_outlined),
          activeIcon: Icon(Icons.inventory),
          label: 'Products',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.psychology_outlined),
          activeIcon: Icon(Icons.psychology),
          label: 'AI Recommend',
        ),
      ];
    } else if (authProvider.isKasir) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.point_of_sale_outlined),
          activeIcon: Icon(Icons.point_of_sale),
          label: 'Cashier',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_outlined),
          activeIcon: Icon(Icons.inventory),
          label: 'Products',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.psychology_outlined),
          activeIcon: Icon(Icons.psychology),
          label: 'AI Recommend',
        ),
      ];
    } else {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Transactions',
        ),
      ];
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Ambil AuthProvider sebelum async gap
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Tampilkan dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Logout
    await authProvider.logout();

    // Cek apakah context masih valid setelah async
    if (!context.mounted) return;

    // Arahkan ke Login
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
