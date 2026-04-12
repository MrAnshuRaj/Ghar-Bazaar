# Ghar Bazaar

Ghar Bazaar is a Flutter marketplace app for hyperlocal grocery shopping. It supports two roles:

- Customer: browse nearby shops, search products, manage a cart, and place orders.
- Vendor: create a shop, upload product listings, and track incoming orders.

The app can run in two storage modes:

- Firebase mode: uses Firebase Auth and Cloud Firestore when Firebase initializes successfully.
- Local fallback mode: uses a SharedPreferences-backed JSON store plus seeded demo data when Firebase is unavailable.

## What The App Is Built With

- Flutter + Material 3 for UI
- Riverpod for dependency injection and state management
- GoRouter for navigation and role-aware redirects
- Firebase Auth for authentication
- Cloud Firestore for shared marketplace data
- SharedPreferences for onboarding flags, cart persistence, selected locality, and local fallback data
- ImgBB for image uploads, with local file fallback when remote upload is unavailable in local mode

## How The Architecture Works

This codebase follows a practical layered Flutter structure instead of a strict clean-architecture setup.

### 1. App shell

- `lib/main.dart` initializes Flutter, SharedPreferences, and Firebase.
- `lib/app/app.dart` builds the root `MaterialApp.router`.
- `lib/app/router.dart` owns route definitions and redirect rules.

### 2. Shared core layer

- `lib/core/constants/` holds branding, demo seed data, and secret placeholders.
- `lib/core/services/` contains startup, preferences, and image upload services.
- `lib/core/utils/` centralizes formatting, validation, navigation, and snackbar helpers.
- `lib/core/widgets/` contains reusable UI widgets shared across features.

### 3. Data layer

- `lib/data/models/` defines app entities such as `Shop`, `Product`, `OrderModel`, and profiles.
- `lib/data/repositories/` provides app-facing data APIs.
- `lib/data/sources/` contains the actual persistence implementations.
- `lib/data/providers.dart` wires repositories, providers, and controllers together.

### 4. Feature layer

- `lib/features/onboarding/` handles first-run onboarding.
- `lib/features/auth/` handles sign in, sign up, and password reset.
- `lib/features/profile/` handles role selection and profile completion.
- `lib/features/customer/` contains the shopper-facing flow.
- `lib/features/vendor/` contains the seller-facing flow.
- `lib/features/splash/` resolves the startup route.

### 5. Runtime flow

1. `main.dart` calls `AppBootstrap.initialize()`.
2. `AppBootstrap` checks whether Firebase can initialize and creates `AppPreferences`.
3. `ProviderScope` injects the bootstrap result into Riverpod.
4. `providers.dart` chooses `FirebaseMarketplaceDataSource` or `LocalMarketplaceDataSource`.
5. `router.dart` inspects onboarding state, auth state, selected role, and completed profile state.
6. Screens call Riverpod providers and repositories.
7. Repositories delegate to the selected data source.

### Architectural notes

- There is no separate domain layer; business logic lives mainly in providers, repositories, and feature screens.
- `MarketplaceRepository` is intentionally thin. The main storage switch happens at the `MarketplaceDataSource` abstraction.
- Customer cart state is local-only and persisted through `SharedPreferences`.
- Demo seed data powers the local mode and also seeds Firestore if the remote database is empty.
- Image upload is resilient: it prefers ImgBB, but local mode can fall back to copied local files.

## Main User Journeys

### Startup and access control

- Splash screen resolves the next route.
- Onboarding must be completed first.
- Unauthenticated users go to sign-in.
- Authenticated users without a role go to role selection.
- Role selection sends users into customer-profile or vendor-profile completion.
- Completed customer accounts land on `/customer/home`.
- Completed vendor accounts land on `/vendor/home`.

### Customer flow

- Select locality
- Browse nearby shops
- Search and filter products inside a shop
- Add items to a single-shop cart
- Checkout with mocked payment choices
- View past orders and account info

### Vendor flow

- Create vendor profile
- Create a shop
- Add or edit products
- Review incoming orders
- Manually update order status

## Firebase Data Model

The app code maps these Firestore collections to Dart models:

- `users/{uid}` -> `AppUser`
- `customer_profiles/{uid}` -> `CustomerProfile`
- `vendor_profiles/{uid}` -> `VendorProfile`
- `shops/{shopId}` -> `Shop`
- `products/{productId}` -> `Product`
- `orders/{orderId}` -> `OrderModel`

Important behavior:

- Product category labels stored in products are synced back into each shop's `categories` list.
- Orders embed address and cart-item snapshots so history remains stable after product edits.
- Product parsing is defensive so malformed payloads do not crash the UI.

## Setup

1. Install Flutter stable and verify with `flutter doctor`.
2. Run `flutter pub get`.
3. For Firebase mode, add:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
4. Configure Google Sign-In for Android and iOS.
5. Set `imgbbApiKey` in `lib/core/constants/app_secrets.dart` if you want shared remote image URLs.
6. Run the app with `flutter run`.

## File Map

This section documents the tracked repository files. Generated local folders such as `.dart_tool/`, `.idea/`, and the top-level `build/` directory are intentionally not listed file-by-file because they are machine-generated, not source architecture.

### Root

```text
.gitignore                                          - Root ignore rules for Flutter, Dart, IDE files, build output, and Firebase config secrets.
.metadata                                           - Flutter tool metadata used for migrations and SDK upgrade tracking.
.vscode/settings.json                               - Workspace-level VS Code Java build configuration setting.
README.md                                           - Project documentation, architecture notes, and annotated file map.
analysis_options.yaml                               - Static analysis configuration; currently inherits the default Flutter lint set.
pubspec.yaml                                        - Package manifest with dependencies, app version, launcher icon config, and Flutter asset settings.
pubspec.lock                                        - Resolved dependency lockfile for reproducible installs.
assets/ghar_bazaar_logo.png                         - Branding image used for launcher icon generation and project identity.
```

### Flutter App Source

```text
lib/main.dart                                       - App entry point; logs missing ImgBB setup, initializes bootstrap services, and starts Riverpod.

lib/app/app.dart                                    - Root widget that creates `MaterialApp.router` with app title, theme, and router config.
lib/app/router.dart                                 - Central route table plus redirect logic for onboarding, auth, role selection, and profile completion.
lib/app/theme/app_theme.dart                        - Material 3 theme definition, color scheme, typography, button styles, input styles, and navigation styling.

lib/core/constants/app_constants.dart               - Shared brand constants such as app name, tagline, support email, and default localities.
lib/core/constants/app_secrets.dart                 - ImgBB API key placeholder and helper flags/messages for image-upload configuration state.
lib/core/constants/demo_content.dart                - Demo users, profiles, shops, products, seeded database payload, and sample order used by fallback/demo flows.

lib/core/services/app_bootstrap.dart                - Startup service that ensures Flutter binding, opens SharedPreferences, and attempts Firebase initialization.
lib/core/services/app_preferences.dart              - Wrapper around SharedPreferences for onboarding state, cart JSON, locality selection, and local DB persistence.
lib/core/services/image_upload_service.dart         - Image picker plus upload pipeline that sends images to ImgBB or copies them locally as a fallback.

lib/core/utils/app_feedback.dart                    - Shared snackbar helper for success/error feedback.
lib/core/utils/formatters.dart                      - Currency and date/time formatting helpers for Indian locale UI output.
lib/core/utils/navigation.dart                      - Startup route resolver used by splash and auth screens.
lib/core/utils/validators.dart                      - Shared form validation helpers for required values, email, password, phone, and numeric input.

lib/core/widgets/app_logo.dart                      - Branded logo widget with icon, gradient, title, and optional tagline.
lib/core/widgets/app_primary_button.dart            - Reusable primary action button with loading state support.
lib/core/widgets/app_text_field.dart                - Standardized `TextFormField` wrapper used across forms.
lib/core/widgets/async_value_widget.dart            - Convenience widget for rendering Riverpod `AsyncValue` loading, error, and success states.
lib/core/widgets/empty_state_card.dart              - Reusable empty-state card with icon, title, subtitle, and optional action.
lib/core/widgets/marketplace_image.dart             - Safe image renderer for remote URLs and local file paths with graceful placeholders.
lib/core/widgets/order_status_chip.dart             - Colored pill widget for displaying order status labels.
lib/core/widgets/product_card.dart                  - Shared product list card with price display, stock details, quantity controls, and defensive rendering.
lib/core/widgets/section_header.dart                - Section heading widget with title, subtitle, and optional trailing action.
lib/core/widgets/shop_card.dart                     - Shop summary card used on the customer home screen.

lib/data/models/address.dart                        - Address value object embedded inside orders.
lib/data/models/app_user.dart                       - App-level user profile model stored in the `users` collection.
lib/data/models/auth_session.dart                   - Lightweight auth session model derived from Firebase auth state.
lib/data/models/cart_item.dart                      - Cart line item combining a product snapshot with quantity and price helpers.
lib/data/models/cart_state.dart                     - Entire cart aggregate with totals, delivery fee rules, serialization, and quantity helpers.
lib/data/models/customer_profile.dart               - Customer delivery profile model.
lib/data/models/enums.dart                          - Enums and helpers for user role, product category, payment method, and order status.
lib/data/models/order_model.dart                    - Order aggregate including address, line items, totals, payment method, and status.
lib/data/models/product.dart                        - Product model with defensive parsing for inconsistent Firestore/local payloads.
lib/data/models/shop.dart                           - Shop/storefront model for vendor listings.
lib/data/models/vendor_profile.dart                 - Vendor onboarding profile model.

lib/data/providers.dart                             - Riverpod dependency graph: bootstrap, repositories, data-source selection, app initialization, queries, and controllers.
lib/data/repositories/auth_repository.dart          - Firebase-auth wrapper for sign-up, sign-in, Google sign-in, password reset, and sign-out.
lib/data/repositories/marketplace_repository.dart   - Thin repository that forwards marketplace operations to the selected data source.

lib/data/sources/marketplace_data_source.dart       - Abstract marketplace storage contract used by the repository.
lib/data/sources/firebase/firebase_marketplace_data_source.dart
                                                   - Firestore-backed marketplace implementation with seeding, live streams, category syncing, retries, and friendly data errors.
lib/data/sources/local/local_database.dart          - SharedPreferences-backed JSON database helper used in local fallback mode.
lib/data/sources/local/local_marketplace_data_source.dart
                                                   - Local marketplace implementation that reads/writes collections from the JSON database and emits change streams.

lib/features/auth/presentation/forgot_password_screen.dart
                                                   - Password reset form that triggers `sendPasswordResetEmail`.
lib/features/auth/presentation/sign_in_screen.dart  - Email/password and Google sign-in screen; routes users after auth succeeds.
lib/features/auth/presentation/sign_up_screen.dart  - Email/password registration screen for new accounts.

lib/features/onboarding/presentation/onboarding_screen.dart
                                                   - Multi-page first-run onboarding flow that marks onboarding complete in preferences.

lib/features/profile/presentation/role_selection_screen.dart
                                                   - Role chooser that saves `customer` or `vendor` on the user record.
lib/features/profile/presentation/customer_profile_form_screen.dart
                                                   - Customer profile form for name, phone, locality, and delivery address.
lib/features/profile/presentation/vendor_profile_form_screen.dart
                                                   - Vendor profile form for owner details, shop summary, locality, address, and delivery radius.

lib/features/splash/presentation/splash_screen.dart - Initial loading screen that resolves the correct startup route.

lib/features/customer/presentation/customer_home_screen.dart
                                                   - Customer dashboard with greeting, locality picker, search, category filters, and nearby shop list.
lib/features/customer/presentation/shop_detail_screen.dart
                                                   - Shop detail page with cover image, category/search filtering, product list, cart enforcement, refresh, and error feedback.
lib/features/customer/presentation/cart_screen.dart - Cart view with quantity controls, bill summary, and checkout action.
lib/features/customer/presentation/checkout_screen.dart
                                                   - Checkout flow that shows address, payment options, order summary, and creates orders.
lib/features/customer/presentation/customer_orders_screen.dart
                                                   - Customer order history screen with timestamps, totals, payment method, and order status.
lib/features/customer/presentation/customer_account_screen.dart
                                                   - Customer account screen with profile summary, address, recent orders, and logout.
lib/features/customer/presentation/order_success_screen.dart
                                                   - Post-checkout confirmation screen shown after an order is created.
lib/features/customer/presentation/widgets/customer_bottom_nav.dart
                                                   - Bottom navigation bar for the customer role.

lib/features/vendor/presentation/vendor_home_screen.dart
                                                   - Vendor dashboard with shop summary, quick stats, and shortcuts to manage listings.
lib/features/vendor/presentation/vendor_products_screen.dart
                                                   - Vendor product management screen with category grouping, edit, delete, and add actions.
lib/features/vendor/presentation/product_form_screen.dart
                                                   - Product create/edit form with image upload, category selection, pricing, stock, and availability toggle.
lib/features/vendor/presentation/vendor_orders_screen.dart
                                                   - Vendor order inbox with status controls for each order.
lib/features/vendor/presentation/vendor_account_screen.dart
                                                   - Vendor account page with profile summary, shop summary, and logout.
lib/features/vendor/presentation/shop_form_screen.dart
                                                   - Shop create/edit form with image upload and storefront details.
lib/features/vendor/presentation/widgets/vendor_bottom_nav.dart
                                                   - Bottom navigation bar for the vendor role.
```

### Tests

```text
test/shop_detail_screen_malformed_products_test.dart
                                                   - Widget test that ensures `ShopDetailScreen` still renders when product payloads are malformed or partially inconsistent.
```

### Android

```text
android/.gitignore                                  - Android-specific ignore rules for Gradle caches, local properties, generated plugin registrants, and keystores.
android/build.gradle.kts                            - Root Android Gradle configuration and shared build-directory setup.
android/settings.gradle.kts                         - Android Gradle settings, Flutter tool plugin loader, and plugin version declarations.
android/gradle.properties                           - Gradle JVM and AndroidX build settings.
android/gradle/wrapper/gradle-wrapper.properties    - Pins the Gradle wrapper distribution version.
android/build/reports/problems/problems-report.html - Generated Gradle problems report currently checked into the repository.

android/app/build.gradle.kts                        - Android app module configuration, package namespace, SDK settings, and Google services plugin setup.
android/app/src/main/AndroidManifest.xml            - Main Android app manifest defining app label, launcher activity, and Flutter embedding metadata.
android/app/src/debug/AndroidManifest.xml           - Debug-only manifest adding internet permission for development tooling.
android/app/src/profile/AndroidManifest.xml         - Profile-only manifest adding internet permission for profiling builds.
android/app/src/main/java/com/anshu/gharbazaar/MainActivity.java
                                                    - Native Android entry activity extending `FlutterActivity`.

android/app/src/main/res/drawable/launch_background.xml
                                                    - Default launch background definition for older Android splash startup.
android/app/src/main/res/drawable-v21/launch_background.xml
                                                    - API 21+ launch background definition that uses theme background color.
android/app/src/main/res/values/styles.xml          - Light-theme Android launch and normal window styles.
android/app/src/main/res/values-night/styles.xml    - Dark-theme Android launch and normal window styles.

android/app/src/main/res/mipmap-mdpi/ic_launcher.png
                                                    - Android launcher icon asset for mdpi density.
android/app/src/main/res/mipmap-hdpi/ic_launcher.png
                                                    - Android launcher icon asset for hdpi density.
android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
                                                    - Android launcher icon asset for xhdpi density.
android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
                                                    - Android launcher icon asset for xxhdpi density.
android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
                                                    - Android launcher icon asset for xxxhdpi density.
```

### iOS

```text
ios/.gitignore                                      - iOS/Xcode ignore rules for Pods, DerivedData, generated Flutter artifacts, and user state.
ios/Flutter/AppFrameworkInfo.plist                  - Metadata plist for the embedded Flutter iOS framework.
ios/Flutter/Debug.xcconfig                          - Debug iOS build config that includes generated Flutter settings.
ios/Flutter/Release.xcconfig                        - Release iOS build config that includes generated Flutter settings.

ios/Runner.xcodeproj/project.pbxproj                - Main Xcode project definition with targets, build settings, and file references.
ios/Runner.xcodeproj/project.xcworkspace/contents.xcworkspacedata
                                                    - Xcode project workspace metadata.
ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist
                                                    - Shared Xcode workspace safety/check settings.
ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings
                                                    - Shared Xcode workspace preferences, including SwiftUI preview settings.
ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme
                                                    - Shared Xcode scheme for running, testing, profiling, and archiving the app.

ios/Runner.xcworkspace/contents.xcworkspacedata     - Top-level Xcode workspace metadata pointing at `Runner.xcodeproj`.
ios/Runner.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist
                                                    - Shared workspace check settings for the app workspace.
ios/Runner.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings
                                                    - Shared workspace preferences for the app workspace.

ios/Runner/AppDelegate.swift                        - iOS app delegate that boots Flutter and registers plugins for the implicit engine.
ios/Runner/SceneDelegate.swift                      - iOS scene delegate extending `FlutterSceneDelegate`.
ios/Runner/Runner-Bridging-Header.h                 - Objective-C bridging header exposing generated plugin registration to Swift.
ios/Runner/Info.plist                               - iOS app metadata including display name and photo-library permission strings.
ios/Runner/Base.lproj/Main.storyboard               - Main iOS storyboard hosting the root `FlutterViewController`.
ios/Runner/Base.lproj/LaunchScreen.storyboard       - iOS launch screen storyboard that displays the launch image.

ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json
                                                    - iOS asset-catalog manifest describing all app icon variants.
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png
                                                    - iOS app icon asset for 20x20 at 1x.
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png
                                                    - iOS app icon asset for 20x20 at 2x.
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png
                                                    - iOS app icon asset for 20x20 at 3x.
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png
                                                    - iOS app icon asset for 29x29 at 1x.
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png
                                                    - iOS app icon asset for 29x29 at 2x.
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png
                                                    - iOS app icon asset for 29x29 at 3x.
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png
                                                    - iOS app icon asset for 40x40 at 1x.
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png
                                                    - iOS app icon asset for 40x40 at 2x.
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png
                                                    - iOS app icon asset for 40x40 at 3x.
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-50x50@1x.png
                                                    - iOS app icon asset for 50x50 at 1x.
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-50x50@2x.png
                                                    - iOS app icon asset for 50x50 at 2x.
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-57x57@1x.png
                                                    - iOS app icon asset for 57x57 at 1x.
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-57x57@2x.png
                                                    - iOS app icon asset for 57x57 at 2x.
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png
                                                    - iOS app icon asset for 60x60 at 2x.
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png
                                                    - iOS app icon asset for 60x60 at 3x.
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-72x72@1x.png
                                                    - iOS app icon asset for 72x72 at 1x.
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-72x72@2x.png
                                                    - iOS app icon asset for 72x72 at 2x.
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png
                                                    - iOS app icon asset for 76x76 at 1x.
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png
                                                    - iOS app icon asset for 76x76 at 2x.
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png
                                                    - iOS app icon asset for 83.5x83.5 at 2x.
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
                                                    - iOS App Store marketing icon asset.

ios/Runner/Assets.xcassets/LaunchImage.imageset/Contents.json
                                                    - Asset-catalog manifest for launch images.
ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png
                                                    - Base launch image asset.
ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png
                                                    - 2x launch image asset.
ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png
                                                    - 3x launch image asset.
ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md
                                                    - Default Flutter note explaining how launch images work in the asset set.

ios/RunnerTests/RunnerTests.swift                   - Placeholder iOS unit-test target file.
```

## Generated And Local-Only Folders You Will Also See

These folders may exist in a working copy but are not core source architecture:

- `.dart_tool/` - Flutter and Dart build/tool cache.
- `.idea/` - IntelliJ/Android Studio project metadata.
- `build/` - Top-level generated build output.
- `android/app/debug`, `android/app/profile`, `android/app/release` - Generated Android build artifacts.

## Notes For Contributors

- `lib/data/providers.dart` is the best first file to read if you want to understand the app's dependency graph.
- `lib/app/router.dart` is the best first file to read if you want to understand navigation and access control.
- `lib/data/sources/firebase/firebase_marketplace_data_source.dart` and `lib/data/sources/local/local_marketplace_data_source.dart` are the best pair to read if you want to understand how the same feature set works in both remote and fallback modes.
- `lib/features/customer/presentation/shop_detail_screen.dart` is the most defensive customer UI file and is covered by the current widget test.
