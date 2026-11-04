-- Phase 1: Database & Security V1
-- Repository: gantulu/asri-store
-- Additive migration. Does not rewrite legacy public.orders or convert legacy prices.
-- Apply only after reviewing the migration against the target Supabase project.

begin;

create schema if not exists private;

revoke all on schema private from public;
revoke all on schema private from anon, authenticated;
grant usage on schema private to service_role;

-- IDR price columns are intentionally nullable until business-approved price mapping
-- is supplied. Checkout must reject products without price_idr.
alter table public.products
  add column if not exists price_idr bigint,
  add column if not exists compare_at_price_idr bigint;

alter table public.products
  add constraint products_price_idr_nonnegative
  check (price_idr is null or price_idr >= 0);

alter table public.products
  add constraint products_compare_at_price_idr_nonnegative
  check (compare_at_price_idr is null or compare_at_price_idr >= 0);

create table if not exists private.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null
);

create table if not exists private.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  customer_name text not null,
  customer_email text not null,
  customer_phone text not null,
  shipping_address text not null,
  shipping_city text not null,
  shipping_postal_code text not null,
  customer_notes text,
  subtotal bigint not null check (subtotal >= 0),
  shipping_fee bigint not null check (shipping_fee >= 0),
  discount_amount bigint not null default 0 check (discount_amount = 0),
  total bigint not null check (total >= 0),
  currency text not null default 'IDR' check (currency = 'IDR'),
  status text not null default 'awaiting_payment'
    check (status in (
      'awaiting_payment', 'paid', 'processing', 'shipped', 'completed',
      'cancelled', 'payment_failed', 'payment_expired', 'needs_review'
    )),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint orders_total_matches_snapshot
    check (total = subtotal + shipping_fee - discount_amount)
);

create index if not exists private_orders_created_at_idx
  on private.orders (created_at desc);
create index if not exists private_orders_status_idx
  on private.orders (status);
create index if not exists private_orders_user_id_idx
  on private.orders (user_id) where user_id is not null;

create table if not exists private.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references private.orders(id) on delete restrict,
  product_id uuid references public.products(id) on delete set null,
  product_name text not null,
  unit_price bigint not null check (unit_price >= 0),
  quantity integer not null check (quantity > 0),
  line_total bigint not null check (line_total = unit_price * quantity),
  created_at timestamptz not null default now()
);

create index if not exists private_order_items_order_id_idx
  on private.order_items (order_id);

create table if not exists private.payments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references private.orders(id) on delete restrict,
  provider text not null default 'duitku' check (provider = 'duitku'),
  merchant_order_id text not null unique,
  provider_invoice_id text unique,
  amount bigint not null check (amount > 0),
  currency text not null default 'IDR' check (currency = 'IDR'),
  status text not null default 'creating'
    check (status in ('creating', 'pending', 'paid', 'failed', 'expired', 'needs_review')),
  payment_url text,
  expires_at timestamptz,
  paid_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists private_payments_order_id_idx
  on private.payments (order_id);
create index if not exists private_payments_status_idx
  on private.payments (status);

create table if not exists private.payment_events (
  id uuid primary key default gen_random_uuid(),
  payment_id uuid references private.payments(id) on delete set null,
  provider text not null default 'duitku' check (provider = 'duitku'),
  event_fingerprint text not null,
  result_code text,
  amount bigint,
  signature_valid boolean not null default false,
  processing_status text not null default 'received'
    check (processing_status in ('received', 'processed', 'duplicate', 'rejected', 'needs_review')),
  processing_note text,
  received_at timestamptz not null default now(),
  processed_at timestamptz,
  constraint payment_events_provider_fingerprint_unique unique (provider, event_fingerprint)
);

create index if not exists private_payment_events_payment_id_idx
  on private.payment_events (payment_id);
create index if not exists private_payment_events_received_at_idx
  on private.payment_events (received_at desc);

create table if not exists private.inventory_movements (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references public.products(id) on delete set null,
  order_id uuid not null references private.orders(id) on delete restrict,
  order_item_id uuid not null references private.order_items(id) on delete restrict,
  movement_type text not null
    check (movement_type in ('order_decrease', 'payment_restore')),
  quantity_delta integer not null,
  created_at timestamptz not null default now(),
  constraint inventory_movement_direction_check check (
    (movement_type = 'order_decrease' and quantity_delta < 0)
    or (movement_type = 'payment_restore' and quantity_delta > 0)
  ),
  constraint inventory_movement_once_per_item unique (order_item_id, movement_type)
);

create index if not exists private_inventory_movements_order_id_idx
  on private.inventory_movements (order_id);
create index if not exists private_inventory_movements_product_id_idx
  on private.inventory_movements (product_id);

create table if not exists private.order_access_tokens (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references private.orders(id) on delete cascade,
  token_hash text not null unique,
  expires_at timestamptz not null,
  revoked_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists private_order_access_tokens_order_id_idx
  on private.order_access_tokens (order_id);
create index if not exists private_order_access_tokens_expiry_idx
  on private.order_access_tokens (expires_at);

create table if not exists private.checkout_idempotency (
  id uuid primary key default gen_random_uuid(),
  idempotency_key_hash text not null unique,
  payload_hash text not null,
  order_id uuid not null references private.orders(id) on delete restrict,
  expires_at timestamptz not null,
  created_at timestamptz not null default now()
);

create index if not exists private_checkout_idempotency_expiry_idx
  on private.checkout_idempotency (expires_at);

create table if not exists private.store_settings (
  singleton_id smallint primary key default 1 check (singleton_id = 1),
  currency text not null default 'IDR' check (currency = 'IDR'),
  flat_shipping_fee bigint check (flat_shipping_fee is null or flat_shipping_fee >= 0),
  checkout_enabled boolean not null default false,
  updated_at timestamptz not null default now()
);

insert into private.store_settings (singleton_id, currency, flat_shipping_fee, checkout_enabled)
values (1, 'IDR', null, false)
on conflict (singleton_id) do nothing;

-- Private tables have RLS enabled and intentionally have no client-facing policies.
alter table private.admin_users enable row level security;
alter table private.orders enable row level security;
alter table private.order_items enable row level security;
alter table private.payments enable row level security;
alter table private.payment_events enable row level security;
alter table private.inventory_movements enable row level security;
alter table private.order_access_tokens enable row level security;
alter table private.checkout_idempotency enable row level security;
alter table private.store_settings enable row level security;

revoke all on all tables in schema private from public, anon, authenticated;
revoke all on all sequences in schema private from public, anon, authenticated;

-- Explicitly deny direct client access to new IDR price columns through table grants
-- only if the project uses column-level grants; RLS/grants for public.products remain
-- governed by the existing catalog policy and must be reviewed before cutover.

commit;
