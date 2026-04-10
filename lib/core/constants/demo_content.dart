import 'package:ghar_bazaar/data/models/address.dart';
import 'package:ghar_bazaar/data/models/app_user.dart';
import 'package:ghar_bazaar/data/models/cart_item.dart';
import 'package:ghar_bazaar/data/models/customer_profile.dart';
import 'package:ghar_bazaar/data/models/enums.dart';
import 'package:ghar_bazaar/data/models/order_model.dart';
import 'package:ghar_bazaar/data/models/product.dart';
import 'package:ghar_bazaar/data/models/shop.dart';
import 'package:ghar_bazaar/data/models/vendor_profile.dart';

class DemoContent {
  const DemoContent._();

  static final now = DateTime.now();

  static final demoUsers = <AppUser>[
    AppUser(
      uid: 'demo_customer',
      email: 'customer.sample@gharbazaar.app',
      name: 'Aarav Mehta',
      role: UserRole.customer,
      phone: '9876543210',
      isOnboarded: true,
      createdAt: now,
    ),
    AppUser(
      uid: 'demo_vendor',
      email: 'vendor.sample@gharbazaar.app',
      name: 'Priya Storefront',
      role: UserRole.vendor,
      phone: '9988776655',
      isOnboarded: true,
      createdAt: now,
    ),
  ];

  static final demoCustomerProfile = CustomerProfile(
    uid: 'demo_customer',
    fullName: 'Aarav Mehta',
    phoneNumber: '9876543210',
    locality: 'Model Town',
    addressLine: '24 Park View Apartments',
    landmark: 'Near Community Hall',
  );

  static final demoVendorProfile = VendorProfile(
    uid: 'demo_vendor',
    ownerName: 'Priya Sharma',
    phoneNumber: '9988776655',
    shopName: 'Fresh Basket Market',
    shopDescription:
        'Daily essentials, fresh produce, snacks, and dairy sourced from nearby wholesalers.',
    locality: 'Model Town',
    shopAddress: '12 Market Road, Model Town',
    deliveryRadiusKm: 4,
    shopImageUrl:
        'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=800&q=80',
  );

  static final shops = <Shop>[
    Shop(
      id: 'shop_fresh_basket',
      vendorId: 'demo_vendor',
      name: 'Fresh Basket Market',
      description:
          'Fresh fruits, vegetables, staples, and breakfast essentials delivered in under 40 minutes.',
      imageUrl:
          'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=900&q=80',
      coverImageUrl:
          'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=1200&q=80',
      locality: 'Model Town',
      address: '12 Market Road, Model Town',
      deliveryEstimate: '30-40 mins',
      contactNumber: '9988776655',
      openingHours: '7:00 AM - 10:00 PM',
      rating: 4.7,
      categories: const [
        'Fruits & Vegetables',
        'Dairy & Bread',
        'Beverages',
        'Ration & Staples',
      ],
    ),
    Shop(
      id: 'shop_green_leaf',
      vendorId: 'vendor_green_leaf',
      name: 'Green Leaf Grocers',
      description:
          'Trusted neighborhood kirana with premium greens, snacks, and household needs.',
      imageUrl:
          'https://images.unsplash.com/photo-1579113800032-c38bd7635818?auto=format&fit=crop&w=900&q=80',
      coverImageUrl:
          'https://images.unsplash.com/photo-1488459716781-31db52582fe9?auto=format&fit=crop&w=1200&q=80',
      locality: 'Model Town',
      address: '8 Residency Lane, Model Town',
      deliveryEstimate: '25-35 mins',
      contactNumber: '9870011223',
      openingHours: '8:00 AM - 11:00 PM',
      rating: 4.5,
      categories: const [
        'Chips & Snacks',
        'Biscuits',
        'Home Essentials',
        'Personal Care',
      ],
    ),
    Shop(
      id: 'shop_daily_needs',
      vendorId: 'vendor_daily_needs',
      name: 'Daily Needs Corner',
      description:
          'Budget-friendly staples, dairy, frozen items, and cleaning supplies for family shopping.',
      imageUrl:
          'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?auto=format&fit=crop&w=900&q=80',
      coverImageUrl:
          'https://images.unsplash.com/photo-1608686207856-001b95cf60ca?auto=format&fit=crop&w=1200&q=80',
      locality: 'Civil Lines',
      address: '44 Station Road, Civil Lines',
      deliveryEstimate: '35-45 mins',
      contactNumber: '9810011223',
      openingHours: '7:30 AM - 9:30 PM',
      rating: 4.4,
      categories: const [
        'Frozen Food',
        'Cleaning Supplies',
        'Instant Food',
        'Baby Care',
      ],
    ),
  ];

  static final products = <Product>[
    Product(
      id: 'prod_tomato',
      vendorId: 'demo_vendor',
      shopId: 'shop_fresh_basket',
      name: 'Farm Fresh Tomatoes',
      description: 'Bright red handpicked tomatoes for daily cooking.',
      imageUrl:
          'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=800&q=80',
      category: ProductCategory.fruitsVegetables,
      price: 38,
      discountPercent: 8,
      stock: 40,
      unit: 'kg',
      locality: 'Model Town',
      isAvailable: true,
      createdAt: now,
    ),
    Product(
      id: 'prod_banana',
      vendorId: 'demo_vendor',
      shopId: 'shop_fresh_basket',
      name: 'Robusta Bananas',
      description: 'Sweet ripe bananas perfect for breakfast or smoothies.',
      imageUrl:
          'https://images.unsplash.com/photo-1574226516831-e1dff420e12f?auto=format&fit=crop&w=800&q=80',
      category: ProductCategory.fruitsVegetables,
      price: 52,
      discountPercent: 12,
      stock: 25,
      unit: 'dozen',
      locality: 'Model Town',
      isAvailable: true,
      createdAt: now,
    ),
    Product(
      id: 'prod_milk',
      vendorId: 'demo_vendor',
      shopId: 'shop_fresh_basket',
      name: 'Full Cream Milk',
      description: '1 litre pouch, chilled and delivered fresh.',
      imageUrl:
          'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=800&q=80',
      category: ProductCategory.dairyBread,
      price: 64,
      discountPercent: 5,
      stock: 60,
      unit: 'litre',
      locality: 'Model Town',
      isAvailable: true,
      createdAt: now,
    ),
    Product(
      id: 'prod_bread',
      vendorId: 'demo_vendor',
      shopId: 'shop_fresh_basket',
      name: 'Whole Wheat Bread',
      description: 'Soft sliced loaf baked this morning.',
      imageUrl:
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80',
      category: ProductCategory.dairyBread,
      price: 42,
      discountPercent: 10,
      stock: 18,
      unit: 'pack',
      locality: 'Model Town',
      isAvailable: true,
      createdAt: now,
    ),
    Product(
      id: 'prod_rice',
      vendorId: 'demo_vendor',
      shopId: 'shop_fresh_basket',
      name: 'Premium Basmati Rice',
      description: 'Aromatic aged rice suitable for biryani and pulao.',
      imageUrl:
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=800&q=80',
      category: ProductCategory.rationStaples,
      price: 399,
      discountPercent: 15,
      stock: 12,
      unit: '5 kg',
      locality: 'Model Town',
      isAvailable: true,
      createdAt: now,
    ),
    Product(
      id: 'prod_juice',
      vendorId: 'demo_vendor',
      shopId: 'shop_fresh_basket',
      name: 'Orange Juice',
      description: 'Refreshing family pack beverage.',
      imageUrl:
          'https://images.unsplash.com/photo-1600271886742-f049cd5bba3f?auto=format&fit=crop&w=800&q=80',
      category: ProductCategory.beverages,
      price: 110,
      discountPercent: 9,
      stock: 16,
      unit: 'litre',
      locality: 'Model Town',
      isAvailable: true,
      createdAt: now,
    ),
    Product(
      id: 'prod_chips',
      vendorId: 'vendor_green_leaf',
      shopId: 'shop_green_leaf',
      name: 'Masala Potato Chips',
      description: 'Crunchy family pack with a spicy tangy kick.',
      imageUrl:
          'https://images.unsplash.com/photo-1566478989037-eec170784d0b?auto=format&fit=crop&w=800&q=80',
      category: ProductCategory.chipsSnacks,
      price: 45,
      discountPercent: 5,
      stock: 34,
      unit: 'pack',
      locality: 'Model Town',
      isAvailable: true,
      createdAt: now,
    ),
    Product(
      id: 'prod_biscuit',
      vendorId: 'vendor_green_leaf',
      shopId: 'shop_green_leaf',
      name: 'Butter Cookies',
      description: 'Melt-in-mouth tea-time favorite.',
      imageUrl:
          'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?auto=format&fit=crop&w=800&q=80',
      category: ProductCategory.biscuits,
      price: 60,
      discountPercent: 14,
      stock: 20,
      unit: 'box',
      locality: 'Model Town',
      isAvailable: true,
      createdAt: now,
    ),
    Product(
      id: 'prod_detergent',
      vendorId: 'vendor_green_leaf',
      shopId: 'shop_green_leaf',
      name: 'Detergent Powder',
      description: 'Powerful cleaning for everyday laundry loads.',
      imageUrl:
          'https://images.unsplash.com/photo-1610552050890-fe99536c2614?auto=format&fit=crop&w=800&q=80',
      category: ProductCategory.homeEssentials,
      price: 189,
      discountPercent: 18,
      stock: 14,
      unit: '2 kg',
      locality: 'Model Town',
      isAvailable: true,
      createdAt: now,
    ),
    Product(
      id: 'prod_shampoo',
      vendorId: 'vendor_green_leaf',
      shopId: 'shop_green_leaf',
      name: 'Herbal Shampoo',
      description: 'Daily-use shampoo with a clean floral fragrance.',
      imageUrl:
          'https://images.unsplash.com/photo-1626806787461-102c1a4156f9?auto=format&fit=crop&w=800&q=80',
      category: ProductCategory.personalCare,
      price: 220,
      discountPercent: 11,
      stock: 10,
      unit: 'bottle',
      locality: 'Model Town',
      isAvailable: true,
      createdAt: now,
    ),
    Product(
      id: 'prod_frozen_peas',
      vendorId: 'vendor_daily_needs',
      shopId: 'shop_daily_needs',
      name: 'Frozen Green Peas',
      description: 'Quick-cook peas kept frozen for freshness.',
      imageUrl:
          'https://images.unsplash.com/photo-1615486363973-1f08f8586495?auto=format&fit=crop&w=800&q=80',
      category: ProductCategory.frozenFood,
      price: 95,
      discountPercent: 6,
      stock: 18,
      unit: 'pack',
      locality: 'Civil Lines',
      isAvailable: true,
      createdAt: now,
    ),
    Product(
      id: 'prod_cleaner',
      vendorId: 'vendor_daily_needs',
      shopId: 'shop_daily_needs',
      name: 'Floor Cleaner',
      description: 'Citrus floor cleaner for a fresh-smelling home.',
      imageUrl:
          'https://images.unsplash.com/photo-1583947582886-f40ec95dd752?auto=format&fit=crop&w=800&q=80',
      category: ProductCategory.cleaningSupplies,
      price: 155,
      discountPercent: 10,
      stock: 22,
      unit: 'bottle',
      locality: 'Civil Lines',
      isAvailable: true,
      createdAt: now,
    ),
    Product(
      id: 'prod_noodles',
      vendorId: 'vendor_daily_needs',
      shopId: 'shop_daily_needs',
      name: 'Instant Noodles',
      description: '2-minute comfort meal, classic masala flavor.',
      imageUrl:
          'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?auto=format&fit=crop&w=800&q=80',
      category: ProductCategory.instantFood,
      price: 78,
      discountPercent: 7,
      stock: 55,
      unit: '6 pack',
      locality: 'Civil Lines',
      isAvailable: true,
      createdAt: now,
    ),
    Product(
      id: 'prod_diapers',
      vendorId: 'vendor_daily_needs',
      shopId: 'shop_daily_needs',
      name: 'Baby Diapers',
      description: 'Soft overnight diapers with quick-lock absorption.',
      imageUrl:
          'https://images.unsplash.com/photo-1584362917165-526a968579e8?auto=format&fit=crop&w=800&q=80',
      category: ProductCategory.babyCare,
      price: 499,
      discountPercent: 16,
      stock: 8,
      unit: 'pack',
      locality: 'Civil Lines',
      isAvailable: true,
      createdAt: now,
    ),
  ];

  static Map<String, dynamic> seededDatabase() {
    return {
      'users': demoUsers.map((user) => user.toMap()).toList(),
      'customer_profiles': [demoCustomerProfile.toMap()],
      'vendor_profiles': [demoVendorProfile.toMap()],
      'shops': shops.map((shop) => shop.toMap()).toList(),
      'products': products.map((product) => product.toMap()).toList(),
      'orders': <Map<String, dynamic>>[],
    };
  }

  static OrderModel sampleOrderForPreview() {
    return OrderModel(
      id: 'order_demo_1',
      customerId: 'demo_customer',
      vendorId: 'demo_vendor',
      shopId: 'shop_fresh_basket',
      shopName: 'Fresh Basket Market',
      customerName: 'Aarav Mehta',
      customerPhone: '9876543210',
      locality: 'Model Town',
      deliveryAddress: const Address(
        locality: 'Model Town',
        line1: '24 Park View Apartments',
        landmark: 'Near Community Hall',
      ),
      items: [
        CartItem(product: products.first, quantity: 2),
        CartItem(product: products[2], quantity: 1),
      ],
      subtotal: 140,
      discount: 12,
      deliveryFee: 25,
      total: 153,
      paymentMethod: PaymentMethod.cashOnDelivery,
      status: OrderStatus.placed,
      createdAt: now,
    );
  }
}
