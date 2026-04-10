enum UserRole { customer, vendor, unknown }

extension UserRoleX on UserRole {
  String get value => switch (this) {
    UserRole.customer => 'customer',
    UserRole.vendor => 'vendor',
    UserRole.unknown => 'unknown',
  };

  String get label => switch (this) {
    UserRole.customer => 'Customer',
    UserRole.vendor => 'Vendor',
    UserRole.unknown => 'Choose a role',
  };
}

UserRole userRoleFromValue(String? value) {
  return UserRole.values.firstWhere(
    (role) => role.value == value,
    orElse: () => UserRole.unknown,
  );
}

enum ProductCategory {
  fruitsVegetables,
  dairyBread,
  chocolates,
  chipsSnacks,
  biscuits,
  beverages,
  rationStaples,
  meatFishEgg,
  homeEssentials,
  personalCare,
  cleaningSupplies,
  instantFood,
  babyCare,
  frozenFood,
  others,
}

extension ProductCategoryX on ProductCategory {
  String get label => switch (this) {
    ProductCategory.fruitsVegetables => 'Fruits & Vegetables',
    ProductCategory.dairyBread => 'Dairy & Bread',
    ProductCategory.chocolates => 'Chocolates',
    ProductCategory.chipsSnacks => 'Chips & Snacks',
    ProductCategory.biscuits => 'Biscuits',
    ProductCategory.beverages => 'Beverages',
    ProductCategory.rationStaples => 'Ration & Staples',
    ProductCategory.meatFishEgg => 'Meat / Fish / Egg',
    ProductCategory.homeEssentials => 'Home Essentials',
    ProductCategory.personalCare => 'Personal Care',
    ProductCategory.cleaningSupplies => 'Cleaning Supplies',
    ProductCategory.instantFood => 'Instant Food',
    ProductCategory.babyCare => 'Baby Care',
    ProductCategory.frozenFood => 'Frozen Food',
    ProductCategory.others => 'Others',
  };
}

ProductCategory productCategoryFromValue(String? value) {
  return ProductCategory.values.firstWhere(
    (category) =>
        category.name == value ||
        category.label.toLowerCase() == value?.toLowerCase(),
    orElse: () => ProductCategory.others,
  );
}

enum PaymentMethod { cashOnDelivery, upi, card, wallet }

extension PaymentMethodX on PaymentMethod {
  String get label => switch (this) {
    PaymentMethod.cashOnDelivery => 'Cash on Delivery',
    PaymentMethod.upi => 'UPI',
    PaymentMethod.card => 'Card',
    PaymentMethod.wallet => 'Wallet',
  };

  String get value => name;
}

PaymentMethod paymentMethodFromValue(String? value) {
  return PaymentMethod.values.firstWhere(
    (method) => method.value == value,
    orElse: () => PaymentMethod.cashOnDelivery,
  );
}

enum OrderStatus { placed, accepted, packed, outForDelivery, delivered }

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
    OrderStatus.placed => 'Placed',
    OrderStatus.accepted => 'Accepted',
    OrderStatus.packed => 'Packed',
    OrderStatus.outForDelivery => 'Out for delivery',
    OrderStatus.delivered => 'Delivered',
  };

  String get value => name;
}

OrderStatus orderStatusFromValue(String? value) {
  return OrderStatus.values.firstWhere(
    (status) => status.value == value,
    orElse: () => OrderStatus.placed,
  );
}
