import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ghar_bazaar/data/models/app_user.dart';
import 'package:ghar_bazaar/data/models/enums.dart';
import 'package:ghar_bazaar/data/models/vendor_profile.dart';
import 'package:ghar_bazaar/data/providers.dart';
import 'package:ghar_bazaar/core/utils/validators.dart';
import 'package:ghar_bazaar/core/widgets/app_primary_button.dart';
import 'package:ghar_bazaar/core/widgets/app_text_field.dart';

class VendorProfileFormScreen extends ConsumerStatefulWidget {
  const VendorProfileFormScreen({super.key});

  @override
  ConsumerState<VendorProfileFormScreen> createState() =>
      _VendorProfileFormScreenState();
}

class _VendorProfileFormScreenState
    extends ConsumerState<VendorProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _shopDescriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _radiusController = TextEditingController(text: '4');
  String? _locality;
  bool _submitting = false;
  bool _initialized = false;

  @override
  void dispose() {
    _ownerController.dispose();
    _phoneController.dispose();
    _shopNameController.dispose();
    _shopDescriptionController.dispose();
    _addressController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _locality == null) {
      return;
    }
    setState(() => _submitting = true);
    final session = ref.read(authRepositoryProvider).currentSession;
    if (session == null) {
      if (mounted) context.go('/auth/signin');
      return;
    }
    final repository = ref.read(marketplaceRepositoryProvider);
    final profile = VendorProfile(
      uid: session.uid,
      ownerName: _ownerController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      shopName: _shopNameController.text.trim(),
      shopDescription: _shopDescriptionController.text.trim(),
      locality: _locality!,
      shopAddress: _addressController.text.trim(),
      deliveryRadiusKm: double.tryParse(_radiusController.text.trim()),
    );
    await repository.saveVendorProfile(profile);
    final user =
        (await repository.getUser(session.uid)) ??
        AppUser(
          uid: session.uid,
          email: session.email,
          name: profile.ownerName,
          role: UserRole.vendor,
          phone: profile.phoneNumber,
          photoUrl: session.photoUrl,
          isOnboarded: true,
          createdAt: DateTime.now(),
        );
    await repository.saveUser(
      user.copyWith(
        name: profile.ownerName,
        phone: profile.phoneNumber,
        role: UserRole.vendor,
      ),
    );
    ref.invalidate(currentAppUserProvider);
    ref.invalidate(vendorProfileProvider);
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    context.go('/vendor/create-shop');
  }

  @override
  Widget build(BuildContext context) {
    final localities = ref.watch(localitiesProvider);
    final existingProfile = ref.watch(vendorProfileProvider).asData?.value;
    final currentUser = ref.watch(currentAppUserProvider).asData?.value;
    final session = ref.read(authRepositoryProvider).currentSession;
    final isEditing = existingProfile != null;
    if (!_initialized) {
      if (existingProfile != null) {
        _ownerController.text = existingProfile.ownerName;
        _phoneController.text = existingProfile.phoneNumber;
        _shopNameController.text = existingProfile.shopName;
        _shopDescriptionController.text = existingProfile.shopDescription;
        _addressController.text = existingProfile.shopAddress;
        _radiusController.text = (existingProfile.deliveryRadiusKm ?? 4)
            .toStringAsFixed(0);
        _locality = existingProfile.locality;
        _initialized = true;
      } else {
        final fallbackName =
            currentUser?.name ??
            session?.displayName ??
            session?.email.split('@').first;
        final fallbackPhone = currentUser?.phone;
        if ((fallbackName ?? '').isNotEmpty ||
            (fallbackPhone ?? '').isNotEmpty) {
          _ownerController.text = fallbackName ?? '';
          _phoneController.text = fallbackPhone ?? '';
          _initialized = true;
        }
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit vendor profile' : 'Create vendor profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                        Text(
                          isEditing
                              ? 'Update your vendor profile'
                              : 'Set up your vendor profile',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'A polished profile builds trust and helps customers choose your shop quickly.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                        AppTextField(
                          controller: _ownerController,
                          label: 'Owner full name',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (value) => Validators.requiredField(
                            value,
                            label: 'Owner name',
                          ),
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _phoneController,
                          label: 'Phone number',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: Validators.phone,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _shopNameController,
                          label: 'Shop name',
                          prefixIcon: Icons.storefront_outlined,
                          validator: (value) => Validators.requiredField(
                            value,
                            label: 'Shop name',
                          ),
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _shopDescriptionController,
                          label: 'Shop description',
                          prefixIcon: Icons.notes_rounded,
                          maxLines: 3,
                          validator: (value) => Validators.requiredField(
                            value,
                            label: 'Shop description',
                          ),
                        ),
                        const SizedBox(height: 14),
                        localities.when(
                          data: (items) => DropdownButtonFormField<String>(
                            initialValue: _locality,
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
                          error: (_, _) =>
                              const Text('Unable to load localities'),
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _addressController,
                          label: 'Shop address',
                          prefixIcon: Icons.location_on_outlined,
                          maxLines: 2,
                          validator: (value) => Validators.requiredField(
                            value,
                            label: 'Shop address',
                          ),
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _radiusController,
                          label: 'Delivery radius (km)',
                          prefixIcon: Icons.route_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) =>
                              Validators.numeric(value, label: 'Radius'),
                        ),
                        const SizedBox(height: 20),
                        AppPrimaryButton(
                          label: isEditing ? 'Save Changes' : 'Save & Continue',
                          icon: Icons.check_circle_outline_rounded,
                          onPressed: _submit,
                          isLoading: _submitting,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
