import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_form.dart';
import '../../widgets/loading_overlay.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer2<AuthProvider, ProductProvider>(
        builder: (context, authProvider, productProvider, child) {
          return LoadingOverlay(
            isLoading: productProvider.isLoading,
            child: ProductForm(
              onSubmit: (data) async {
                final product = await productProvider.createProduct(data);
                if (product != null && mounted) {
                  // Store context in local variable before async gap
                  final scaffoldContext = context;

                  // Show success message
                  if (scaffoldContext.mounted) {
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      const SnackBar(
                        content: Text('Product added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }

                  // Go back to products list
                  if (scaffoldContext.mounted) {
                    Navigator.pop(scaffoldContext, true);
                  }
                }
              },
              isLoading: productProvider.isLoading,
              error: productProvider.error,
            ),
          );
        },
      ),
    );
  }
}
