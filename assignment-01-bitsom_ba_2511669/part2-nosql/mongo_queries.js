// ============================================================
// Part 2 — MongoDB Operations
// File: part2-nosql/mongo_queries.js
// Run in: mongosh
// ============================================================

use("ecommerce");

// OP1: insertMany() — insert all 3 documents from sample_documents.json
db.products.insertMany([
  {
    _id: "prod_elec_001",
    category: "Electronics",
    product_name: "Samsung Galaxy S24 Ultra",
    brand: "Samsung",
    price: 124999,
    currency: "INR",
    in_stock: true,
    stock_quantity: 45,
    specifications: {
      display: "6.8 inch Dynamic AMOLED 2X",
      processor: "Snapdragon 8 Gen 3",
      ram_gb: 12,
      storage_gb: 256,
      battery_mah: 5000,
      camera_mp: 200,
      voltage: "5V / 45W fast charging",
      warranty_years: 1,
      water_resistance: "IP68"
    },
    tags: ["smartphone", "android", "flagship", "5G"],
    ratings: { average: 4.6, total_reviews: 2341 },
    added_on: "2024-01-20"
  },
  {
    _id: "prod_cloth_001",
    category: "Clothing",
    product_name: "Men's Slim Fit Formal Shirt",
    brand: "Raymond",
    price: 1899,
    currency: "INR",
    in_stock: true,
    stock_quantity: 200,
    specifications: {
      fabric: "Cotton-Polyester Blend",
      fit_type: "Slim Fit",
      sleeve: "Full Sleeve",
      occasion: "Formal",
      care_instructions: ["Machine wash cold", "Do not bleach", "Iron on medium heat"],
      available_sizes: ["S", "M", "L", "XL", "XXL"],
      available_colors: ["White", "Light Blue", "Pale Grey"]
    },
    tags: ["formal", "shirt", "office-wear", "men"],
    ratings: { average: 4.2, total_reviews: 876 },
    added_on: "2023-11-10"
  },
  {
    _id: "prod_groc_001",
    category: "Groceries",
    product_name: "Organic Cold-Pressed Coconut Oil",
    brand: "Organic India",
    price: 449,
    currency: "INR",
    in_stock: true,
    stock_quantity: 530,
    specifications: {
      weight_ml: 500,
      type: "Cold Pressed, Virgin",
      organic_certified: true,
      expiry_date: new Date("2025-06-30"),
      manufactured_on: new Date("2024-06-30"),
      shelf_life_months: 12,
      storage_instructions: "Store in a cool, dry place away from direct sunlight",
      nutritional_info: {
        serving_size_ml: 14,
        calories_per_serving: 120,
        total_fat_g: 14,
        saturated_fat_g: 12,
        trans_fat_g: 0,
        cholesterol_mg: 0,
        sodium_mg: 0
      },
      allergens: []
    },
    tags: ["oil", "organic", "cooking", "vegan", "cold-pressed"],
    ratings: { average: 4.8, total_reviews: 1203 },
    added_on: "2024-07-01"
  }
]);

// OP2: find() — retrieve all Electronics products with price > 20000
db.products.find(
  {
    category: "Electronics",
    price: { $gt: 20000 }
  },
  {
    product_name: 1,
    brand: 1,
    price: 1,
    category: 1
  }
);

// OP3: find() — retrieve all Groceries expiring before 2025-01-01
db.products.find(
  {
    category: "Groceries",
    "specifications.expiry_date": { $lt: new Date("2025-01-01") }
  },
  {
    product_name: 1,
    "specifications.expiry_date": 1,
    price: 1
  }
);

// OP4: updateOne() — add a "discount_percent" field to a specific product
db.products.updateOne(
  { _id: "prod_elec_001" },
  { $set: { discount_percent: 10 } }
);

// OP5: createIndex() — create an index on category field and explain why
// Reason: The 'category' field is the most common filter used in product
// searches (e.g., OP2 queries all Electronics). Without an index, MongoDB
// performs a full collection scan (O(n)) on every such query. A B-tree
// index on 'category' reduces lookup to O(log n), which is critical as
// the catalog grows to millions of products. It also benefits sort
// operations and aggregation pipelines that group by category.
db.products.createIndex(
  { category: 1 },
  { name: "idx_category", background: true }
);
