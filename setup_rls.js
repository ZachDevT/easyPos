const { Client } = require('pg');

const client = new Client({
  connectionString: 'postgresql://postgres:4aPIXAJ9HOvSC04f@db.uretwlyfrucmtihkdsww.supabase.co:5432/postgres'
});

async function setupRLS() {
  await client.connect();
  
  const schema = `
    -- BOUTIQUES POLICIES
    DROP POLICY IF EXISTS "Allow authenticated inserts" ON boutiques;
    CREATE POLICY "Allow authenticated inserts" ON boutiques FOR INSERT TO authenticated WITH CHECK (true);

    DROP POLICY IF EXISTS "Allow users to read their boutique" ON boutiques;
    CREATE POLICY "Allow users to read their boutique" ON boutiques FOR SELECT TO authenticated USING (true);
    
    DROP POLICY IF EXISTS "Allow users to update their boutique" ON boutiques;
    CREATE POLICY "Allow users to update their boutique" ON boutiques FOR UPDATE TO authenticated USING (true);

    -- PROFILES POLICIES
    DROP POLICY IF EXISTS "Allow users to insert their own profile" ON profiles;
    CREATE POLICY "Allow users to insert their own profile" ON profiles FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);

    DROP POLICY IF EXISTS "Allow users to read their own profile" ON profiles;
    CREATE POLICY "Allow users to read their own profile" ON profiles FOR SELECT TO authenticated USING (auth.uid() = id);

    -- GENERAL TABLES (Products, Sales, etc.)
    -- For the MVP, we allow authenticated users to read/write. 
    -- The frontend filters by boutique_id automatically.
    
    DROP POLICY IF EXISTS "Enable all operations for authenticated users on products" ON products;
    CREATE POLICY "Enable all operations for authenticated users on products" ON products FOR ALL TO authenticated USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Enable all operations for authenticated users on sales" ON sales;
    CREATE POLICY "Enable all operations for authenticated users on sales" ON sales FOR ALL TO authenticated USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Enable all operations for authenticated users on sale_items" ON sale_items;
    CREATE POLICY "Enable all operations for authenticated users on sale_items" ON sale_items FOR ALL TO authenticated USING (true) WITH CHECK (true);
    
    DROP POLICY IF EXISTS "Enable all operations for authenticated users on categories" ON categories;
    CREATE POLICY "Enable all operations for authenticated users on categories" ON categories FOR ALL TO authenticated USING (true) WITH CHECK (true);
    
    DROP POLICY IF EXISTS "Enable all operations for authenticated users on brands" ON brands;
    CREATE POLICY "Enable all operations for authenticated users on brands" ON brands FOR ALL TO authenticated USING (true) WITH CHECK (true);
    
    DROP POLICY IF EXISTS "Enable all operations for authenticated users on customers" ON customers;
    CREATE POLICY "Enable all operations for authenticated users on customers" ON customers FOR ALL TO authenticated USING (true) WITH CHECK (true);
  `;
  
  try {
    await client.query(schema);
    console.log('Row Level Security (RLS) policies successfully applied!');
  } catch(e) {
    console.error('Error applying RLS:', e);
  } finally {
    await client.end();
  }
}

setupRLS();
