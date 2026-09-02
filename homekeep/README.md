# UpkeepCue

Household maintenance reminder MVP built with Next.js and Supabase.

## Included
- Magic-link email authentication
- Persistent maintenance tasks when Supabase is configured
- Demo mode when not signed in
- Recurring maintenance schema
- Row-level security policies
- Household/member schema ready for family sharing
- Subscription entitlement table ready for Stripe

## Setup
1. Create a dedicated Supabase project.
2. Run `supabase/migrations/0001_homekeep.sql` in the Supabase SQL editor.
3. Copy `.env.example` to `.env.local` and add the project URL and publishable key.
4. Run `npm install` and `npm run dev` from the `homekeep` folder.
5. Deploy the `homekeep` folder to Vercel and set the same environment variables.

Never expose a Supabase secret/service-role key in browser code.
