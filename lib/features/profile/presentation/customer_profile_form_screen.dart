import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ghar_bazaar/data/models/app_user.dart';
import 'package:ghar_bazaar/data/models/customer_profile.dart';
import 'package:ghar_bazaar/data/models/enums.dart';
import 'package:ghar_bazaar/data/providers.dart';
import 'package:ghar_bazaar/core/utils/validators.dart';
import 'package:ghar_bazaar/core/widgets/app_primary_button.dart';
import 'package:ghar_bazaar/core/widgets/app_text_field.dart';

class CustomerProfileFormScreen extends ConsumerStatefulWidget {
  const CustomerProfileFormScreen({super.key});

  @override
  ConsumerState<CustomerProfileFormScreen> createState() =>
      _CustomerProfileFormScreenState();
}

class _CustomerProfileFormScreenState
    extends ConsumerState<CustomerProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  String? _locality;
  bool _submitting = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
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
    final profile = CustomerProfile(
      uid: session.uid,
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      locality: _locality!,
      addressLine: _addressController.text.trim(),
      landmark: _landmarkController.text.trim().isEmpty
          ? null
          : _landmarkController.text.trim(),
    );
    await repository.saveCustomerProfile(profile);
    final user =
        (await repository.getUser(session.uid)) ??
        AppUser(
          uid: session.uid,
          email: session.email,
          name: profile.fullName,
          role: UserRole.customer,
          phone: profile.phoneNumber,
          photoUrl: session.photoUrl,
          isOnboarded: true,
          createdAt: DateTime.now(),
        );
    await repository.saveUser(
      user.copyWith(
        name: profile.fullName,
        phone: profile.phoneNumber,
        role: UserRole.customer,
      ),
    );
    await ref.read(selectedLocalityProvider.notifier).setLocality(_locality!);
    ref.invalidate(currentAppUserProvider);
    ref.invalidate(customerProfileProvider);
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    context.go('/customer/home');
  }

  @override
  Widget build(BuildContext context) {
    final localities = ref.watch(localitiesProvider);
    final existingProfile = ref.watch(customerProfileProvider).asData?.value;
    final currentUser = ref.watch(currentAppUserProvider).asData?.value;
    final session = ref.read(authRepositoryProvider).currentSession;
    if (!_initialized) {
      if (existingProfile != null) {
        _nameController.text = existingProfile.fullName;
        _phoneController.text = existingProfile.phoneNumber;
        _addressController.text = existingProfile.addressLine;
        _landmarkController.text = existingProfile.landmark ?? '';
        _locality = existingProfile.locality;
        _initialized = true;
      } else {
        final fallbackName =
            currentUser?.name ??
            session?.displayName ??
            (session == null ? null : session.email.split('@').first);
        final fallbackPhone = currentUser?.phone;
        if ((fallbackName ?? '').isNotEmpty ||
            (fallbackPhone ?? '').isNotEmpty) {
          _nameController.text = fallbackName ?? '';
          _phoneController.text = fallbackPhone ?? '';
          _initialized = true;
        }
      }
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Create customer profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tell us where to deliver',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your locality helps us show nearby shops and faster delivery options.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                        AppTextField(
                          controller: _nameController,
                          label: 'Full name',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (value) => Validators.requiredField(
                            value,
                            label: 'Full name',
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
                          label: 'Address line',
                          prefixIcon: Icons.location_on_outlined,
                          maxLines: 2,
                          validator: (value) => Validators.requiredField(
                            value,
                            label: 'Address line',
                          ),
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _landmarkController,
                          label: 'Landmark (optional)',
                          prefixIcon: Icons.pin_drop_outlined,
                        ),
                        const SizedBox(height: 20),
                        AppPrimaryButton(
                          label: 'Save & Continue',
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
