import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ghar_bazaar/core/utils/app_feedback.dart';
import 'package:uuid/uuid.dart';
import 'package:ghar_bazaar/core/services/image_upload_service.dart';
import 'package:ghar_bazaar/core/widgets/app_primary_button.dart';
import 'package:ghar_bazaar/core/widgets/app_text_field.dart';
import 'package:ghar_bazaar/core/widgets/marketplace_image.dart';
import 'package:ghar_bazaar/core/utils/validators.dart';
import 'package:ghar_bazaar/data/models/enums.dart';
import 'package:ghar_bazaar/data/models/product.dart';
import 'package:ghar_bazaar/data/providers.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.productId});

  final String? productId;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _stockController = TextEditingController();
  final _unitController = TextEditingController(text: 'kg');
  ProductCategory _category = ProductCategory.fruitsVegetables;
  File? _pickedImage;
  bool _isAvailable = true;
  bool _submitting = false;
  bool _initialized = false;
  final _uuid = const Uuid();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _stockController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ref
        .read(imageUploadServiceProvider)
        .pickImage(imageQuality: 80);
    if (picked != null && mounted) {
      setState(() => _pickedImage = picked);
    }
  }

  Future<void> _saveProduct(
    Product? existing,
    String shopId,
    String locality,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final session = ref.read(authRepositoryProvider).currentSession;
    if (session == null) {
      return;
    }
    setState(() => _submitting = true);
    try {
      var imageUrl = existing?.imageUrl ?? '';
      if (_pickedImage != null) {
        imageUrl = await ref
            .read(imageUploadServiceProvider)
            .uploadImage(_pickedImage!);
      }
      final product = Product(
        id: existing?.id ?? _uuid.v4(),
        vendorId: session.uid,
        shopId: shopId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
        category: _category,
        price: double.parse(_priceController.text.trim()),
        discountPercent: double.tryParse(_discountController.text.trim()) ?? 0,
        stock: int.parse(_stockController.text.trim()),
        unit: _unitController.text.trim(),
        locality: locality,
        isAvailable: _isAvailable,
        createdAt: existing?.createdAt ?? DateTime.now(),
      );
      await ref.read(marketplaceRepositoryProvider).upsertProduct(product);
      ref.invalidate(vendorProductsProvider);
      ref.invalidate(vendorShopProvider);
      if (!mounted) {
        return;
      }
      context.go('/vendor/products');
    } on ImageUploadException catch (error) {
      if (!mounted) {
        return;
      }
      showAppSnackBar(context, error.message, isError: true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppSnackBar(
        context,
        'Unable to save product right now. $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopAsync = ref.watch(vendorShopProvider);
    final productsAsync = ref.watch(vendorProductsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId == null ? 'Add Product' : 'Edit Product'),
      ),
      body: shopAsync.when(
        data: (shop) {
          if (shop == null) {
            return Center(
              child: FilledButton(
                onPressed: () => context.push('/vendor/create-shop'),
                child: const Text('Create shop first'),
              ),
            );
          }
          final existing = productsAsync.asData?.value
              .where((product) => product.id == widget.productId)
              .firstOrNull;
          if (!_initialized && existing != null) {
            _nameController.text = existing.name;
            _descriptionController.text = existing.description;
            _priceController.text = existing.price.toStringAsFixed(0);
            _discountController.text = existing.discountPercent.toStringAsFixed(
              0,
            );
            _stockController.text = existing.stock.toString();
            _unitController.text = existing.unit;
            _category = existing.category;
            _isAvailable = existing.isAvailable;
            _initialized = true;
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: MarketplaceImage(
                              imageUrl:
                                  _pickedImage?.path ??
                                  existing?.imageUrl ??
                                  '',
                              height: 180,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image_outlined),
                            label: const Text('Upload product image'),
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _nameController,
                            label: 'Product name',
                            prefixIcon: Icons.shopping_basket_outlined,
                            validator: (value) => Validators.requiredField(
                              value,
                              label: 'Product name',
                            ),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _descriptionController,
                            label: 'Description',
                            prefixIcon: Icons.notes_rounded,
                            maxLines: 3,
                            validator: (value) => Validators.requiredField(
                              value,
                              label: 'Description',
                            ),
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<ProductCategory>(
                            value: _category,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                            ),
                            items: ProductCategory.values
                                .map(
                                  (category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(category.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _category = value!),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _priceController,
                                  label: 'Price',
                                  prefixIcon: Icons.currency_rupee_rounded,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator: (value) =>
                                      Validators.numeric(value, label: 'Price'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  controller: _discountController,
                                  label: 'Discount %',
                                  prefixIcon: Icons.discount_outlined,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator: (value) => Validators.numeric(
                                    value,
                                    label: 'Discount',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _stockController,
                                  label: 'Stock quantity',
                                  prefixIcon: Icons.inventory_outlined,
                                  keyboardType: TextInputType.number,
                                  validator: (value) =>
                                      Validators.numeric(value, label: 'Stock'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  controller: _unitController,
                                  label: 'Unit',
                                  prefixIcon: Icons.scale_outlined,
                                  validator: (value) =>
                                      Validators.requiredField(
                                        value,
                                        label: 'Unit',
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _isAvailable,
                            onChanged: (value) =>
                                setState(() => _isAvailable = value),
                            title: const Text('Available for customers'),
                          ),
                          const SizedBox(height: 16),
                          AppPrimaryButton(
                            label: existing == null
                                ? 'Add Product'
                                : 'Save Changes',
                            icon: Icons.check_circle_outline_rounded,
                            onPressed: () =>
                                _saveProduct(existing, shop.id, shop.locality),
                            isLoading: _submitting,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}

extension _FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
