import { createClient } from '@supabase/supabase-js';

const HOMEKEEP_SUPABASE_URL = 'https://bmkjvbuqnmxgqzqwxsvl.supabase.co';
const HOMEKEEP_SUPABASE_PUBLISHABLE_KEY = 'sb_publishable_6GAvE3vt0gHC9VTSTCF1Fw_KLRHudM8';

export function createBrowserSupabase() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL || HOMEKEEP_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY || HOMEKEEP_SUPABASE_PUBLISHABLE_KEY;
  return createClient(url, key);
}
