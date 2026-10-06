const { Client } = require('pg');

const connectionString = 'postgresql://postgres:4aPIXAJ9HOvSC04f@db.uretwlyfrucmtihkdsww.supabase.co:5432/postgres';

async function runMigration() {
  const client = new Client({ connectionString });
  try {
    await client.connect();
    console.log("Connected to Supabase.");

    const query = `
      ALTER TABLE boutiques 
      ADD COLUMN IF NOT EXISTS address TEXT,
      ADD COLUMN IF NOT EXISTS phone TEXT,
      ADD COLUMN IF NOT EXISTS currency TEXT DEFAULT 'USD';
    `;
    
    await client.query(query);
    console.log("Migration successful: Added address, phone, currency to boutiques.");
  } catch (err) {
    console.error("Migration error:", err);
  } finally {
    await client.end();
  }
}

runMigration();
