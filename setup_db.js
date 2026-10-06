const { Client } = require('pg');

const client = new Client({
  connectionString: 'postgresql://postgres:4aPIXAJ9HOvSC04f@db.uretwlyfrucmtihkdsww.supabase.co:5432/postgres'
});

async function setup() {
  await client.connect();
  
  const schema = `
    -- Enable UUID extension
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

    -- Boutiques
    CREATE TABLE IF NOT EXISTS boutiques (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        name TEXT NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

    -- Profiles (extends auth.users)
    CREATE TABLE IF NOT EXISTS profiles (
        id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
        boutique_id UUID REFERENCES boutiques(id) ON DELETE CASCADE,
        role TEXT DEFAULT 'cashier',
        name TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

    -- Categories
    CREATE TABLE IF NOT EXISTS categories (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        boutique_id UUID REFERENCES boutiques(id) ON DELETE CASCADE,
        name TEXT NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

    -- Brands
    CREATE TABLE IF NOT EXISTS brands (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        boutique_id UUID REFERENCES boutiques(id) ON DELETE CASCADE,
        category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
        name TEXT NOT NULL
    );

    -- Products
    CREATE TABLE IF NOT EXISTS products (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        boutique_id UUID REFERENCES boutiques(id) ON DELETE CASCADE,
        name TEXT NOT NULL,
        barcode TEXT,
        sku TEXT,
        category_id UUID REFERENCES categories(id),
        brand_id UUID REFERENCES brands(id),
        purchase_price NUMERIC DEFAULT 0,
        selling_price NUMERIC DEFAULT 0,
        stock_quantity NUMERIC DEFAULT 0,
        minimum_stock NUMERIC DEFAULT 0,
        unit TEXT DEFAULT 'pièce',
        image_path TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

    -- Customers
    CREATE TABLE IF NOT EXISTS customers (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        boutique_id UUID REFERENCES boutiques(id) ON DELETE CASCADE,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        total_credit NUMERIC DEFAULT 0,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

    -- Sales
    CREATE TABLE IF NOT EXISTS sales (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        boutique_id UUID REFERENCES boutiques(id) ON DELETE CASCADE,
        sale_number TEXT NOT NULL,
        date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        subtotal NUMERIC NOT NULL,
        discount NUMERIC DEFAULT 0,
        total NUMERIC NOT NULL,
        payment_method TEXT DEFAULT 'ESPÈCES',
        customer_id UUID REFERENCES customers(id) ON DELETE SET NULL
    );

    -- Sale Items
    CREATE TABLE IF NOT EXISTS sale_items (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        sale_id UUID REFERENCES sales(id) ON DELETE CASCADE,
        product_id UUID REFERENCES products(id),
        quantity NUMERIC NOT NULL,
        unit_price NUMERIC NOT NULL,
        total NUMERIC NOT NULL
    );

    -- Enable RLS
    ALTER TABLE boutiques ENABLE ROW LEVEL SECURITY;
    ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
    ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
    ALTER TABLE brands ENABLE ROW LEVEL SECURITY;
    ALTER TABLE products ENABLE ROW LEVEL SECURITY;
    ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
    ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
    ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;
    
    -- Basic Policy Template (Users can only see data for their boutique)
    -- We can expand these policies later.
  `;
  
  await client.query(schema);
  console.log('SaaS Schema created successfully in Supabase!');
  await client.end();
}

setup().catch(e => {
    console.error('Error:', e);
    process.exit(1);
});
