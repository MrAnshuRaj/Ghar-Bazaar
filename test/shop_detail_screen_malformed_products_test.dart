import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghar_bazaar/data/models/cart_state.dart';
import 'package:ghar_bazaar/data/models/product.dart';
import 'package:ghar_bazaar/data/models/shop.dart';
import 'package:ghar_bazaar/data/providers.dart';
import 'package:ghar_bazaar/features/customer/presentation/shop_detail_screen.dart';

class _FakeCartController extends CartController {
  @override
  CartState build() => const CartState();
}

void main() {
  testWidgets(
    'ShopDetailScreen renders product cards with malformed product payloads',
    (tester) async {
      final malformedProducts = <Product>[
        Product.fromMap({
          'id': 'p-1',
          'vendorId': 'v-1',
          'shopId': 'shop-1',
          'name': 'Choco Pack',
          'description': 'Tasty chocolate mix',
          'imageUrl': '\u0000bad-image-path',
          'category': 'unknown_category',
          'price': '120.5',
          'discount': '10',
          'stock': '5',
          'unit': 'pack',
          'isAvailable': 'true',
          'createdAt': '1700000000000',
        }),
        Product.fromMap({
          'id': 'p-2',
          'vendorId': 'v-1',
          'shopId': 'shop-1',
          'name': 'Chips',
          'description': null,
          'imageUrl': '',
          'category': 'chipsSnacks',
          'price': 80,
          'discountPercent': double.nan,
          'stock': '2',
          'unit': 'pcs',
          'isAvailable': 1,
          'createdAt': 1700000001000,
        }),
      ];

      final shop = Shop(
        id: 'shop-1',
        vendorId: 'v-1',
        name: 'Amit Kirana',
        description: 'Daily needs',
        imageUrl: '',
        locality: 'Civil Lines',
        address: '123 Market Road',
        deliveryEstimate: '30-40 mins',
        contactNumber: '9999999999',
        categories: const [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            shopProductsProvider.overrideWith(
              (ref, shopId) => Stream.value(malformedProducts),
            ),
            cartControllerProvider.overrideWith(_FakeCartController.new),
          ],
          child: MaterialApp(
            home: ShopDetailScreen(shopId: 'shop-1', initialShop: shop),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('2 items available'), findsOneWidget);
      expect(find.text('Choco Pack'), findsOneWidget);
      expect(find.text('Chips'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsWidgets);
      expect(find.text('Others'), findsOneWidget);
    },
  );
}
