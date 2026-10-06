import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://uretwlyfrucmtihkdsww.supabase.co'
const supabaseAnonKey = 'sb_publishable_Q_doQGOmePgqgywsqia8FQ_4cPhc7MN'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
