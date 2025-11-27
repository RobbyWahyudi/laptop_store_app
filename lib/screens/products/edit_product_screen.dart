import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_form.dart';
import '../../widgets/loading_overlay.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Consumer2<AuthProvider, ProductProvider>(
        builder: (context, authProvider, productProvider, child) {
          return LoadingOverlay(
            isLoading: productProvider.isLoading,
            child: ProductForm(
              product: widget.product,
              onSubmit: (data) async {
                final product = await productProvider.updateProduct(
                  widget.product.id,
                  data,
                );
                if (product != null && mounted) {
                  // Store context in local variable before async gap
                  final scaffoldContext = context;

                  // Show success message
                  if (scaffoldContext.mounted) {
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      const SnackBar(
                        content: Text('Product updated successfully'),
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

  Future<void> _confirmDelete(BuildContext context) async {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text(
          'Are you sure you want to delete this product? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await productProvider.deleteProduct(widget.product.id);
      if (success && mounted) {
        // Store context in local variable before async gap
        final scaffoldContext = context;

        // Show success message
        if (scaffoldContext.mounted) {
          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
            const SnackBar(
              content: Text('Product deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Go back to products list
        if (scaffoldContext.mounted) {
          Navigator.pop(scaffoldContext, true);
        }
      }
    }
  }
}
