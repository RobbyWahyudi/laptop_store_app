import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class ProductForm extends StatefulWidget {
  final Product? product; // null for add, existing product for edit
  final Function(Map<String, dynamic>) onSubmit;
  final bool isLoading;
  final String? error; // Add error field
  final String? token; // Add token parameter

  const ProductForm({
    super.key,
    this.product,
    required this.onSubmit,
    this.isLoading = false,
    this.error,
    this.token, // Add token parameter
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();

  // Common fields
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  int? _selectedCategoryId;
  List<Category> _categories = [];

  // Product type
  String _productType = 'laptop';

  // Laptop specific fields
  late TextEditingController _brandController;
  late TextEditingController _processorController;
  late TextEditingController _ramController;
  late TextEditingController _storageController;
  late TextEditingController _gpuController;
  late TextEditingController _screenResolutionController;
  late TextEditingController _weightController;
  late TextEditingController _osController;

  // Accessory specific fields
  late TextEditingController _accessoryTypeController;

  @override
  void initState() {
    super.initState();

    // Initialize common controllers
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
      text: widget.product != null ? widget.product!.price.toString() : '',
    );
    _stockController = TextEditingController(
      text: widget.product != null ? widget.product!.stock.toString() : '',
    );
    // Set selected category ID if product exists
    if (widget.product != null) {
      // We'll set this when we load categories
    }

    // Initialize laptop controllers
    if (widget.product is Laptop) {
      final laptop = widget.product as Laptop;
      _brandController = TextEditingController(text: laptop.brand);
      _processorController = TextEditingController(text: laptop.processor);
      _ramController = TextEditingController(text: laptop.ramGb.toString());
      _storageController = TextEditingController(text: laptop.storage);
      _gpuController = TextEditingController(text: laptop.gpu ?? '');
      // For existing products, we use the screenResolution field which contains the full display string
      _screenResolutionController = TextEditingController(
        text: laptop.screenResolution ?? '',
      );
      _weightController = TextEditingController(
        text: laptop.weight?.toString() ?? '',
      );
      _osController = TextEditingController(text: laptop.operatingSystem ?? '');
      _productType = 'laptop';
    } else {
      _brandController = TextEditingController();
      _processorController = TextEditingController();
      _ramController = TextEditingController();
      _storageController = TextEditingController();
      _gpuController = TextEditingController();
      _screenResolutionController = TextEditingController();
      _weightController = TextEditingController();
      _osController = TextEditingController();
    }

    // Initialize accessory controller
    if (widget.product is Accessory) {
      final accessory = widget.product as Accessory;
      _accessoryTypeController = TextEditingController(
        text: accessory.accessoryType,
      );
      _productType = 'accessory';
    } else {
      _accessoryTypeController = TextEditingController();
    }

    // Load categories if token is available
    if (widget.token != null) {
      _loadCategories();
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();

    // Laptop controllers
    _brandController.dispose();
    _processorController.dispose();
    _ramController.dispose();
    _storageController.dispose();
    _gpuController.dispose();
    _screenResolutionController.dispose();
    _weightController.dispose();
    _osController.dispose();

    // Accessory controller
    _accessoryTypeController.dispose();

    super.dispose();
  }

  /// Load categories from API
  Future<void> _loadCategories() async {
    if (widget.token == null) return;

    try {
      print('Loading categories with token: ${widget.token}');
      final productService = ProductService(widget.token!);
      final categories = await productService.getCategories();
      print('Loaded ${categories.length} categories');

      if (mounted) {
        setState(() {
          _categories = categories;
          print('Categories updated in state. Count: ${_categories.length}');

          // Set selected category if editing existing product
          if (widget.product != null && widget.product!.categoryId != null) {
            _selectedCategoryId = widget.product!.categoryId;
            print('Selected category ID set to: $_selectedCategoryId');
          }
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      // Handle error silently or show a message
      if (mounted) {
        // Optionally show error message
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> data = {
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0,
        'stock': int.tryParse(_stockController.text) ?? 0,
        'category_id': _selectedCategoryId,
        'type': _productType,
      };

      // Add type-specific fields
      if (_productType == 'laptop') {
        data.addAll({
          'brand': _brandController.text,
          'cpu': _processorController.text,
          'ram': int.tryParse(_ramController.text) ?? 0,
          'storage': _storageController.text,
          'gpu': _gpuController.text.isEmpty ? null : _gpuController.text,
          'display': _screenResolutionController.text.isEmpty
              ? ''
              : _screenResolutionController.text,
          'weight': _weightController.text.isEmpty
              ? null
              : double.tryParse(_weightController.text),
          'os': _osController.text.isEmpty ? null : _osController.text,
        });
      } else {
        data['accessory_type'] = _accessoryTypeController.text;
      }

      widget.onSubmit(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            16,
          ).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error message
              if (widget.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.grey100,
                    border: Border.all(color: AppTheme.grey300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Product Type Selector
              const Text(
                'Product Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Laptop'),
                    selected: _productType == 'laptop',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _productType = 'laptop');
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Accessory'),
                    selected: _productType == 'accessory',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _productType = 'accessory');
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Common Fields
              CustomTextField(
                label: 'Product Name',
                controller: _nameController,
                prefixIcon: Icons.laptop_mac,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // CustomTextField(
              //   label: 'Description',
              //   controller: _descriptionController,
              //   prefixIcon: Icons.description_outlined,
              //   maxLines: 3,
              // ),
              // const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Price',
                      controller: _priceController,
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'Stock',
                      controller: _stockController,
                      prefixIcon: Icons.inventory_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter stock';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              if (_categories.isEmpty)
                const Text(
                  'Loading categories...',
                  style: TextStyle(color: Colors.grey),
                )
              else
                DropdownButtonFormField<int?>(
                  initialValue: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 24),

              // Type-specific fields
              if (_productType == 'laptop') ...[
                const Text(
                  'Laptop Specifications',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Brand',
                  controller: _brandController,
                  prefixIcon: Icons.branding_watermark_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter brand';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Processor',
                  controller: _processorController,
                  prefixIcon: Icons.memory_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter processor';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'RAM (GB)',
                        controller: _ramController,
                        prefixIcon: Icons.sd_card_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter RAM';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Storage',
                        controller: _storageController,
                        prefixIcon: Icons.storage_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter storage';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'GPU (optional)',
                  controller: _gpuController,
                  prefixIcon: Icons.view_in_ar_outlined,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Screen Resolution (optional)',
                  controller: _screenResolutionController,
                  prefixIcon: Icons.hd_outlined,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Weight (kg, optional)',
                  controller: _weightController,
                  prefixIcon: Icons.fitness_center_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Operating System (optional)',
                  controller: _osController,
                  prefixIcon: Icons.computer_outlined,
                ),
              ] else ...[
                const Text(
                  'Accessory Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Accessory Type',
                  controller: _accessoryTypeController,
                  prefixIcon: Icons.category_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter accessory type';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 32),

              // Submit Button
              CustomButton(
                text: widget.product == null ? 'Add Product' : 'Update Product',
                onPressed: widget.isLoading ? null : _submitForm,
                isLoading: widget.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
