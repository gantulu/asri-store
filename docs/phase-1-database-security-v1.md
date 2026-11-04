# Phase 1 — Database & Security V1 Implementation

**Repository:** `gantulu/asri-store`  
**Baseline:** Requirement V1.1 + Phase 1 Design Specification V1  
**Status:** Implemented in repository branch; not applied to a Supabase project.

## Scope

This change adds an additive database migration for the Phase 1 transactional data model. It deliberately does not:
- alter or delete legacy `public.orders` or `public.order_items`;
- convert existing product prices into IDR;
- grant browser roles access to private transactional tables;
- insert or promote any administrator;
- enable checkout;
- apply SQL to a live Supabase database;
- deploy Edge Functions or change secrets.

## Migration

`supabase/migrations/202611040001_phase1_database_security_v1.sql`

The migration:
- creates the `private` schema;
- adds nullable `price_idr` and `compare_at_price_idr` columns to `public.products`;
- creates private tables for admins, orders, order items, payments, payment events, inventory movements, guest access tokens, checkout idempotency, and store settings;
- enables RLS on every private table without adding client-facing policies;
- revokes direct `anon` and `authenticated` table access;
- creates the initial store settings row with checkout disabled and shipping fee unset.

## Locked design decisions

| Decision | Value |
|---|---|
| Payment retry | Create a new order after failed/expired payment |
| Idempotency retention | 24 hours |
| Guest token delivery | Show once on confirmation |
| Guest token TTL | 7 days |
| Edge Function database access | Private schema + server-side PostgreSQL connection / controlled private functions |
| Currency | IDR only |
| Tax | None |
| Coupon | Out of V1 |

## Important implementation constraints

### Product price migration

Existing `products.price` and `compare_at_price` are retained for compatibility. The new IDR columns are nullable because the existing seed values have no verified IDR mapping. Checkout must remain disabled until every sellable product has an approved IDR price and the application reads the IDR columns.

### Shipping configuration

`private.store_settings.flat_shipping_fee` is intentionally NULL and `checkout_enabled` is false. Set a business-approved shipping fee and complete checkout verification before enabling checkout.

### Admin bootstrap

`private.admin_users` starts empty. Admin membership must be populated through a trusted, reviewed administrative procedure after verifying the intended Auth user IDs. Do not copy the legacy `profiles.is_admin` values automatically.

### Private schema access

The private schema is not intended for PostgREST/Data API exposure. Edge Functions must connect server-side using a Supabase PostgreSQL connection string held only in project secrets. For serverless/Edge workloads, use the Supabase shared pooler in transaction mode, keep the client pool small, disable prepared statements where required by the driver, and require TLS. Never place a database URL or service-role credential in a `VITE_*` variable.

The migration does not grant direct DML to `service_role`; privileged access should be mediated by narrowly scoped private database functions and verified server-side authorization.

### Not yet implemented by this migration

The following are separate implementation work and must be completed before checkout/payment is enabled:
- atomic checkout function with stock locking, authoritative price calculation, inventory ledger, guest-token hash, and idempotency behavior;
- private payment transition and stock-restoration functions;
- Duitku Create Invoice and callback Edge Functions;
- guest order status endpoint;
- admin authorization Edge Functions;
- cleanup job for expired idempotency rows and guest tokens;
- pgTAP tests for grants, RLS, function execution, idempotency, stock concurrency, and payment callback replay.

## Apply and verification procedure

This file is a repository migration only. Do not apply it automatically.

Before applying to a target project:
1. Back up the database and inspect the live schema/grants/policies.
2. Confirm the project supports the required `private` schema and server-side database connection approach.
3. Validate the migration using the project's Supabase CLI workflow.
4. Review the SQL diff and run database advisors.
5. Apply to a non-production environment first.
6. Verify table ownership, RLS, grants, Data API exposure, and catalog compatibility.
7. Keep checkout disabled until IDR prices, shipping fee, admin identity, Edge Functions, and integration tests are complete.

## Official references

- [Supabase securing your data](https://supabase.com/docs/guides/database/secure-data)
- [Supabase connect to Postgres](https://supabase.com/docs/guides/database/connecting-to-postgres)
- [Supabase connect to Postgres from Edge Functions](https://supabase.com/docs/guides/functions/connect-to-postgres)
- [Supabase Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security)
- [Supabase database functions](https://supabase.com/docs/guides/database/functions)
