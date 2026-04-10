# Ghar Bazaar

Ghar Bazaar is a hyperlocal grocery marketplace app built with Flutter for Android and iOS. It provides a polished product-focused experience for two roles:

- Customer: browse nearby local shops by locality, discover products, add items to cart, and place orders.
- Vendor: create a local grocery storefront, manage products, and track incoming orders.

The app branding uses `Ghar Bazaar` with the tagline: `Your neighborhood grocery market, now online.`

## Features

- Splash flow with onboarding, auth checks, role selection, and profile completion routing
- Email/password sign in and sign up
- Google Sign-In integration path
- Customer locality selection, nearby shop discovery, categorized product browsing, cart, checkout, and order history
- Vendor dashboard, shop setup, product CRUD, and manual order status updates
- Riverpod state management and GoRouter navigation
- Firebase-backed authentication and Firestore data flow
- ImgBB-based image upload for shops and products

## Setup

1. Install Flutter stable and verify with `flutter doctor`.
2. Run `flutter pub get`.
3. For Firebase-enabled mode, add Android and iOS Firebase config:
   - Android: place `google-services.json` in `android/app/`
   - iOS: place `GoogleService-Info.plist` in `ios/Runner/`
4. Configure Google Sign-In platform setup:
   - Android and iOS still need their platform OAuth setup from the official `google_sign_in` package docs.
5. Add your ImgBB API key in `lib/core/constants/app_secrets.dart`.
6. Run the app with `flutter run`.
7. Create Firebase Auth users normally from the app or Firebase Console.

## Project Structure

```text
lib/
  app/
  core/
    constants/
    services/
    utils/
    widgets/
  data/
    models/
    repositories/
    sources/
  features/
    auth/
    customer/
    onboarding/
    profile/
    splash/
    vendor/
```

## Firebase Collections Schema

`users/{uid}`
- `uid`
- `email`
- `name`
- `role`
- `photoUrl`
- `phone`
- `isOnboarded`
- `createdAt`

`customer_profiles/{uid}`
- `uid`
- `fullName`
- `phoneNumber`
- `locality`
- `addressLine`
- `landmark`

`vendor_profiles/{uid}`
- `uid`
- `ownerName`
- `phoneNumber`
- `shopName`
- `shopDescription`
- `locality`
- `shopAddress`
- `deliveryRadiusKm`
- `shopImageUrl`

`shops/{shopId}`
- `id`
- `vendorId`
- `name`
- `description`
- `imageUrl`
- `coverImageUrl`
- `locality`
- `address`
- `deliveryEstimate`
- `contactNumber`
- `openingHours`
- `rating`
- `categories`

`products/{productId}`
- `id`
- `vendorId`
- `shopId`
- `name`
- `description`
- `imageUrl`
- `category`
- `price`
- `discountPercent`
- `finalPrice`
- `stock`
- `unit`
- `locality`
- `isAvailable`
- `createdAt`

`orders/{orderId}`
- `id`
- `customerId`
- `vendorId`
- `shopId`
- `shopName`
- `customerName`
- `customerPhone`
- `locality`
- `deliveryAddress`
- `items`
- `subtotal`
- `discount`
- `deliveryFee`
- `total`
- `paymentMethod`
- `status`
- `createdAt`

## Assumptions

- The app targets Android and iOS only.
- Payments are currently mocked in the checkout flow.
- Delivery partners are mentioned in trust/onboarding messaging only.
- Firebase Auth and Firestore are expected to be configured for sign-in and profile flows.
- Product and shop images upload to ImgBB and only the returned image URL is stored.

## Future Improvements

- Add real geolocation and locality search
- Add push notifications and live order tracking
- Add customer favorites, coupons, and real delivery fees
- Add vendor analytics and low-stock alerts
- Add stronger Firestore security rules and role-based enforcement
