# OUI Product Details — Dynamic API Documentation

> **Base URL:** `https://oui.corescent.in/api/`

This document covers all API endpoints powering the OUI product details screen. All data is fully dynamic from the backend — no hardcoded content.

---

## Table of Contents

1. [Product Details (Main API)](#1-product-details-main-api)
2. [Submit Review API](#2-submit-review-api)
3. [Add to Cart API](#3-add-to-cart-api)
4. [Wishlist API](#4-wishlist-api)
5. [Section Layout & Data Mapping](#5-section-layout--data-mapping)
6. [Models Reference](#6-models-reference)

---

## 1. Product Details (Main API)

**Endpoint:** `GET /api/product/{slug}`  
**Auth:** None  
**Used by:** `ProductDetailsCubit` → `ProductDetailsRepository` → `RemoteDataSource`

### Response Schema

```json
{
  "id": int,
  "tags": "string (comma-separated)",
  "totalProductReviewQty": int,
  "is_seller_product": bool,
  "product": ProductDetailsProductModel,
  "gellery": [GalleryModel],
  "relatedProducts": [ProductDetailsProductModel],
  "productReviews": [DetailsProductReviewModel],
  "this_seller_products": [ProductDetailsProductModel],
  "sellerTotalProducts": int,
  "sellerReviewQty": int,
  "sellerTotalReview": int,
  "seller": {
    "user": SellerInfoProfile
  }
}
```

### Key Fields

| Field | Type | Description |
|---|---|---|
| `product` | Object | Full product details (name, price, offerPrice, longDescription, thumbImage, category, variants, etc.) |
| `gellery` | Array | Additional product images for the image carousel |
| `relatedProducts` | Array | Related products for "Complete the Look" section |
| `productReviews` | Array | User reviews with rating, text, user info, date |
| `this_seller_products` | Array | Other products from the same seller |
| `seller.user` | Object | Seller profile (name, image, address) |
| `tags` | String | Comma-separated product tags |
| `is_seller_product` | Bool | Whether the product belongs to a seller |
| `sellerTotalProducts` | Int | Total products from this seller |
| `sellerReviewQty` | Int | Seller's average rating |
| `sellerTotalReview` | Int | Total reviews for this seller |
| `totalProductReviewQty` | Int | Total review count for this product |

---

## 2. Submit Review API

**Endpoint:** `POST /api/user/store-product-review?token={token}`  
**Auth:** Bearer token required  
**Used by:** Review submission flow

### Request Body

```json
{
  "product_id": int,
  "rating": int (1-5),
  "review": "string"
}
```

---

## 3. Add to Cart API

**Endpoint:** `POST /api/add-to-cart`  
**Auth:** Token (optional, uses local cart if unauthenticated)  
**Used by:** `AddToCartCubit`

### Request Body

```json
{
  "product_id": int,
  "quantity": int,
  "token": "string",
  "slug": "string",
  "image": "string",
  "variant_items": [ActiveVariantModel]
}
```

---

## 4. Wishlist API

| Action | Method | Endpoint |
|---|---|---|
| Get wishlist | GET | `/api/user/wishlist?token={token}` |
| Add to wishlist | GET | `/api/user/add-to-wishlist/{id}?token={token}` |
| Remove from wishlist | GET | `/api/user/delete-wishlist/{id}?token={token}` |
| Clear wishlist | GET | `/api/user/clear-wishlist?token={token}` |

---

## 5. Section Layout & Data Mapping

The product details screen displays these sections in order:

### Image Header (ProductHeaderComponent)
- **Data:** `product.thumbImage` + `gellery[].image`
- **Overlay:** `product.category.name`, `product.name`, `product.price`/`product.offerPrice`
- **Wishlist:** `FavoriteButton` using `product.id`

### App Bar Overlay
- Static "COLLECTION" title
- Share button (shares product URL: `https://oui.corescent.in/product/{slug}`)
- Cart badge (from `CartCubit.cartCount`)

### Tab Bar (3 tabs always visible)
1. **Description** → `product.longDescription` (HTML rendered)
2. **Reviews** → `productReviews[]` array
3. **Seller Info** → `sellerProfile`, `sellerTotalProducts`, `sellerReviewQty`, `sellerTotalReview`, `tags`, `this_seller_products`

### Description Tab
- **HTML Content:** `product.longDescription` rendered via `flutter_html`

### Reviews Tab
- **Rating Summary:** `totalProductReviewQty`, average computed from `productReviews`
- **Review Cards:** Each shows `rating`, `review` text, `user.name`, `createdAt`
- **Pagination:** "LOAD MORE REVIEWS" (client-side, shows 3 initially)

### Seller Info Tab
- **Profile:** `sellerProfile.name`, `sellerProfile.image`, `sellerProfile.address`
- **Stats Grid:** `sellerTotalProducts`, category name, `sellerReviewQty` (rating), `sellerTotalReview`
- **Tags:** `tags` (split by comma)
- **Seller Products Grid:** `this_seller_products[]` (max 4)

### Related Products
- **Data:** `relatedProducts[]`
- **Header:** "COMPLETE THE LOOK" / "Curated Essentials"

### Bottom Bar
- **ADD TO CART** → Opens variant selection bottom sheet
- **TRY ON (AR)** → Navigates to AR try-on (clothing categories only)

---

## 6. Models Reference

### ProductDetailsProductModel
Key fields: `id`, `name`, `slug`, `price`, `offerPrice`, `thumbImage`, `longDescription`, `shortDescription`, `category` (CategoryModel), `activeVariantModel[]`, `qty` (stock)

### GalleryModel
Fields: `id`, `image`, `productId`

### DetailsProductReviewModel
Fields: `id`, `rating`, `review`, `createdAt`, `user` (UserModel with `name`, `image`)

### SellerInfoProfile
Fields: `id`, `name`, `email`, `image`, `address`

### ActiveVariantModel
Fields: `id`, `name`, `activeVariantsItems[]` (each with `id`, `name`, `price`)

---

## Dynamic Data Verification

All product details screen content is **100% dynamic from the API**:

| Section | Source | Status |
|---|---|---|
| Product images | `gellery` + `product.thumbImage` | ✅ Dynamic |
| Product name/price | `product.name`, `product.price` | ✅ Dynamic |
| Category label | `product.category.name` | ✅ Dynamic |
| Description HTML | `product.longDescription` | ✅ Dynamic |
| Reviews list | `productReviews` | ✅ Dynamic |
| Rating summary | `totalProductReviewQty` + computed avg | ✅ Dynamic |
| Seller profile | `seller.user` | ✅ Dynamic |
| Seller stats | `sellerTotalProducts`, `sellerReviewQty`, `sellerTotalReview` | ✅ Dynamic |
| Tags | `tags` | ✅ Dynamic |
| Related products | `relatedProducts` | ✅ Dynamic |
| Seller products | `this_seller_products` | ✅ Dynamic |
| Cart count | `CartCubit` state | ✅ Dynamic |
| Wishlist state | `WishListCubit` state | ✅ Dynamic |

**No new backend endpoints are needed.** The existing `GET /api/product/{slug}` provides all required data.
