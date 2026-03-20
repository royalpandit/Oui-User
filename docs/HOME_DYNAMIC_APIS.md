# OUI Home Screen — Dynamic API Documentation

> **Base URL:** `https://oui.corescent.in/api/`

This document covers all API endpoints powering the OUI home screen, including the newly added dynamic content endpoints and the existing home data API.

---

## Table of Contents

1. [Home Data (Main API)](#1-home-data-main-api)
2. [Home Quotes API](#2-home-quotes-api) *(new)*
3. [Home Trending API](#3-home-trending-api) *(new)*
4. [Home Featured Highlight API](#4-home-featured-highlight-api) *(new)*
5. [Section Titles API](#5-section-titles-api)
6. [Visibility Flags Reference](#6-visibility-flags-reference)
7. [Fallback Behavior](#7-fallback-behavior)
8. [Models Reference](#8-models-reference)
9. [Backend CRUD Requirements](#9-backend-crud-requirements)

---

## 1. Home Data (Main API)

**Endpoint:** `GET /api/`  
**Auth:** None  
**Used by:** `HomeControllerCubit` → `HomeRepository` → `RemoteDataSource`

### Response Schema

```json
{
  "sliders": [SliderModel],
  "sliderVisibilty": bool | int | "1",
  "popularCategories": [{ "category": CategoryModel }],
  "popularCategoryVisibilty": bool | int | "1",
  "homepage_categories": [HomePageCategoriesModel],
  "section_title": [SectionTitleModel],
  "flashSale": FlashSaleModel,
  "featuredCategoryProducts": [ProductModel],  // -> "Featured" section
  "featuredProductVisibility": bool | int | "1",
  "newArrivalProducts": [ProductModel],
  "newArrivalProductVisibility": bool | int | "1",
  "topRatedProducts": [ProductModel],
  "topRatedVisibility": bool | int | "1",
  "bestProducts": [ProductModel],
  "bestProductVisibility": bool | int | "1",
  "brands": [BrandModel],
  "brandVisibility": bool | int | "1",
  "sellers": [HomeSellerModel],
  "sellerVisibility": bool | int | "1",

  // Dynamic (new fields — optional, with fallback defaults)
  "quotes": [HomeQuoteModel] | null,
  "quoteVisibility": bool | null,
  "trendingProducts": [ProductModel] | null,
  "trendingVisibility": bool | null,
  "trendingSectionTitle": string | null,
  "featuredHighlightVisibility": bool | null,
  "featuredHighlightSectionTitle": string | null,

  // Banners
  "banner_one": BannerModel | null,
  "banner_two": BannerModel | null,
  "banner_three": BannerModel | null,
  "banner_four": BannerModel | null,
  "flashSaleSidebarBanner": BannerModel | null,
  "popularCategorySidebarBanner": string | null
}
```

---

## 2. Home Quotes API

**Endpoint:** `GET /api/home-quotes`  
**Constant:** `RemoteUrls.homeQuotesUrl`  
**Auth:** None  
**Status:** *Planned — backend CRUD needed*

### Purpose

Provides inspirational/fashion quotes displayed between product sections on the home screen.

### Expected Response

```json
{
  "quotes": [
    {
      "id": 1,
      "text": "Style is a way to say who you are\nwithout having to speak.",
      "author": "Rachel Zoe",
      "status": 1
    },
    {
      "id": 2,
      "text": "Elegance is the only beauty\nthat never fades.",
      "author": "Audrey Hepburn",
      "status": 1
    }
  ],
  "quoteVisibility": true
}
```

### Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | int | yes | Unique quote ID |
| `text` | string | yes | Quote text (supports `\n` line breaks) |
| `author` | string | no | Attribution text (shown as "— Author") |
| `status` | int | no | 1 = active, 0 = inactive (default: 1) |

### Client Behavior

- If API returns `null` or fails, **5 hardcoded fallback quotes** are used (see `HomeQuoteModel.defaults`)
- Quotes are distributed across the home screen at indices 0–4 between sections
- `quoteVisibility` defaults to `true` if not provided

---

## 3. Home Trending API

**Endpoint:** `GET /api/home-trending`  
**Constant:** `RemoteUrls.homeTrendingUrl`  
**Auth:** None  
**Status:** *Planned — backend CRUD needed*

### Purpose

Supplies the "Trending Now" auto-scrolling product strip on the home screen.

### Expected Response

```json
{
  "trendingProducts": [ProductModel, ...],
  "trendingVisibility": true,
  "trendingSectionTitle": "Trending Now"
}
```

### Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `trendingProducts` | ProductModel[] | no | Product list for the strip |
| `trendingVisibility` | bool/int/string | no | Controls section visibility (default: `true`) |
| `trendingSectionTitle` | string | no | Section heading text (default: `"Trending Now"`) |

### Client Behavior

- If `trendingProducts` is null, falls back to `topRatedProducts` from the main home API
- Rendered by `AutoScrollProductStrip` — auto-scrolls horizontally using `AnimationController` ticker
- Uses `ClampingScrollPhysics` for Android-native scroll feel

---

## 4. Home Featured Highlight API

**Endpoint:** `GET /api/home-featured-highlight`  
**Constant:** `RemoteUrls.homeFeaturedHighlightUrl`  
**Auth:** None  
**Status:** *Planned — backend CRUD needed*

### Purpose

Controls the "Spotlight" featured highlight card — a large hero card showcasing a single product.

### Expected Response

```json
{
  "featuredHighlightVisibility": true,
  "featuredHighlightSectionTitle": "Spotlight"
}
```

### Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `featuredHighlightVisibility` | bool/int/string | no | Section visibility (falls back to `featuredProductVisibility`) |
| `featuredHighlightSectionTitle` | string | no | Section heading (default: `"Spotlight"`) |

### Client Behavior

- Product data comes from `featuredCategoryProducts[0]` in the main home API
- If visibility is off or no featured products exist, section is hidden
- Rendered by `FeaturedHighlightCard` — a 420px tall hero card with gradient overlay

---

## 5. Section Titles API

**Endpoint:** `GET /api/section_title`  
**Constant:** `RemoteUrls.sectionTitle`  
**Auth:** None

### Response Schema

```json
[
  {
    "key": "popular_category",
    "default": "Popular Categories",
    "custom": "Our Collections"
  },
  {
    "key": "flash_sale",
    "default": "Flash Sale",
    "custom": null
  }
]
```

### Section Title Keys (used in home screen)

| Index | Key | Default Title |
|-------|-----|---------------|
| 0 | popular_category | Popular Category |
| 1 | flash_sale | Flash Sale |
| 2 | new_arrival | New Arrival |
| 3 | featured_products | Featured Products |
| 4 | top_rated_products | Top Rated Products |
| 5 | best_products | Best Products |
| 6 | best_seller | Best Seller |
| 7 | brands | Brands |

The `custom` value takes precedence over `default` when displayed.

---

## 6. Visibility Flags Reference

All visibility flags can be `bool`, `int` (0/1), or `String` ("0"/"1"). The client normalizes these via `_isVisible()` helper:

```dart
bool _isVisible(dynamic flag) {
  if (flag == true || flag == 1 || flag == '1') return true;
  return false;
}
```

| Flag | Controls | Default |
|------|----------|---------|
| `sliderVisibilty` | Hero slider banner | `false` |
| `popularCategoryVisibilty` | Category circles + product list | `false` |
| `brandVisibility` | Brands section | `false` |
| `topRatedVisibility` | Top-rated products grid | `false` |
| `sellerVisibility` | Sellers horizontal list | `false` |
| `featuredProductVisibility` | Featured products component | `false` |
| `newArrivalProductVisibility` | New arrivals section | `false` |
| `bestProductVisibility` | Best products grid | `false` |
| `quoteVisibility` | Quote sections between content | `true` |
| `trendingVisibility` | Trending auto-scroll strip | `true` |
| `featuredHighlightVisibility` | Spotlight hero card | `true` |

> **Note:** New dynamic flags (`quoteVisibility`, `trendingVisibility`, `featuredHighlightVisibility`) default to `true` — they display unless explicitly disabled.

---

## 7. Fallback Behavior

| Feature | API Field | Fallback |
|---------|-----------|----------|
| Quotes | `quotes` | 5 hardcoded fashion quotes (`HomeQuoteModel.defaults`) |
| Trending Products | `trendingProducts` | Uses `topRatedProducts` array |
| Trending Title | `trendingSectionTitle` | `"Trending Now"` |
| Featured Highlight Visibility | `featuredHighlightVisibility` | Falls back to `featuredProductVisibility` |
| Featured Highlight Title | `featuredHighlightSectionTitle` | `"Spotlight"` |
| Quote Visibility | `quoteVisibility` | `true` |
| Trending Visibility | `trendingVisibility` | `true` |

This ensures the home screen displays rich content even before backend APIs for new features are implemented.

---

## 8. Models Reference

### HomeQuoteModel

**File:** `lib/modules/home/model/home_quote_model.dart`

```dart
class HomeQuoteModel extends Equatable {
  final int id;
  final String text;       // Supports \n for line breaks
  final String? author;    // Optional attribution
  final int status;        // 1 = active, 0 = inactive
}
```

### ProductModel (key fields)

**File:** `lib/modules/home/model/product_model.dart`

Used across trending products, featured highlight, popular products, etc.

| Field | Type | Description |
|-------|------|-------------|
| `id` | int | Product ID |
| `name` | String | Product name |
| `slug` | String | URL slug for navigation |
| `thumbImage` | String | Thumbnail image path |
| `price` | double | Base price |
| `offerPrice` | double | Discounted price |
| `rating` | double | Average rating |
| `shortDescription` | String | Brief description |
| `productVariants` | List | Active variants |

### SectionTitleModel

**File:** `lib/modules/home/model/section_title_model.dart`

| Field | Type | Description |
|-------|------|-------------|
| `key` | String | Section identifier |
| `defaultTitle` | String? | Default section name |
| `custom` | String? | Admin-customized name |

---

## 9. Backend CRUD Requirements

The following backend tables/endpoints need to be created to support the new dynamic features:

### home_quotes table

```sql
CREATE TABLE home_quotes (
  id          INT PRIMARY KEY AUTO_INCREMENT,
  text        TEXT NOT NULL,
  author      VARCHAR(255) NULL,
  status      TINYINT DEFAULT 1,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

**Admin CRUD Endpoints:**
- `GET /api/home-quotes` — List all active quotes
- `POST /api/home-quotes` — Create new quote
- `PUT /api/home-quotes/{id}` — Update quote
- `DELETE /api/home-quotes/{id}` — Delete quote

### home_settings table (for visibility/titles)

```sql
CREATE TABLE home_settings (
  id    INT PRIMARY KEY AUTO_INCREMENT,
  key   VARCHAR(100) UNIQUE NOT NULL,
  value TEXT NOT NULL
);

-- Seed data:
INSERT INTO home_settings (key, value) VALUES
  ('quoteVisibility', '1'),
  ('trendingVisibility', '1'),
  ('trendingSectionTitle', 'Trending Now'),
  ('featuredHighlightVisibility', '1'),
  ('featuredHighlightSectionTitle', 'Spotlight');
```

### home_trending_products table (or use tagging)

Option A: Dedicated table with product_id foreign keys  
Option B: Add `is_trending` boolean column to products table  
Option C: Use the existing `topRatedProducts` query and expose via new endpoint

**Admin Endpoint:**
- `GET /api/home-trending` — Returns trending product list + settings
- `POST /api/home-trending/products` — Add/remove products from trending

---

## Home Screen Section Order

The home screen renders sections in this fixed order:

1. **HomeAppBar** — Search bar + cart icon
2. **OfferBannerSlider** — Hero slider (if `sliderVisibilty`)
3. **CategoryGridView** — Category circles (if `popularCategoryVisibilty`)
4. **QuoteSection #0** — First quote (if `quoteVisibility`)
5. **CategoryAndListComponent** — Category products (if `popularCategoryVisibilty`)
6. **FeaturedHighlightCard** — Spotlight hero (if `featuredHighlightVisibility` + products exist)
7. **QuoteSection #1** — Second quote
8. **FlashSaleComponent** — Flash sale countdown + products
9. **HotDealBannerSlider** — Two-column banners (if both exist)
10. **AutoScrollProductStrip** — Trending strip (if `trendingVisibility` + products exist)
11. **QuoteSection #2** — Third quote
12. **NewArrivalComponent** — New arrivals (if `newArrivalProductVisibility`)
13. **HorizontalProductComponent** — Top-rated products (if `topRatedVisibility`)
14. **QuoteSection #3** — Fourth quote
15. **BestSellerGridView** — Best products grid (if `bestProductVisibility`)
16. **QuoteSection #4** — Fifth quote
17. **Bottom spacing** (80px)
