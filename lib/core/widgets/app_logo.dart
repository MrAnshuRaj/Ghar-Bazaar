import 'package:flutter/material.dart';
import 'package:ghar_bazaar/core/constants/app_constants.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.large = false, this.showTagline = true});

  final bool large;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = large ? 88.0 : 56.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Color(0xFF2F9E44), Color(0xFF7CC767)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2F9E44).withValues(alpha: 0.24),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Icon(
            Icons.storefront_rounded,
            color: Colors.white,
            size: large ? 42 : 28,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          AppConstants.brandName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.1,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 6),
          Text(
            AppConstants.tagline,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
