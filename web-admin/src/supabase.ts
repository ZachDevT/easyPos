import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://uretwlyfrucmtihkdsww.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVyZXR3bHlmcnVjbXRpaGtkc3d3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTEyNzgwNTIsImV4cCI6MjEwNjg1NDA1Mn0.XoXM8imEbMref3OWihK9kcr9yWJdJo3htq53ebdfgiA'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
