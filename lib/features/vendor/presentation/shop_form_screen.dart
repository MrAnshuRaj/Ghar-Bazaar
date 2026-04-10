import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ghar_bazaar/core/utils/app_feedback.dart';
import 'package:uuid/uuid.dart';
import 'package:ghar_bazaar/core/services/image_upload_service.dart';
import 'package:ghar_bazaar/core/widgets/async_value_widget.dart';
import 'package:ghar_bazaar/core/widgets/app_primary_button.dart';
import 'package:ghar_bazaar/core/widgets/app_text_field.dart';
import 'package:ghar_bazaar/core/widgets/marketplace_image.dart';
import 'package:ghar_bazaar/core/utils/validators.dart';
import 'package:ghar_bazaar/data/models/shop.dart';
import 'package:ghar_bazaar/data/providers.dart';

class ShopFormScreen extends ConsumerStatefulWidget {
  const ShopFormScreen({super.key});

  @override
  ConsumerState<ShopFormScreen> createState() => _ShopFormScreenState();
}

class _ShopFormScreenState extends ConsumerState<ShopFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _deliveryEstimateController = TextEditingController(text: '30-40 mins');
  final _contactController = TextEditingController();
  final _openingHoursController = TextEditingController(
    text: '7:00 AM - 10:00 PM',
  );
  String? _locality;
  File? _pickedImage;
  bool _initialized = false;
  bool _submitting = false;
  final _uuid = const Uuid();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _deliveryEstimateController.dispose();
    _contactController.dispose();
    _openingHoursController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ref
        .read(imageUploadServiceProvider)
        .pickImage(imageQuality: 78);
    if (picked != null && mounted) {
      setState(() => _pickedImage = picked);
    }
  }

  Future<void> _saveShop(Shop? existingShop) async {
    if (!_formKey.currentState!.validate() || _locality == null) {
      return;
    }
    final session = ref.read(authRepositoryProvider).currentSession;
    if (session == null) {
      return;
    }
    setState(() => _submitting = true);
    try {
      var imageUrl = existingShop?.imageUrl ?? '';
      if (_pickedImage != null) {
        imageUrl = await ref
            .read(imageUploadServiceProvider)
            .uploadImage(_pickedImage!);
      }
      final shop = Shop(
        id: existingShop?.id ?? _uuid.v4(),
        vendorId: session.uid,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
        coverImageUrl: imageUrl,
        locality: _locality!,
        address: _addressController.text.trim(),
        deliveryEstimate: _deliveryEstimateController.text.trim(),
        contactNumber: _contactController.text.trim(),
        openingHours: _openingHoursController.text.trim(),
        categories: existingShop?.categories ?? const [],
      );
      await ref.read(marketplaceRepositoryProvider).upsertShop(shop);
      ref.invalidate(vendorShopProvider);
      if (!mounted) {
        return;
      }
      context.go('/vendor/home');
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
        'Unable to save shop right now. $error',
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
    final localities = ref.watch(localitiesProvider);
    final shopAsync = ref.watch(vendorShopProvider);
    final vendorProfile = ref.watch(vendorProfileProvider).asData?.value;
    final currentUser = ref.watch(currentAppUserProvider).asData?.value;
    return Scaffold(
      appBar: AppBar(title: const Text('Create or Edit Shop')),
      body: AsyncValueWidget(
        value: shopAsync,
        data: (existingShop) {
          if (!_initialized) {
            if (existingShop != null) {
              _nameController.text = existingShop.name;
              _descriptionController.text = existingShop.description;
              _addressController.text = existingShop.address;
              _deliveryEstimateController.text = existingShop.deliveryEstimate;
              _contactController.text = existingShop.contactNumber;
              _openingHoursController.text = existingShop.openingHours ?? '';
              _locality = existingShop.locality;
              _initialized = true;
            } else if (vendorProfile != null) {
              _nameController.text = vendorProfile.shopName;
              _descriptionController.text = vendorProfile.shopDescription;
              _addressController.text = vendorProfile.shopAddress;
              _contactController.text = vendorProfile.phoneNumber.isNotEmpty
                  ? vendorProfile.phoneNumber
                  : (currentUser?.phone ?? '');
              _locality = vendorProfile.locality;
              _initialized = true;
            }
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
                                  existingShop?.imageUrl ??
                                  '',
                              height: 180,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image_outlined),
                            label: const Text('Upload shop image'),
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _nameController,
                            label: 'Shop name',
                            prefixIcon: Icons.storefront_outlined,
                            validator: (value) => Validators.requiredField(
                              value,
                              label: 'Shop name',
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
                          localities.when(
                            data: (items) => DropdownButtonFormField<String>(
                              value: _locality,
                              decoration: const InputDecoration(
                                labelText: 'Locality',
                              ),
                              items: items
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(item),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _locality = value),
                              validator: (value) => value == null
                                  ? 'Please select your locality'
                                  : null,
                            ),
                            loading: () => const LinearProgressIndicator(),
                            error: (_, __) =>
                                const Text('Unable to load localities'),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _addressController,
                            label: 'Address',
                            prefixIcon: Icons.location_on_outlined,
                            maxLines: 2,
                            validator: (value) => Validators.requiredField(
                              value,
                              label: 'Address',
                            ),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _deliveryEstimateController,
                            label: 'Delivery estimate',
                            prefixIcon: Icons.timer_outlined,
                            validator: (value) => Validators.requiredField(
                              value,
                              label: 'Delivery estimate',
                            ),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _contactController,
                            label: 'Contact number',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: Validators.phone,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _openingHoursController,
                            label: 'Opening hours',
                            prefixIcon: Icons.schedule_outlined,
                          ),
                          const SizedBox(height: 20),
                          AppPrimaryButton(
                            label: existingShop == null
                                ? 'Create Shop'
                                : 'Save Changes',
                            icon: Icons.check_circle_outline_rounded,
                            onPressed: () => _saveShop(existingShop),
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
      ),
    );
  }
}
