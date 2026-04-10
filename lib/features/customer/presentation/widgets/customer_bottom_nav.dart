import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomerBottomNav extends StatelessWidget {
  const CustomerBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/customer/home');
          case 1:
            context.go('/customer/cart');
          case 2:
            context.go('/customer/account');
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Account',
        ),
      ],
    );
  }
}
