import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ghar_bazaar/data/models/app_user.dart';
import 'package:ghar_bazaar/data/models/enums.dart';
import 'package:ghar_bazaar/data/providers.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  Future<void> _selectRole(
    BuildContext context,
    WidgetRef ref,
    UserRole role,
  ) async {
    final session = ref.read(authRepositoryProvider).currentSession;
    if (session == null) {
      context.go('/auth/signin');
      return;
    }
    final repository = ref.read(marketplaceRepositoryProvider);
    final existing = await repository.getUser(session.uid);
    final user =
        (existing ??
                AppUser(
                  uid: session.uid,
                  email: session.email,
                  name: session.displayName ?? session.email.split('@').first,
                  role: role,
                  photoUrl: session.photoUrl,
                  isOnboarded: true,
                  createdAt: DateTime.now(),
                ))
            .copyWith(role: role, isOnboarded: true);
    await repository.saveUser(user);
    ref.invalidate(currentAppUserProvider);
    if (!context.mounted) {
      return;
    }
    context.go(
      role == UserRole.customer
          ? '/customer/create-profile'
          : '/vendor/create-profile',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose your role')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How will you use Ghar Bazaar?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pick the experience that best matches your goals today.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: MediaQuery.of(context).size.width > 720
                        ? 2
                        : 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _RoleCard(
                        icon: Icons.shopping_basket_rounded,
                        title: 'Customer',
                        description:
                            'Browse nearby grocery shops, compare products, and order essentials from your locality.',
                        onTap: () =>
                            _selectRole(context, ref, UserRole.customer),
                      ),
                      _RoleCard(
                        icon: Icons.storefront_rounded,
                        title: 'Vendor',
                        description:
                            'Create your digital shop, list products, and serve local customers online.',
                        onTap: () => _selectRole(context, ref, UserRole.vendor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF4FAF1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(icon, color: theme.colorScheme.primary, size: 28),
              ),
              const Spacer(),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(description, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Continue',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
