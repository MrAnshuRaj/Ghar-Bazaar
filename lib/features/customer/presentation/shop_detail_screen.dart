import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ghar_bazaar/core/utils/app_feedback.dart';
import 'package:ghar_bazaar/core/widgets/async_value_widget.dart';
import 'package:ghar_bazaar/core/widgets/empty_state_card.dart';
import 'package:ghar_bazaar/core/widgets/marketplace_image.dart';
import 'package:ghar_bazaar/core/widgets/product_card.dart';
import 'package:ghar_bazaar/data/models/cart_state.dart';
import 'package:ghar_bazaar/data/models/enums.dart';
import 'package:ghar_bazaar/data/models/product.dart';
import 'package:ghar_bazaar/data/models/shop.dart';
import 'package:ghar_bazaar/data/providers.dart';

class ShopDetailScreen extends ConsumerStatefulWidget {
  const ShopDetailScreen({super.key, required this.shopId, this.initialShop});

  final String shopId;
  final Shop? initialShop;

  @override
  ConsumerState<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends ConsumerState<ShopDetailScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String? _lastFeedbackMessage;

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted || message.trim().isEmpty || _lastFeedbackMessage == message) {
      return;
    }
    _lastFeedbackMessage = message;
    showAppSnackBar(context, message, isError: isError);
  }

  Future<void> _refreshShopData() async {
    ref.invalidate(shopProvider(widget.shopId));
    ref.invalidate(shopProductsProvider(widget.shopId));
    await Future.wait<void>([
      ref.read(shopProvider(widget.shopId).future).then((_) {}),
      ref.read(shopProductsProvider(widget.shopId).future).then((_) {}),
    ]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addProduct(Product product, String shopName) async {
    final cart = ref.read(cartControllerProvider);
    final cartController = ref.read(cartControllerProvider.notifier);
    if (!cartController.canAddProduct(product)) {
      final shouldReplace =
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Replace cart items?'),
              content: const Text(
                'Your cart contains items from another shop. Clear cart and add this item?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Clear Cart'),
                ),
              ],
            ),
          ) ??
          false;
      if (!shouldReplace) {
        return;
      }
      await cartController.replaceCartAndAdd(product, shopName: shopName);
    } else {
      await cartController.addProduct(product, shopName: shopName);
    }
    if (!mounted) {
      return;
    }
    showAppSnackBar(
      context,
      cart.shopId == product.shopId
          ? '${product.name} updated in cart'
          : '${product.name} added to cart',
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);
    ref.listen<AsyncValue<List<Product>>>(shopProductsProvider(widget.shopId), (
      previous,
      next,
    ) {
      next.whenOrNull(
        error: (error, stackTrace) => _showFeedback(
          'Could not load shop items. ${error.toString()}',
          isError: true,
        ),
        data: (products) {
          final hasCategories =
              (widget.initialShop?.categories ?? const <String>[]).isNotEmpty;
          if (products.isEmpty && hasCategories) {
            _showFeedback(
              'This shop has categories but no items were returned. Pull to refresh or check Firestore data.',
              isError: true,
            );
          }
        },
      );
    });
    if (widget.initialShop == null) {
      ref.listen<AsyncValue<Shop?>>(shopProvider(widget.shopId), (
        previous,
        next,
      ) {
        next.whenOrNull(
          error: (error, stackTrace) => _showFeedback(
            'Could not load shop details. ${error.toString()}',
            isError: true,
          ),
          data: (shop) {
            if (shop == null) {
              _showFeedback('Shop details could not be found.', isError: true);
            }
          },
        );
      });
    }
    final productsAsync = ref.watch(shopProductsProvider(widget.shopId));
    final fallbackShopAsync = widget.initialShop == null
        ? ref.watch(shopProvider(widget.shopId))
        : const AsyncValue<Shop?>.data(null);
    final resolvedShop = widget.initialShop ?? fallbackShopAsync.asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          IconButton(
            onPressed: () => context.push('/customer/cart'),
            icon: Badge.count(
              count: cart.itemCount,
              isLabelVisible: cart.itemCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ],
      ),
      body: resolvedShop == null
          ? AsyncValueWidget(
              value: fallbackShopAsync,
              data: (shop) {
                if (shop == null) {
                  return const Center(child: Text('Shop not found'));
                }
                return RefreshIndicator(
                  onRefresh: _refreshShopData,
                  child: _ShopDetailContent(
                    shop: shop,
                    cart: cart,
                    searchController: _searchController,
                    selectedCategory: _selectedCategory,
                    productsAsync: productsAsync,
                    onSearchChanged: () => setState(() {}),
                    onCategoryChanged: (value) =>
                        setState(() => _selectedCategory = value),
                    onAddProduct: _addProduct,
                    onDecrease: (productId, quantity) => ref
                        .read(cartControllerProvider.notifier)
                        .changeQuantity(productId, quantity - 1),
                    onRetry: _refreshShopData,
                  ),
                );
              },
            )
          : RefreshIndicator(
              onRefresh: _refreshShopData,
              child: _ShopDetailContent(
                shop: resolvedShop,
                cart: cart,
                searchController: _searchController,
                selectedCategory: _selectedCategory,
                productsAsync: productsAsync,
                onSearchChanged: () => setState(() {}),
                onCategoryChanged: (value) =>
                    setState(() => _selectedCategory = value),
                onAddProduct: _addProduct,
                onDecrease: (productId, quantity) => ref
                    .read(cartControllerProvider.notifier)
                    .changeQuantity(productId, quantity - 1),
                onRetry: _refreshShopData,
              ),
            ),
    );
  }
}

class _ShopDetailContent extends StatelessWidget {
  const _ShopDetailContent({
    required this.shop,
    required this.cart,
    required this.searchController,
    required this.selectedCategory,
    required this.productsAsync,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onAddProduct,
    required this.onDecrease,
    required this.onRetry,
  });

  final Shop shop;
  final CartState cart;
  final TextEditingController searchController;
  final String selectedCategory;
  final AsyncValue<List<Product>> productsAsync;
  final VoidCallback onSearchChanged;
  final ValueChanged<String> onCategoryChanged;
  final Future<void> Function(Product product, String shopName) onAddProduct;
  final Future<void> Function(String productId, int quantity) onDecrease;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        MarketplaceImage(
          imageUrl: shop.coverImageUrl ?? shop.imageUrl,
          height: 220,
          borderRadius: BorderRadius.circular(28),
          placeholderIcon: Icons.storefront_rounded,
        ),
        const SizedBox(height: 16),
        Text(
          shop.name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(shop.description),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              label: Text(shop.locality),
              avatar: const Icon(Icons.pin_drop_outlined),
            ),
            Chip(
              label: Text(shop.deliveryEstimate),
              avatar: const Icon(Icons.timer_outlined),
            ),
            if ((shop.openingHours ?? '').isNotEmpty)
              Chip(
                label: Text(shop.openingHours!),
                avatar: const Icon(Icons.storefront_outlined),
              ),
          ],
        ),
        const SizedBox(height: 18),
        TextField(
          controller: searchController,
          onChanged: (_) => onSearchChanged(),
          decoration: const InputDecoration(
            hintText: 'Search within shop',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 18),
        productsAsync.when(
          data: (products) {
            final filteredProducts = products.where((product) {
              final query = searchController.text.trim().toLowerCase();
              final matchesQuery =
                  query.isEmpty ||
                  product.name.toLowerCase().contains(query) ||
                  product.description.toLowerCase().contains(query);
              final matchesCategory =
                  selectedCategory == 'All' ||
                  product.category.label == selectedCategory;
              return matchesQuery && matchesCategory;
            }).toList();
            final categories = [
              'All',
              ...products.map((product) => product.category.label).toSet(),
            ];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories
                        .map(
                          (label) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(label),
                              selected: selectedCategory == label,
                              onSelected: (_) => onCategoryChanged(label),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 18),
                if (products.isEmpty)
                  EmptyStateCard(
                    title: 'No products listed yet',
                    subtitle:
                        'This shop is live, but no items were returned. Pull to refresh or try again in a moment.',
                    icon: Icons.inventory_2_outlined,
                    action: OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  )
                else if (filteredProducts.isEmpty)
                  const EmptyStateCard(
                    title: 'No products match this search',
                    subtitle:
                        'Try another category or search term to explore more items.',
                    icon: Icons.search_off_rounded,
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${filteredProducts.length} item${filteredProducts.length == 1 ? '' : 's'} available',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...filteredProducts.map(
                        (product) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ProductCard(
                            product: product,
                            quantity: cart.quantityFor(product.id),
                            onAdd: () => onAddProduct(product, shop.name),
                            onIncrease: () => onAddProduct(product, shop.name),
                            onDecrease: () => onDecrease(
                              product.id,
                              cart.quantityFor(product.id),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.only(top: 12),
            child: EmptyStateCard(
              title: 'Unable to load products',
              subtitle: error.toString(),
              icon: Icons.error_outline_rounded,
              action: OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
