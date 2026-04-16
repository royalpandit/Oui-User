# OUI User App

<p align="left">
	<img src="assets/icons/Logo.png" alt="OUI Logo" width="120" />
</p>

OUI User App is a Flutter-based fashion and lifestyle eCommerce mobile application focused on premium shopping, variant-rich product discovery, and smooth checkout. The app includes modern commerce features like virtual try-on, wishlist, coupons, shipping calculation, order tracking, and integrated payment options.

## What This App Provides

- Full eCommerce user journey from browsing to order tracking
- Product variants with correct color, size, price, and image mapping
- Virtual Try-On experience for selected products
- Cart and checkout with coupon and shipping flows
- Order management and order details
- User account management with addresses and profile editing
- Search, category browsing, flash deals, and seller exploration
- Notifications and inbox modules
- Crash reporting support via Firebase Crashlytics (configured in app bootstrap)

## Key Business Features

### Shopping and Product Discovery
- Home feed with collections, offers, and featured products
- Category, sub-category, and seller-based browsing
- Search with product discovery support
- Product details with gallery, variants, and reviews

### Variant-Driven Commerce
- Variant-specific pricing
- Variant-specific product image selection
- Color/size persistence across product, cart, checkout, and orders
- Color name with visual swatch rendering

### Virtual Try-On
- Try-on module with camera/gallery based user flow
- Device permissions and media integrations
- Try-on result and gallery handling for user interaction

### Checkout and Orders
- Cart quantity and line-item calculations
- Coupon application and total recalculation
- Shipping method selection and delivery cost handling
- Place order flow with address validation
- Order list and detailed order view

### Profile and Utilities
- Address management
- Wishlist management
- Notifications and inbox sections
- App settings and informational pages

## Tech Stack

- Flutter and Dart
- `flutter_bloc` for BLoC/Cubit state management
- Repository pattern with remote/local data sources
- `http`, `dartz`, `equatable` for API and model layer
- `shared_preferences` for local state persistence
- Payment integrations including Stripe (`flutter_stripe`)
- Firebase Crashlytics (`firebase_core`, `firebase_crashlytics`) for crash monitoring

## Project Architecture

The app follows a feature-first modular architecture.

```mermaid
flowchart LR
		UI[UI: Screens and Widgets] --> ST[State: Cubit and Bloc]
		ST --> RP[Repositories]
		RP --> RD[Remote Data Source]
		RP --> LD[Local Data Source]
		RD --> API[Backend APIs]
		LD --> SP[SharedPreferences]
```

### Startup and Dependency Wiring

```mermaid
flowchart TD
		A[main.dart] --> B[Initialize Flutter Bindings]
		B --> C[Initialize Crashlytics]
		C --> D[StateInjector.init]
		D --> E[MultiRepositoryProvider]
		E --> F[MultiBlocProvider]
		F --> G[MaterialApp and Routes]
```

## End-to-End User Flows

### Browse to Order Flow

```mermaid
flowchart TD
		A[Open App] --> B[Home]
		B --> C[Category or Search]
		C --> D[Product Details]
		D --> E[Select Variant]
		E --> F[Add to Cart]
		F --> G[Cart]
		G --> H[Checkout]
		H --> I[Place Order]
		I --> J[Order Details]
```

### Variant Consistency Flow

```mermaid
flowchart LR
		V[Selected Variant] --> P[Variant Price]
		V --> I[Variant Image]
		V --> C[Variant Color and Size]
		P --> C1[Cart Price]
		P --> C2[Checkout Price]
		P --> C3[Order Details Price]
		I --> I1[Cart Thumbnail]
		I --> I2[Checkout Thumbnail]
		I --> I3[Order Item Thumbnail]
		C --> T[Color and Size Chips]
```

### Virtual Try-On Flow

```mermaid
flowchart TD
		A[Open Try-On] --> B[Permission Check]
		B --> C[Open Camera or Gallery]
		C --> D[Pick or Capture Image]
		D --> E[Apply Try-On Experience]
		E --> F[Preview Result]
		F --> G[Save or Continue Shopping]
```

### Checkout Flow

```mermaid
flowchart TD
		A[Cart Totals] --> B[Apply Coupon]
		B --> C[Fetch Shipping Methods]
		C --> D[Select Billing and Shipping Address]
		D --> E[Confirm Terms]
		E --> F[Place Order]
```

## File and Module Architecture

### Top-Level `lib` Layout

```text
lib/
	core/                    # Routing, constants, remote URLs, shared core logic
	dummy_data/              # Static mock or supportive data
	generated/               # Generated files
	modules/                 # Feature modules
	utils/                   # Helpers, theme, language strings, constants
	widgets/                 # Reusable UI widgets
	main.dart                # App entry point
	state_injector.dart      # Dependency and bloc provider wiring
	state_inject_packages.dart
```

### Feature Modules (`lib/modules`)

```text
lib/modules/
	animated_splash_screen/
	authentication/
	cart/
	category/
	flash/
	home/
	main_page/
	message/
	notification/
	onboarding/
	order/
	place_order/
	product_details/
	profile/
	search/
	seller/
	setting/
	try_on/
```

### Assets Layout

```text
assets/
	icon/
	icons/
	image/
	images/
	stripe/
```

## API and State Data Flow

```mermaid
sequenceDiagram
		participant UI as Screen or Widget
		participant B as Bloc or Cubit
		participant R as Repository
		participant DS as Data Source
		participant API as Server

		UI->>B: User action
		B->>R: Request use-case
		R->>DS: Read remote or local
		DS->>API: HTTP request
		API-->>DS: JSON response
		DS-->>R: Model mapping
		R-->>B: Success or Failure
		B-->>UI: Updated state render
```

## Crashlytics and Error Observability

Crash reporting is integrated in startup with Flutter and zone error handlers.

- Bootstrap and global handlers: [lib/main.dart](lib/main.dart)
- Dependencies: [pubspec.yaml](pubspec.yaml)

To complete Firebase linkage (required for dashboard visibility):

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Then apply native setup for Android/iOS generated by FlutterFire.

## Setup and Run

```bash
flutter clean
flutter pub get
flutter run
```

## Configuration Checklist

- API base URLs and keys
- Payment keys and provider settings
- Firebase project configuration for Crashlytics
- Android and iOS environment setup

## Developer Guidelines

- Keep new features inside [lib/modules](lib/modules)
- Register repositories and blocs in [lib/state_injector.dart](lib/state_injector.dart)
- Keep shared utilities in [lib/utils](lib/utils)
- Keep reusable UI components in [lib/widgets](lib/widgets)
- Follow variant consistency across product, cart, checkout, and order layers

## Additional Documentation

- Home dynamic API reference: [docs/HOME_DYNAMIC_APIS.md](docs/HOME_DYNAMIC_APIS.md)
- Product details API reference: [docs/PRODUCT_DETAILS_APIS.md](docs/PRODUCT_DETAILS_APIS.md)