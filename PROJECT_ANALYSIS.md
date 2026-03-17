# OUI-User Flutter App — Complete Project Analysis

> **Package**: `shop_us` (v1.3.0+1)  
> **Type**: Multivendor eCommerce user app (Flutter)  
> **Backend**: Laravel API at `https://oui.corescent.in/api/`  
> **Android**: namespace `com.oui.app`, Kotlin, Java 11, AGP plugin DSL  
> **iOS**: CocoaPods, Runner target  
> **SDK**: Dart >=3.4.1 <4.0.0  
> **Total Dart Files**: 343

---

## Architecture

- **Pattern**: Feature-based Clean Architecture + BLoC/Cubit
- **State Management**: flutter_bloc (BLoC + Cubit)
- **DI**: Manual via `StateInjector` (RepositoryProvider + BlocProvider)
- **Error Handling**: dartz `Either<Failure, T>`, custom exceptions/failures
- **API**: http package, `NetworkParser` for response handling
- **Local Storage**: SharedPreferences via `LocalDataSource`
- **Routing**: Named routes in `RouteNames.generateRoute()` (50+ routes)

---

## Folder Structure

```
lib/
├── main.dart                  # Entry point, ScreenUtil(375×812), MultiProvider
├── state_injector.dart        # DI container (~15 repos + ~30 blocs)
├── state_inject_packages.dart # Barrel exports for DI
├── core/
│   ├── remote_urls.dart       # 60+ API endpoints
│   ├── router_name.dart       # 50+ named routes + generateRoute()
│   ├── router_package_names.dart
│   ├── error/                 # Failure, Exception, NetworkParser
│   └── data/datasources/     # RemoteDataSource (60+ methods), LocalDataSource
├── utils/                     # Theme, constants, colors, validators, formatters
├── widgets/                   # 20 reusable widgets
├── generated/assets.dart      # 100+ asset path constants
├── dummy_data/                # Placeholder notification/chat data
└── modules/
    ├── animated_splash_screen/ # Splash + AppSettingCubit
    ├── onboarding/            # 3-page intro carousel
    ├── authentication/        # Login, SignUp, Forgot, Verification
    ├── main_page/             # BottomNav (Home, Order, Profile)
    ├── home/                  # Home screen with all sections
    ├── category/              # Categories, filtering, sub/child
    ├── flash/                 # Flash sale with countdown
    ├── product_details/       # Product page, variants, reviews
    ├── cart/                  # Cart CRUD, coupon, checkout
    ├── place_order/           # 10 payment gateways
    ├── order/                 # Order list, single order, status
    ├── profile/               # Profile, address, wishlist, password
    ├── search/                # Product search with pagination
    ├── seller/                # Seller store page
    ├── setting/               # About, FAQ, Terms, Privacy, Contact
    ├── notification/          # Notification list (dummy)
    ├── message/               # Chat UI (dummy)
    └── try_on/                # Virtual try-on via CatVTON API
```

---

## Key Flows

- **App Start**: Splash → `AppSettingCubit.loadWebSetting()` → check login/onboarding → route
- **Auth**: `LoginBloc` (email+pass) → token → cache → MainPage
- **Browse**: Home → Category → ProductDetails → AddToCart → Cart → Checkout → PlaceOrder
- **Payments**: COD, Stripe (card form), PayPal/Razorpay/Flutterwave/Mollie/Instamojo/PayStack/SSL (WebView), Bank (form)
- **Profile**: Edit (cascading country/state/city), Address CRUD, Wishlist, Password change

---

## Key Dependencies

| Package | Purpose |
|---------|---------|
| flutter_bloc | State management (BLoC + Cubit) |
| http | HTTP client for API calls |
| shared_preferences | Local key-value storage |
| dartz | Functional programming (Either, Option) |
| flutter_stripe | Stripe payment integration |
| webview_flutter | WebView for payment gateways |
| cached_network_image | Image caching |
| image_picker | Camera/gallery image selection |
| flutter_screenutil | Responsive UI sizing |
| carousel_slider | Image carousels |
| flutter_html | HTML content rendering |
| flutter_credit_card | Credit card UI widget |
| pinput | OTP input field |
| country_code_picker | Country code selection |
| shimmer | Loading skeleton animations |

---

## Screen-by-Screen File Map

### 1. SPLASH SCREEN
**Screen**: Animated splash with logo animation, loads app settings from API

| # | File Path | Class | Role |
|---|-----------|-------|------|
| 1 | `lib/modules/animated_splash_screen/animated_splash_screen.dart` | `AnimatedSplashScreen` | Wrapper for splash config |
| 2 | `lib/modules/animated_splash_screen/splash_screen.dart` | `SplashScreen` | Main splash screen UI |
| 3 | `lib/modules/animated_splash_screen/widgets/animation_splash_widget.dart` | `AnimationSplashWidget` | Animated logo + loader |
| 4 | `lib/modules/animated_splash_screen/widgets/setting_error_widget.dart` | `SettingErrorWidget` | Error display on init fail |
| 5 | `lib/modules/animated_splash_screen/controller/app_setting_cubit/app_setting_cubit.dart` | `AppSettingCubit` | Loads website settings |
| 6 | `lib/modules/animated_splash_screen/controller/app_setting_cubit/app_setting_state.dart` | `AppSettingState` | States: Loading/Error/Loaded |
| 7 | `lib/modules/animated_splash_screen/controller/repository/app_setting_repository.dart` | `AppSettingRepositoryImp` | Fetches app config from API |

---

### 2. ONBOARDING SCREEN
**Screen**: 3-page intro carousel with dot indicators, shown only on first launch

| # | File Path | Class | Role |
|---|-----------|-------|------|
| 1 | `lib/modules/onboarding/onboarding_screen.dart` | `OnboardingScreen` | Main onboarding carousel |
| 2 | `lib/modules/onboarding/model/onboarding_model.dart` | `OnboardingModel` | Page data model |
| 3 | `lib/modules/onboarding/model/onboarding_data.dart` | (Data) | Sample content/images |
| 4 | `lib/modules/onboarding/widgets/dot_indicator_widget.dart` | `DotIndicatorWidget` | Page indicator dots |

---

### 3. AUTHENTICATION SCREEN
**Screen**: Login/SignUp tabs, Forgot Password, OTP Verification, Set Password

| # | File Path | Class | Role |
|---|-----------|-------|------|
| 1 | `lib/modules/authentication/authentication_screen.dart` | `AuthenticationScreen` | Main auth screen (Login/SignUp) |
| 2 | `lib/modules/authentication/forgot_screen.dart` | `ForgotScreen` | Password recovery form |
| 3 | `lib/modules/authentication/verification_code_screen.dart` | `VerificationCodeScreen` | OTP input screen |
| 4 | `lib/modules/authentication/setpassword_screen.dart` | `SetPasswordScreen` | New password setup |
| 5 | `lib/modules/authentication/widgets/sign_in_form.dart` | `SignInForm` | Email + password login |
| 6 | `lib/modules/authentication/widgets/sign_up_form.dart` | `SignUpForm` | Registration form |
| 7 | `lib/modules/authentication/widgets/social_buttons.dart` | `SocialButtons` | OAuth buttons (Google, FB) |
| 8 | `lib/modules/authentication/widgets/guest_button.dart` | `GuestButton` | Continue as guest |
| 9 | `lib/modules/authentication/models/user_login_response_model.dart` | `UserLoginResponseModel` | Login API response |
| 10 | `lib/modules/authentication/models/user_prfile_model.dart` | `UserProfileModel` | User profile data |
| 11 | `lib/modules/authentication/models/set_password_model.dart` | `SetPasswordModel` | Password reset request |
| 12 | `lib/modules/authentication/models/auth_error_model.dart` | `AuthErrorModel` | Auth error response |
| 13 | `lib/modules/authentication/repository/auth_repository.dart` | `AuthRepositoryImp` | Auth API repository |
| 14 | `lib/modules/authentication/controller/login/login_bloc.dart` | `LoginBloc` | Login state management |
| 15 | `lib/modules/authentication/controller/login/login_event.dart` | `LoginEvent` | Login events |
| 16 | `lib/modules/authentication/controller/login/login_state.dart` | `LoginState` | Login states |
| 17 | `lib/modules/authentication/controller/sign_up/sign_up_bloc.dart` | `SignUpBloc` | SignUp state management |
| 18 | `lib/modules/authentication/controller/sign_up/sign_up_event.dart` | `SignUpEvent` | SignUp events |
| 19 | `lib/modules/authentication/controller/sign_up/sign_up_state.dart` | `SignUpState` | SignUp states |
| 20 | `lib/modules/authentication/controller/forgot_password/forgot_password_cubit.dart` | `ForgotPasswordCubit` | Forgot password flow |
| 21 | `lib/modules/authentication/controller/forgot_password/forgot_password_state.dart` | `ForgotPasswordState` | Forgot password states |

---

### 4. MAIN PAGE (Bottom Navigation Shell)
**Screen**: Bottom nav with 3 tabs — Home, Order, Profile

| # | File Path | Class | Role |
|---|-----------|-------|------|
| 1 | `lib/modules/main_page/main_page.dart` | `MainPage` | Root page + tab switching |
| 2 | `lib/modules/main_page/main_controller.dart` | `MainController` | Tab state management |
| 3 | `lib/modules/main_page/component/bottom_navigation_bar.dart` | `MyBottomNavigationBar` | Bottom nav bar UI |

---

### 5. HOME SCREEN
**Screen**: Home feed with sliders, categories, flash sale, sellers, product sections

| # | File Path | Class | Role |
|---|-----------|-------|------|
| 1 | `lib/modules/home/home_screen.dart` | `HomeScreen`, `_LoadedHomePage` | Main home UI |
| 2 | `lib/modules/home/component/home_app_bar.dart` | `HomeAppBar`, `CartBadge` | App bar + cart badge |
| 3 | `lib/modules/home/component/search_field.dart` | `SearchField` | Search bar |
| 4 | `lib/modules/home/component/offer_banner_slider.dart` | `OfferBannerSlider` | Banner carousel |
| 5 | `lib/modules/home/component/hot_deal_banner.dart` | `HotDealBanner` | Deal banner |
| 6 | `lib/modules/home/component/hot_deal_banner_slider.dart` | `CombineBannerSlider` | Multi-banner carousel |
| 7 | `lib/modules/home/component/category_and_list_component.dart` | `CategoryAndListComponent` | Categories + products layout |
| 8 | `lib/modules/home/component/category_grid_view.dart` | `CategoryGridView` | Category grid |
| 9 | `lib/modules/home/component/flash_sale_component.dart` | `FlashSaleComponent` | Flash sale with countdown |
| 10 | `lib/modules/home/component/populer_product_component.dart` | `HorizontalProductComponent` | Popular products row |
| 11 | `lib/modules/home/component/new_arrival_component.dart` | `NewArrivalComponent` | New arrivals section |
| 12 | `lib/modules/home/component/best_seller_grid_view.dart` | `BestSellerGridView` | Best sellers grid |
| 13 | `lib/modules/home/component/single_circuler_seller.dart` | `SingleCircularSeller` | Seller avatar |
| 14 | `lib/modules/home/component/single_offer_banner.dart` | `SingleOfferBanner` | Single banner widget |
| 15 | `lib/modules/home/component/section_header.dart` | `SectionHeader` | Section title + "View All" |
| 16 | `lib/modules/home/component/sponsor_component.dart` | `SponsorComponent` | Sponsor/brand section |
| 17 | `lib/modules/home/component/headphone_componet.dart` | `HeadphoneComponent` | Featured headphones |
| 18 | `lib/modules/home/component/home_horizontal_list_product_card.dart` | `HomeHorizontalListProductCard` | Product card (horizontal) |
| 19 | `lib/modules/home/model/home_model.dart` | `HomeModel` | Home page response |
| 20 | `lib/modules/home/model/banner_model.dart` | `BannerModel` | Banner data |
| 21 | `lib/modules/home/model/brand_model.dart` | `BrandModel` | Brand data |
| 22 | `lib/modules/home/model/flash_sale_model.dart` | `FlashSaleModel` | Flash sale data |
| 23 | `lib/modules/home/model/home_categories_model.dart` | `HomePageCategoriesModel` | Category data |
| 24 | `lib/modules/home/model/home_seller_model.dart` | `HomeSellerModel` | Seller data |
| 25 | `lib/modules/home/model/product_model.dart` | `ProductModel`, `GalleryModel` | Product data |
| 26 | `lib/modules/home/model/section_title_model.dart` | `SectionTitleModel` | Section title data |
| 27 | `lib/modules/home/model/slider_model.dart` | `SliderModel` | Slider image data |
| 28 | `lib/modules/home/model/setting_model.dart` | `SettingModel` | App settings data |
| 29 | `lib/modules/home/controller/cubit/home_controller_cubit.dart` | `HomeControllerCubit` | Home data loading |
| 30 | `lib/modules/home/controller/cubit/home_controller_state.dart` | `HomeControllerState` | Home states |
| 31 | `lib/modules/home/controller/cubit/products_cubit.dart` | `ProductsCubit` | Featured products |
| 32 | `lib/modules/home/controller/cubit/products_state.dart` | `ProductsState` | Products states |
| 33 | `lib/modules/home/controller/repository/home_repository.dart` | `HomeRepositoryImp` | Home API repository |

---

### 6. CATEGORY SCREEN
**Screen**: Category browsing, sub/child categories, filtering, product grids

| # | File Path | Class | Role |
|---|-----------|-------|------|
| 1 | `lib/modules/category/all_category_list_screen.dart` | `AllCategoryListScreen` | All categories list |
| 2 | `lib/modules/category/single_category_product_screen.dart` | `SingleCategoryProductScreen` | Products in category |
| 3 | `lib/modules/category/sub_category_products.dart` | `SubCategoryProductScreen` | Sub-category products |
| 4 | `lib/modules/category/all_populer_product_screen.dart` | `AllPopularProductScreen` | Popular products |
| 5 | `lib/modules/category/all_flash_deal_product_screen.dart` | `AllFlashDealProductScreen` | Flash deal products |
| 6 | `lib/modules/category/all_seller_list.dart` | `AllSellerListScreen` | All sellers list |
| 7 | `lib/modules/category/brand_product_screen.dart` | `BrandProductScreen` | Products by brand |
| 8 | `lib/modules/category/component/single_circuler_card.dart` | `CategoryCircleCard` | Category circle icon |
| 9 | `lib/modules/category/component/product_card.dart` | `ProductCard` | Product card |
| 10 | `lib/modules/category/component/popular_product_card.dart` | `PopularProductCard` | Popular product card |
| 11 | `lib/modules/category/component/price_card_widget.dart` | `PriceCardWidget` | Price display |
| 12 | `lib/modules/category/component/drawer_filter.dart` | `DrawerFilter` | Filter drawer |
| 13 | `lib/modules/category/model/category_model.dart` | `CategoriesModel` | Category model |
| 14 | `lib/modules/category/model/child_category_model.dart` | `ChildCategoryModel` | Child category model |
| 15 | `lib/modules/category/model/filter_model.dart` | `FilterModelDto` | Filter options |
| 16 | `lib/modules/category/model/product_categories_model.dart` | `ProductCategoriesModel` | Category+products response |
| 17 | `lib/modules/category/model/sub_category_model.dart` | `SubCategoryModel` | Sub-category model |
| 18 | `lib/modules/category/controller/repository/category_repositry.dart` | `CategoryRepositoryImp` | Category API repository |
| 19 | `lib/modules/category/controller/cubit/category_cubit.dart` | `CategoryCubit` | Category state |
| 20 | `lib/modules/category/controller/cubit/category_state.dart` | `CategoryState` | Category states |
| 21 | `lib/modules/category/controller/cubit/cubit/child_cubit.dart` | `ChildCategoryCubit` | Child category state |
| 22 | `lib/modules/category/controller/cubit/cubit/child_state.dart` | `ChildCategoryState` | Child states |
| 23 | `lib/modules/category/controller/cubit/cubit/sub_category_cubit.dart` | `SubCategoryCubit` | Sub-category state |
| 24 | `lib/modules/category/controller/cubit/cubit/sub_category_state.dart` | `SubCategoryState` | Sub-category states |

---

### 7. FLASH SALE SCREEN
**Screen**: Flash sale with countdown timer and products

| # | File Path | Class | Role |
|---|-----------|-------|------|
| 1 | `lib/modules/flash/flash_screen.dart` | `FlashScreen` | Flash sale UI |
| 2 | `lib/modules/flash/model/flash_model.dart` | `FlashModel` | Flash sale model |
| 3 | `lib/modules/flash/controller/flash_repository.dart` | `FlashRepositoryImp` | Flash sale repository |
| 4 | `lib/modules/flash/controller/cubit/flash_cubit.dart` | `FlashCubit` | Flash sale state |
| 5 | `lib/modules/flash/controller/cubit/flash_state.dart` | `FlashState` | Flash states |

---

### 8. PRODUCT DETAILS SCREEN
**Screen**: Product page with image gallery, variants, reviews, related products, add-to-cart

| # | File Path | Class | Role |
|---|-----------|-------|------|
| 1 | `lib/modules/product_details/product_details_screen.dart` | `ProductDetailsScreen` | Main product page |
| 2 | `lib/modules/product_details/review_list_screen.dart` | `SeelAllReviewsScreen` | All reviews list |
| 3 | `lib/modules/product_details/submit_feedback_screen.dart` | `SubmitFeedBackScreen` | Review submission form |
| 4 | `lib/modules/product_details/component/product_details_component.dart` | `ProductDetailsComponent` | Details content |
| 5 | `lib/modules/product_details/component/product_header_component.dart` | `ProductHeaderComponent` | Image gallery + info |
| 6 | `lib/modules/product_details/component/description_component.dart` | `DescriptionComponent` | Product description |
| 7 | `lib/modules/product_details/component/seller_info_component.dart` | `SellerInfoComponent` | Seller info |
| 8 | `lib/modules/product_details/component/rating_list_component.dart` | `RatingListComponent` | Rating breakdown |
| 9 | `lib/modules/product_details/component/signle_review_card_component.dart` | `SingleReviewCardComponent` | Review card |
| 10 | `lib/modules/product_details/component/related_products_list.dart` | `RelatedProductsList` | Related products |
| 11 | `lib/modules/product_details/component/related_single_product_card.dart` | `RelatedSingleProductCard` | Related product card |
| 12 | `lib/modules/product_details/component/bottom_sheet_widget.dart` | `BottomSheetWidget` | Variant/qty selector |
| 13 | `lib/modules/product_details/component/bottom_seet_product.dart` | `BottomSheetProduct` | Add animation |
| 14 | `lib/modules/product_details/component/feedback_product_card.dart` | `FeedbackProductCard` | Product card in feedback |
| 15 | `lib/modules/product_details/component/loader_screen.dart` | `LoaderScreen` | Loading skeleton |
| 16 | `lib/modules/product_details/model/product_details_model.dart` | `ProductDetailsModel` | Full product model |
| 17 | `lib/modules/product_details/model/product_details_product_model.dart` | `ProductDetailsProductModel` | Product sub-model |
| 18 | `lib/modules/product_details/model/details_product_reviews_model.dart` | `DetailsProductReviewModel` | Review model |
| 19 | `lib/modules/product_details/model/avg_review_model.dart` | `AvgReviewModel` | Average rating |
| 20 | `lib/modules/product_details/model/variant_items_model.dart` | `ActiveVariantItemModel` | Variant option |
| 21 | `lib/modules/product_details/model/product_variant_model.dart` | `ActiveVariantModel` | Variant group |
| 22 | `lib/modules/product_details/model/tax_model.dart` | `TaxModel` | Tax data |
| 23 | `lib/modules/product_details/model/seller_profile.dart` | `SellerInfoProfile` | Seller info |
| 24 | `lib/modules/product_details/model/submit_review_response.dart` | `SubmitReviewResponseModel` | Review submit response |
| 25 | `lib/modules/product_details/controller/cubit/product_details_cubit.dart` | `ProductDetailsCubit` | Product details state |
| 26 | `lib/modules/product_details/controller/cubit/product_details_state.dart` | `ProductDetailsState` | Details states |
| 27 | `lib/modules/product_details/controller/review/review_cubit.dart` | `SubmitReviewCubit` | Review submit state |
| 28 | `lib/modules/product_details/controller/review/review_state.dart` | `ReviewSubmitState` | Review states |
| 29 | `lib/modules/product_details/controller/repository/product_details_repository.dart` | `ProductDetailsRepositoryImp` | Details repository |
| 30 | `lib/modules/product_details/controller/repository/review_submit_repository.dart` | `SubmitReviewRepositoryImp` | Review repository |

---

### 9. CART SCREEN
**Screen**: Shopping cart with items, quantity update, coupon, checkout

| # | File Path | Class | Role |
|---|-----------|-------|------|
| 1 | `lib/modules/cart/cart_screen.dart` | `CartScreen` | Cart list UI |
| 2 | `lib/modules/cart/checkout_screen.dart` | `CheckoutScreen` | Checkout flow |
| 3 | `lib/modules/cart/component/add_to_cart_component.dart` | `AddToCartComponent` | Qty + add button |
| 4 | `lib/modules/cart/component/address_card_component.dart` | `AddressCardComponent` | Address selection card |
| 5 | `lib/modules/cart/component/checkout_single_item.dart` | `CheckoutSingleItem` | Cart item in checkout |
| 6 | `lib/modules/cart/component/panel_widget.dart` | `PanelWidget` | Order summary panel |
| 7 | `lib/modules/cart/component/shiping_method_list.dart` | `ShippingMethodList` | Shipping options |
| 8 | `lib/modules/cart/component/single_payment_card_component.dart` | `SinglePaymentCardComponent` | Payment card display |
| 9 | `lib/modules/cart/model/cart_response_model.dart` | `CartResponseModel` | Cart API response |
| 10 | `lib/modules/cart/model/cart_product_model.dart` | `CartProductModel` | Cart item model |
| 11 | `lib/modules/cart/model/cart_calculation_model.dart` | `CartCalculationModel` | Cart totals |
| 12 | `lib/modules/cart/model/add_to_cart_model.dart` | `AddToCartModel` | Add to cart request |
| 13 | `lib/modules/cart/model/address_response_model.dart` | `AddressResponseModel` | Address list response |
| 14 | `lib/modules/cart/model/coupon_response_model.dart` | `CouponResponseModel` | Coupon validation |
| 15 | `lib/modules/cart/model/checkout_response_model.dart` | `CheckoutResponseModel` | Checkout response |
| 16 | `lib/modules/cart/model/shipping_method_model.dart` | `ShippingMethodModel` | Shipping method |
| 17 | `lib/modules/cart/model/shipping_response_model.dart` | `ShippingResponseModel` | Shipping API response |
| 18 | `lib/modules/cart/model/varient_model.dart` | `VarientModel` | Variant info |
| 19 | `lib/modules/cart/model/varient_item_model.dart` | `VarientItemModel` | Variant item |
| 20 | `lib/modules/cart/controllers/cart_repository.dart` | `CartRepositoryImp` | Cart repository |
| 21 | `lib/modules/cart/controllers/cart/cart_cubit.dart` | `CartCubit` | Cart state |
| 22 | `lib/modules/cart/controllers/cart/cart_state.dart` | `CartState` | Cart states |
| 23 | `lib/modules/cart/controllers/cart/add_to_cart/add_to_cart_cubit.dart` | `AddToCartCubit` | Add to cart state |
| 24 | `lib/modules/cart/controllers/cart/add_to_cart/add_to_cart_state.dart` | `AddToCartState` | Add states |
| 25 | `lib/modules/cart/controllers/checkout/checkout_cubit.dart` | `CheckoutCubit` | Checkout state |
| 26 | `lib/modules/cart/controllers/checkout/checkout_state.dart` | `CheckoutState` | Checkout states |
| 27 | `lib/modules/cart/controllers/shipping_charges/shipping_charges_cubit.dart` | `ShippingChargesCubit` | Shipping calc |
| 28 | `lib/modules/cart/controllers/shipping_charges/shipping_charges_state.dart` | `ShippingChargesState` | Shipping states |

---

### 10. PLACE ORDER (Payments)
**Screen**: Payment method selection + 10 gateways (COD, Stripe, PayPal, Razorpay, Flutterwave, Mollie, Instamojo, PayStack, SSL, Bank)

| # | File Path | Class | Role |
|---|-----------|-------|------|
| 1 | `lib/modules/place_order/place_order_screen.dart` | `PlaceOrderScreen`, `PaymentCard` | Payment selection |
| 2 | `lib/modules/place_order/stripe_screen.dart` | `StripeScreen` | Stripe card form |
| 3 | `lib/modules/place_order/paypal_screen.dart` | `PaypalScreen` | PayPal WebView |
| 4 | `lib/modules/place_order/razorpay_screen.dart` | `RazorpayScreen` | Razorpay WebView |
| 5 | `lib/modules/place_order/paystack_payment_screen.dart` | `PaystackPaymentScreen` | PayStack WebView |
| 6 | `lib/modules/place_order/mollie_payment_screen.dart` | `MolliePaymentScreen` | Mollie WebView |
| 7 | `lib/modules/place_order/flutterwave_screen.dart` | `FlutterWaveScreen` | Flutterwave WebView |
| 8 | `lib/modules/place_order/instamojo_payment_screen.dart` | `InstamojoPaymentScreen` | Instamojo WebView |
| 9 | `lib/modules/place_order/sslcommerce.dart` | `SslCommerceScreen` | SSL Commerz WebView |
| 10 | `lib/modules/place_order/bank_payment.dart` | `BankPaymentScreen` | Bank transfer form |
| 11 | `lib/modules/place_order/model/transaction_response.dart` | `TransactionResponseModel` | Transaction result |
| 12 | `lib/modules/place_order/model/payment_status/stripe_status.dart` | `StripeStatusModel` | Stripe status |
| 13 | `lib/modules/place_order/model/payment_status/paypal_status.dart` | `PaypalStatusModel` | PayPal status |
| 14 | `lib/modules/place_order/model/payment_status/razorpay_status.dart` | `RazorpayStatusModel` | Razorpay status |
| 15 | `lib/modules/place_order/model/payment_status/paystact_mollie_status.dart` | `PaystackMollieStatusModel` | PayStack/Mollie status |
| 16 | `lib/modules/place_order/model/payment_status/flutter_wave_status.dart` | `FlutterwaveStatusModel` | Flutterwave status |
| 17 | `lib/modules/place_order/model/payment_status/instamojo_status.dart` | `InstamojoStatusModel` | Instamojo status |
| 18 | `lib/modules/place_order/model/payment_status/sslcommerz_status.dart` | `SslcommerzStatusModel` | SSL Commerz status |
| 19 | `lib/modules/place_order/model/payment_status/bank_status.dart` | `BankStatusModel` | Bank status |
| 20 | `lib/modules/place_order/controllers/payment_repository.dart` | `PaymentRepositoryImp` | Payment repository |
| 21 | `lib/modules/place_order/controllers/payment/payment_cubit.dart` | `PaymentCubit` | Payment state |
| 22 | `lib/modules/place_order/controllers/payment/payment_service.dart` | `PaymentService` | Payment processing |
| 23 | `lib/modules/place_order/controllers/payment/payment_state.dart` | `PaymentState` | Payment states |
| 24 | `lib/modules/place_order/controllers/stripe/stripe_cubit.dart` | `StripeCubit` | Stripe state |
| 25 | `lib/modules/place_order/controllers/stripe/stripe_state.dart` | `StripeState` | Stripe states |
| 26 | `lib/modules/place_order/controllers/paypal/paypal_cubit.dart` | `PaypalCubit` | PayPal state |
| 27 | `lib/modules/place_order/controllers/paypal/paypal_state.dart` | `PaypalState` | PayPal states |
| 28 | `lib/modules/place_order/controllers/razorpay/razorpay_cubit.dart` | `RazorpayCubit` | Razorpay state |
| 29 | `lib/modules/place_order/controllers/razorpay/razorpay_state.dart` | `RazorpayState` | Razorpay states |
| 30 | `lib/modules/place_order/controllers/cash_on_payment/cash_on_payment_cubit.dart` | `CashOnPaymentCubit` | COD state |
| 31 | `lib/modules/place_order/controllers/cash_on_payment/cash_on_payment_state.dart` | `CashOnPaymentState` | COD states |
| 32 | `lib/modules/place_order/controllers/bank/bank_cubit.dart` | `BankCubit` | Bank state |
| 33 | `lib/modules/place_order/controllers/bank/bank_state.dart` | `BankState` | Bank states |

---

### 11. ORDER SCREEN
**Screen**: Order history list, single order details, status tracking

| # | File Path | Class | Role |
|---|-----------|-------|------|
| 1 | `lib/modules/order/order_screen.dart` | `OrderScreen` | Order list |
| 2 | `lib/modules/order/single_order.dart` | `SingleOrderDetailScreen` | Order details |
| 3 | `lib/modules/order/component/ordered_list_component.dart` | `OrderedListComponent` | Order list component |
| 4 | `lib/modules/order/component/single_order_details_component.dart` | `SingleOrderDetailsComponent` | Order detail component |
| 5 | `lib/modules/order/component/product_details_button.dart` | `ProductDetailsButton` | View product button |
| 6 | `lib/modules/order/component/empty_order_component.dart` | `EmptyOrderComponent` | Empty state |
| 7 | `lib/modules/order/model/order_model.dart` | `OrderModel` | Order model |
| 8 | `lib/modules/order/model/product_order_model.dart` | `ProductOrderModel` | Ordered product model |
| 9 | `lib/modules/order/controllers/repository/order_repository.dart` | `OrderRepositoryImp` | Order repository |
| 10 | `lib/modules/order/controllers/order/order_cubit.dart` | `OrderCubit` | Order state |
| 11 | `lib/modules/order/controllers/order/order_state.dart` | `OrderState` | Order states |

---

### 12. PROFILE SCREEN
**Screen**: Profile overview, edit profile, addresses, wishlist, password change

| # | File Path | Class | Role |
|---|-----------|-------|------|
| 1 | `lib/modules/profile/profile_screen.dart` | `ProfileScreen` | Profile overview |
| 2 | `lib/modules/profile/profile_edit_screen.dart` | `ProfileEditScreen` | Edit profile |
| 3 | `lib/modules/profile/address_screen.dart` | `AddressScreen` | Address management |
| 4 | `lib/modules/profile/change_password_screen.dart` | `ChangePasswordScreen` | Change password |
| 5 | `lib/modules/profile/payments_screen.dart` | `PaymentsScreen` | Saved payments |
| 6 | `lib/modules/profile/component/profile_app_bar.dart` | `ProfileAppBar` | Profile app bar |
| 7 | `lib/modules/profile/component/profile_edit_app_bar.dart` | `ProfileEditAppBar` | Edit app bar |
| 8 | `lib/modules/profile/component/profile_edit_form.dart` | `ProfileEditForm` | Edit form fields |
| 9 | `lib/modules/profile/component/wish_list_card.dart` | `WishListCard` | Wishlist item card |
| 10 | `lib/modules/profile/model/address_model.dart` | `AddressModel` | Address model |
| 11 | `lib/modules/profile/model/address_info.dart` | `AddressInfo` | Address info |
| 12 | `lib/modules/profile/model/billing_shipping_model.dart` | `BillingShippingModel` | Billing/shipping |
| 13 | `lib/modules/profile/model/city_model.dart` | `CityModel` | City model |
| 14 | `lib/modules/profile/model/country_model.dart` | `CountryModel` | Country model |
| 15 | `lib/modules/profile/model/country_state_model.dart` | `CountryStateModel` | State/province |
| 16 | `lib/modules/profile/model/edit_address_model.dart` | `EditAddressModel` | Edit address data |
| 17 | `lib/modules/profile/model/user_with_country_response.dart` | `UserWithCountryResponse` | User + country data |
| 18 | `lib/modules/profile/model/user_info/user_updated_info.dart` | `UserUpdatedInfo` | Updated user info |
| 19 | `lib/modules/profile/model/user_info/update_user_info.dart` | `UpdateUserInfo` | Update request |
| 20 | `lib/modules/profile/model/user_info/order_address_model.dart` | `OrderAddressModel` | Order address |
| 21 | `lib/modules/profile/controllers/repository/profile_repository.dart` | `ProfileRepositoryImp` | Profile repository |
| 22 | `lib/modules/profile/controllers/profile_edit/profile_edit_cubit.dart` | `ProfileEditCubit` | Profile edit state |
| 23 | `lib/modules/profile/controllers/profile_edit/profile_edit_state.dart` | `ProfileEditState` | Edit states |
| 24 | `lib/modules/profile/controllers/change_password/change_password_cubit.dart` | `ChangePasswordCubit` | Password change state |
| 25 | `lib/modules/profile/controllers/change_password/change_password_state.dart` | `ChangePasswordState` | Password states |
| 26 | `lib/modules/profile/controllers/updated_info/updated_info_cubit.dart` | `UpdatedInfoCubit` | Info update state |
| 27 | `lib/modules/profile/controllers/updated_info/updated_info_state.dart` | `UpdatedInfoState` | Update states |
| 28 | `lib/modules/profile/controllers/address/address_cubit.dart` | `AddressCubit` | Address state |
| 29 | `lib/modules/profile/controllers/address/address_state.dart` | `AddressState` | Address states |
| 30 | `lib/modules/profile/controllers/address/cubit/edit_address_cubit.dart` | `EditAddressCubit` | Edit address state |
| 31 | `lib/modules/profile/controllers/address/cubit/edit_address_state.dart` | `EditAddressState` | Edit address states |
| 32 | `lib/modules/profile/controllers/country_state_by_id/country_state_by_id_cubit.dart` | `CountryStateByIdCubit` | Country→State fetch |
| 33 | `lib/modules/profile/controllers/country_state_by_id/country_state_by_id_state.dart` | `CountryStateByIdState` | Country state states |
| 34 | `lib/modules/profile/profile_offer/profile_offer_screen.dart` | `ProfileOfferScreen` | Offers/coupons |
| 35 | `lib/modules/profile/profile_offer/wishlist_offer_screen.dart` | `WishlistOfferScreen` | Wishlist screen |
| 36 | `lib/modules/profile/profile_offer/model/wish_list_model.dart` | `WishListModel` | Wishlist model |
| 37 | `lib/modules/profile/profile_offer/controllers/wish_list/wish_list_cubit.dart` | `WishListCubit` | Wishlist state |
| 38 | `lib/modules/profile/profile_offer/controllers/wish_list/wish_list_state.dart` | `WishListState` | Wishlist states |

---

### 13. SEARCH SCREEN
**Screen**: Product search with pagination

| # | File Path | Class | Role |
|---|-----------|-------|------|
| 1 | `lib/modules/search/product_search_screen.dart` | `ProductSearchScreen` | Search UI |
| 2 | `lib/modules/search/components/rounded_app_bar.dart` | `SearchRoundedAppBar` | Search app bar |
| 3 | `lib/modules/search/model/search_response_model.dart` | `SearchResponseModel` | Search response |
| 4 | `lib/modules/search/controllers/search_repository.dart` | `SearchRepositoryImp` | Search repository |
| 5 | `lib/modules/search/controllers/search_product_model.dart` | `SearchProductModel` | Search product model |
| 6 | `lib/modules/search/controllers/search/search_bloc.dart` | `SearchBloc` | Search state |
| 7 | `lib/modules/search/controllers/search/search_event.dart` | `SearchEvent` | Search events |
| 8 | `lib/modules/search/controllers/search/search_state.dart` | `SearchState` | Search states |

---

### 14. SELLER SCREEN
**Screen**: Seller store/profile page with products

| # | File Path | Class | Role |
|---|-----------|-------|------|
| 1 | `lib/modules/seller/seller_screen.dart` | `BestSellerInformation` | Seller page |
| 2 | `lib/modules/seller/model/seller_model.dart` | `SellerModel` | Seller model |
| 3 | `lib/modules/seller/model/single_seller_model.dart` | `SingleSellerModel` | Seller detail model |

---

### 15. SETTING SCREENS
**Screen**: About Us, FAQ, Terms, Privacy, Contact Us, Add/Edit Address, Add Payment Card

| # | File Path | Class | Role |
|---|-----------|-------|------|
| 1 | `lib/modules/setting/setting_screen.dart` | `SettingScreen` | Settings menu |
| 2 | `lib/modules/setting/about_us_screen.dart` | `AboutUsScreen` | About us page |
| 3 | `lib/modules/setting/contact_us_screen.dart` | `ContactUsScreen` | Contact form |
| 4 | `lib/modules/setting/privacy_policy_screen.dart` | `PrivacyPolicyScreen` | Privacy policy |
| 5 | `lib/modules/setting/terms_condition_screen.dart` | `TermsConditionScreen` | Terms & conditions |
| 6 | `lib/modules/setting/faq_screen.dart` | `FaqScreen` | FAQ page |
| 7 | `lib/modules/setting/add_address_screen.dart` | `AddAddressScreen` | Add address form |
| 8 | `lib/modules/setting/edit_address_screen.dart` | `EditAddressScreen` | Edit address form |
| 9 | `lib/modules/setting/add_new_payment_card_screen.dart` | `AddNewPaymentCardScreen` | Add card form |
| 10 | `lib/modules/setting/component/contact_us_form_widget.dart` | `ContactUsFormWidget` | Contact form widget |
| 11 | `lib/modules/setting/component/faq_app_bar.dart` | `FaqAppBar` | FAQ app bar |
| 12 | `lib/modules/setting/component/faq_list_widget.dart` | `FaqListWidget` | FAQ list |
| 13 | `lib/modules/setting/component/payment_card.dart` | `PaymentCard` | Payment card display |
| 14 | `lib/modules/setting/model/about_us_model.dart` | `AboutUsModel` | About model |
| 15 | `lib/modules/setting/model/about_information_model.dart` | `AboutInformationModel` | Company info model |
| 16 | `lib/modules/setting/model/contact_us_mode.dart` | `ContactUsModel` | Contact model |
| 17 | `lib/modules/setting/model/contact_us_mesage_model.dart` | `ContactUsMessageModel` | Contact form data |
| 18 | `lib/modules/setting/model/faq_model.dart` | `FaqModel` | FAQ item model |
| 19 | `lib/modules/setting/model/maintainance_text_model.dart` | `MaintainTextModel` | Maintenance text |
| 20 | `lib/modules/setting/model/privacy_policy_model.dart` | `PrivacyPolicyAndTermConditionModel` | Privacy/terms model |
| 21 | `lib/modules/setting/model/services_model.dart` | `Services` | Service model |
| 22 | `lib/modules/setting/model/testimonials_model.dart` | `Testimonials` | Testimonial model |
| 23 | `lib/modules/setting/model/website_setup_model.dart` | `WebsiteSetupModel` | Website config model |
| 24 | `lib/modules/setting/controllers/repository/setting_repository.dart` | `SettingRepositoryImp` | Settings repository |
| 25 | `lib/modules/setting/controllers/about_us_cubit/about_us_cubit.dart` | `AboutUsCubit` | About state |
| 26 | `lib/modules/setting/controllers/about_us_cubit/about_us_state.dart` | `AboutUsState` | About states |
| 27 | `lib/modules/setting/controllers/contact_us_cubit/contact_us_cubit.dart` | `ContactUsCubit` | Contact state |
| 28 | `lib/modules/setting/controllers/contact_us_cubit/contact_us_state.dart` | `ContactUsState` | Contact states |
| 29 | `lib/modules/setting/controllers/contact_us_form_bloc/contact_us_form_bloc.dart` | `ContactUsFormBloc` | Contact form state |
| 30 | `lib/modules/setting/controllers/contact_us_form_bloc/contact_us_form_event.dart` | `ContactUsFormEvent` | Contact form events |
| 31 | `lib/modules/setting/controllers/contact_us_form_bloc/contact_us_form_state.dart` | `ContactUsFormState` | Contact form states |
| 32 | `lib/modules/setting/controllers/faq_cubit/faq_cubit.dart` | `FaqCubit` | FAQ state |
| 33 | `lib/modules/setting/controllers/faq_cubit/faq_cubit_state.dart` | `FaqCubitState` | FAQ states |
| 34 | `lib/modules/setting/controllers/privacy_and_term_condition_cubit/privacy_and_term_condition_cubit.dart` | `PrivacyAndTermConditionCubit` | Privacy/terms state |
| 35 | `lib/modules/setting/controllers/privacy_and_term_condition_cubit/privacy_and_term_condition_cubit_state.dart` | `PrivacyAndTermConditionState` | Privacy/terms states |

---

### 16. NOTIFICATION SCREEN
**Screen**: Notification list (uses dummy data)

| # | File Path | Class | Role |
|---|-----------|-------|------|
| 1 | `lib/modules/notification/notigication_screen.dart` | `NotificationScreen` | Notification list |
| 2 | `lib/modules/notification/model/notification_model.dart` | `NotificationModel` | Notification model |
| 3 | `lib/modules/notification/component/single_notification.dart` | `SingleNotification` | Notification item |
| 4 | `lib/modules/notification/component/notification_list.dart` | `NotificationList` | Notification list component |
| 5 | `lib/modules/notification/component/empty_notification.dart` | `EmptyNotification` | Empty state |

---

### 17. MESSAGE / CHAT SCREEN
**Screen**: Chat list + message conversation (uses dummy data)

| # | File Path | Class | Role |
|---|-----------|-------|------|
| 1 | `lib/modules/message/chat_list_screen.dart` | `ChatListScreen` | Chat list |
| 2 | `lib/modules/message/message_screen.dart` | `MessageScreen` | Chat conversation |
| 3 | `lib/modules/message/model/message_model.dart` | `MessageModel` | Message model |
| 4 | `lib/modules/message/model/chat_list_model.dart` | `ChatListModel` | Chat list model |
| 5 | `lib/modules/message/component/message_component.dart` | `MessageComponent` | Message bubble |
| 6 | `lib/modules/message/component/message_input_field.dart` | `MessageInputField` | Message input |
| 7 | `lib/modules/message/component/chat_list_component.dart` | `ChatListComponent` | Chat list view |
| 8 | `lib/modules/message/component/single_chat_list_item.dart` | `SingleChatListItem` | Chat list item |
| 9 | `lib/modules/message/component/empty_chat_list_component.dart` | `EmptyChatListComponent` | Empty state |
| 10 | `lib/modules/message/component/chat_list_app_bar.dart` | `ChatListAppBar` | Chat app bar |

---

### 18. TRY ON SCREEN
**Screen**: Virtual try-on via CatVTON API (ngrok backend)

| # | File Path | Class | Role |
|---|-----------|-------|------|
| 1 | `lib/modules/try_on/try_on_screen.dart` | `TryOnScreen` | Try-on UI |
| 2 | `lib/modules/try_on/try_on_constants.dart` | (Constants) | CatVTON config |

---

## Shared / Core Files (Used Across All Screens)

### Root Files
| File Path | Class | Role |
|-----------|-------|------|
| `lib/main.dart` | `MyApp` | App entry, ScreenUtil, routing |
| `lib/state_injector.dart` | `StateInjector` | DI container |
| `lib/state_inject_packages.dart` | (Exports) | Barrel exports |

### Core Infrastructure
| File Path | Class | Role |
|-----------|-------|------|
| `lib/core/remote_urls.dart` | `RemoteUrls` | 60+ API endpoints |
| `lib/core/router_name.dart` | `RouteNames` | Named routes + generator |
| `lib/core/router_package_names.dart` | (Exports) | Route imports |
| `lib/core/error/failure.dart` | `Failure` | Error types |
| `lib/core/error/exception.dart` | `ServerException` | Exception types |
| `lib/core/error/network_parser.dart` | `NetworkParser` | HTTP response parsing |
| `lib/core/data/datasources/remote_data_source.dart` | `RemoteDataSourceImpl` | All API calls |
| `lib/core/data/datasources/local_data_source.dart` | `LocalDataSourceImpl` | Local cache |

### Utils
| File Path | Class | Role |
|-----------|-------|------|
| `lib/utils/utils.dart` | `Utils` | Dialogs, snackbars, formatters |
| `lib/utils/my_theme.dart` | `MyTheme` | App theme (Inter/Jost fonts) |
| `lib/utils/constants.dart` | (Constants) | Colors (primaryColor #AE1C9A) |
| `lib/utils/k_images.dart` | `KImages` | Asset paths |
| `lib/utils/k_strings.dart` | `Kstrings` | Cache keys, app name |
| `lib/utils/k_dimensions.dart` | `KDimensions` | Standard dimensions |
| `lib/utils/language_string.dart` | `Language` | 150+ translatable strings |
| `lib/utils/lazy_loader.dart` | `ShimmerLoader` | Shimmer loading |
| `lib/utils/extensions.dart` | (Extensions) | Dart extensions |
| `lib/utils/convert_data_type.dart` | (Converters) | Type conversions |
| `lib/utils/app_style.dart` | `AppStyle` | Text styles |
| `lib/utils/notifications.dart` | (Functions) | Push notification setup |

### Reusable Widgets
| File Path | Class | Role |
|-----------|-------|------|
| `lib/widgets/primary_button.dart` | `PrimaryButton` | Main action button |
| `lib/widgets/custom_image.dart` | `CustomImage` | Image loader (SVG/network/file) |
| `lib/widgets/favorite_button.dart` | `FavoriteButton` | Wishlist toggle |
| `lib/widgets/error_screen.dart` | `ErrorScreen` | Error + retry |
| `lib/widgets/rounded_app_bar.dart` | `RoundedAppBar` | Rounded app bar |
| `lib/widgets/app_bar_leading.dart` | `AppbarLeading` | Back button |
| `lib/widgets/bottom_popup_card.dart` | `BottomPopupCard` | Bottom sheet |
| `lib/widgets/custom_text.dart` | `CustomText` | Styled text |
| `lib/widgets/custom_rating.dart` | `CustomRatingBar` | Star rating |
| `lib/widgets/custom_radio_button.dart` | `CustomRadioButton` | Radio button |
| `lib/widgets/field_error_text.dart` | `ErrorText` | Form error text |
| `lib/widgets/feedback_success.dart` | `FeedbackSuccess` | Success message |
| `lib/widgets/please_sign_in_widget.dart` | `PleaseSignInWidget` | Sign in prompt |
| `lib/widgets/toggle_button_component.dart` | `ToggleButtonComponent` | Toggle button |
| `lib/widgets/toggle_button_scroll_component.dart` | `ToggleButtonScrollComponent` | Scrollable toggle |
| `lib/widgets/circuler_progress_custom_painter.dart` | `CircleProgressCustomPainter` | Circular progress |
| `lib/widgets/capitalized_word.dart` | (Widget) | Text capitalization |
| `lib/widgets/shimmer_loader.dart` | `ShimmerLoader` | Shimmer skeleton |

### Other
| File Path | Class | Role |
|-----------|-------|------|
| `lib/generated/assets.dart` | `Assets` | Asset path constants |
| `lib/dummy_data/all_dummy_data.dart` | (Data) | Sample data |

---

## UI Redesign Workflow

When redesigning each screen:
1. **Ask for screen name** → I provide the file table above
2. **You provide updated code** → I check functionality preservation and replace files
3. **Rules**:
   - Only UI/widget files change (screens + components)
   - Models, repositories, cubits/blocs stay UNCHANGED
   - All BLoC listeners, state checks, and API calls preserved
   - Navigation routes preserved
   - Widget tree structure can change but data flow stays same
