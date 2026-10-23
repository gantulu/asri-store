# Storefront Requirement V1 — Asri Store

**Repository:** `gantulu/asri-store`  
**Branch:** `main`  
**Status:** Requirement baseline — proposed requirements; implementation and live configuration are not implied  
**Versioning rule:** V1 is the baseline. Future versions must extend this document additively and must not silently delete or duplicate existing requirements.

## 1. Purpose

Define the customer-facing storefront, customer account, order journey, supporting content pages, admin capabilities, and security/payment requirements for Asri Store.

This document defines intended requirements. It does not assert that every page or backend behavior currently exists or works in the repository.

## 2. Existing repository baseline

The repository currently contains a React/Vite storefront with these page modules/routes or corresponding screens identified in the code audit:

- Home
- Product listing/catalog
- Product detail
- Cart
- Checkout
- Login and signup
- Order history
- Admin
- Help
- Not found

The exact implementation state of each feature must be verified against the current route configuration, component behavior, Supabase policies, and tests before marking it complete.

## 3. Customer storefront requirements

| ID | Page / capability | Required behavior | Initial status |
|---|---|---|---|
| SF-001 | Home | Hero/banner, category entry points, featured products, promotional sections, responsive layout | Existing baseline; verify completeness |
| SF-002 | Product listing / category | Product grid/list, category and attribute filters, sorting, pagination or defined loading strategy, empty/error states | Existing baseline; verify completeness |
| SF-003 | Product search results | Search query, relevant results, filters/sorting, no-result state, clear search | To verify / potentially missing |
| SF-004 | Product detail | Product images, description, price, discount where valid, stock availability, quantity selection, related products | Existing baseline; verify completeness |
| SF-005 | Cart | Add/remove items, quantity changes, stock-aware validation, subtotal, persist or restore cart as specified | Existing baseline; verify completeness |
| SF-006 | Wishlist | Add/remove saved products, view saved items, move available items to cart; requires authenticated ownership or an explicitly defined guest behavior | Missing / to implement if approved |
| SF-007 | Checkout | Customer details, delivery address, order note, item summary, server-validated price and totals, shipping and discount breakdown, clear error recovery | Existing baseline; critical backend contract required |
| SF-008 | Payment status | Display pending, paid, failed, expired, or other provider-supported status based only on verified backend state | Missing / to implement |
| SF-009 | Order confirmation | Show order reference, summary, payment instructions/status, and next steps after order creation | Missing / to implement |
| SF-010 | Order history | List the signed-in customer's own orders, status, totals, and links to order details | Existing baseline; verify ownership enforcement |
| SF-011 | Order detail | Show order items, prices, address snapshot, order status, payment status, timestamps, and tracking information when available | Missing as a separate page / to implement |
| SF-012 | Shipment tracking | Show carrier, tracking number, shipment status, and event history when a reliable tracking source exists; do not fabricate tracking events | Missing / to implement |
| SF-013 | Product reviews | Show ratings/reviews; submit, edit, or delete according to policy; verify purchase eligibility if reviews are purchase-verified | Missing / to implement |
| SF-014 | Customer profile | View/edit permitted profile fields and account preferences; protect account identity and role fields | Missing / to implement |
| SF-015 | Address book | Create/edit/delete customer addresses, select default address, validate required address fields, enforce user ownership | Missing / to implement |
| SF-016 | Login | Authenticate, validate errors, preserve safe return path, and handle session state | Existing baseline; verify |
| SF-017 | Signup | Create account, validate inputs, handle email confirmation if enabled, and prevent exposing account data | Existing baseline; verify |
| SF-018 | Help / FAQ | Answer common questions about ordering, payment, shipping, returns, and account access | Help baseline exists; content completeness to verify |
| SF-019 | About us | Store introduction and verified business information | Missing / to implement |
| SF-020 | Contact us | Published contact channels and/or a validated contact form with abuse protection | Missing / to implement |
| SF-021 | Privacy policy | Explain personal-data collection, purpose, handling, sharing, retention, and customer rights using the store's actual practices | Missing / to implement; content requires business/legal review |
| SF-022 | Terms and conditions | State applicable account, order, payment, and use terms consistent with actual business practices | Missing / to implement; content requires business/legal review |
| SF-023 | Shipping policy | Explain service areas, shipping charges, estimates, and delivery conditions without unsupported promises | Missing / to implement |
| SF-024 | Return and refund policy | Explain eligibility, timelines, evidence, cancellation, return, and refund process consistent with actual operations and provider rules | Missing / to implement; content requires business/legal review |
| SF-025 | Not found and error states | Provide useful 404, unauthorized/forbidden, loading, empty, and recoverable service-error states | Not found baseline exists; other states to verify |
| SF-026 | Responsive/accessibility behavior | Support mobile and desktop layouts, keyboard navigation, semantic labels, visible focus, readable contrast, and form error announcements | Cross-cutting requirement; verify |

## 4. Admin requirements

Admin routes and actions must be protected by server-enforced authorization. Hiding UI controls is not sufficient.

| ID | Page / capability | Required behavior | Initial status |
|---|---|---|---|
| AD-001 | Admin dashboard | Summaries for orders, sales, payment states, low stock, and operational exceptions based on trusted data | Existing admin screen; dashboard completeness to verify |
| AD-002 | Product management | Create/edit/archive products, manage images, price, availability, and validated product fields | Existing admin baseline; verify |
| AD-003 | Category management | Manage category names, slugs, ordering, visibility, and product associations | To verify / potentially missing |
| AD-004 | Order management | Search/filter orders, inspect order details, and apply only allowed, audited state transitions | Missing / to implement |
| AD-005 | Payment management | View provider reference, amount, currency, current status, timestamps, and reconciliation exceptions; never manually mark paid without trusted evidence | Missing / to implement |
| AD-006 | Shipment management | Record carrier and tracking number and maintain validated shipment status/history | Missing / to implement |
| AD-007 | Customer management | View only necessary customer information and perform authorized support actions with auditability | Missing / to implement |
| AD-008 | Inventory management | View stock, record controlled adjustments, prevent negative stock, and retain an adjustment trail | Missing / to implement |
| AD-009 | Coupon and promotion management | Configure validity, limits, eligibility, and discount rules; enforce rules server-side | Missing / to implement |
| AD-010 | Review moderation | Hide/remove reviews only under a defined moderation policy and record moderation actions | Missing / to implement |
| AD-011 | Store settings | Manage approved store contact, shipping, and storefront settings without exposing secrets | Missing / to implement |
| AD-012 | Role and access control | Grant admin privileges only through a trusted administrative path; users cannot elevate their own role | Security-critical; audit/remediation required |

## 5. Navigation and information architecture

### Storefront navigation
- Home
- Shop / All Products
- Categories
- Search
- Wishlist
- Cart

### Customer account
- Profile
- Address Book
- Order History
- Order Detail
- Shipment Tracking
- Reviews, where supported
- Sign in / Sign out

### Order journey
**Product → Cart → Checkout → Order Confirmation → Payment Status → Order Detail → Shipment Tracking**

Payment and shipment status are separate concepts and must not be conflated.

### Footer / help navigation
- Help / FAQ
- About Us
- Contact Us
- Privacy Policy
- Terms and Conditions
- Shipping Policy
- Return and Refund Policy

### Admin navigation
- Dashboard
- Products
- Categories
- Orders
- Payments
- Shipments
- Customers
- Inventory
- Coupons and Promotions
- Reviews
- Store Settings
- Access / Role Management

Only show navigation entries the current user is authorized to access. Every protected route and data operation must also enforce authorization server-side.

## 6. Supabase, checkout, and data-integrity requirements

| ID | Requirement | Acceptance criteria |
|---|---|---|
| BE-001 | Trusted checkout totals | Backend derives current product prices, valid discounts, shipping, taxes/fees if applicable, and final total. Client-submitted totals are never trusted. |
| BE-002 | Atomic order creation | Order header and all order items are created in one PostgreSQL transaction, preferably through a narrowly scoped RPC or equivalent trusted server operation. Failure leaves no partial order. |
| BE-003 | Stock concurrency | Stock is validated and reserved/decremented atomically; concurrent checkouts cannot oversell beyond the defined inventory policy. |
| BE-004 | Order idempotency | Repeated checkout submissions using the same idempotency key do not create duplicate orders or payment attempts. |
| BE-005 | RLS and ownership | Customers can read/update only their own permitted data and orders. Admin access is separately authorized and tested. |
| BE-006 | Role escalation prevention | A customer cannot modify their own admin/role field through profile updates, direct API requests, or manipulated client state. |
| BE-007 | Least privilege | Public clients never receive service-role credentials. Sensitive writes run only through trusted backend functions/RPCs with minimal grants. |
| BE-008 | Data minimization | Store only necessary customer/address/order data; do not expose private data through public queries or error messages. |
| BE-009 | Auditability | Sensitive administrative actions and material order/payment transitions have sufficient traceability for support and reconciliation. |
| BE-010 | State transition rules | Order, payment, and shipment state transitions are explicitly defined and validated atomically; stale or invalid transitions are rejected. |

## 7. Duitku POP payment requirements

Duitku POP is the intended payment integration target, but implementation details must be confirmed against current official Duitku documentation before coding. Do not invent request fields, endpoints, signature formulas, status mappings, or callback guarantees.

| ID | Requirement | Acceptance criteria |
|---|---|---|
| PAY-001 | Create Invoice | Trusted backend creates the payment request using documented Duitku POP contract and validated server-side order amount. |
| PAY-002 | Payment reference | Persist the internal order ID and provider transaction/reference identifiers with uniqueness rules appropriate to the documented contract. |
| PAY-003 | Secret handling | Merchant credentials/API keys exist only in server-side secrets/environment; never bundle them into frontend code or logs. |
| PAY-004 | Callback verification | Verify callback authenticity using the exact current official signature procedure before trusting any callback fields. |
| PAY-005 | Idempotent callback | Repeated callbacks produce no duplicate side effects; replay and concurrent delivery are handled safely. |
| PAY-006 | Atomic status update | Validate the expected current state and apply payment/order transitions atomically. Invalid or stale transitions are rejected or safely ignored. |
| PAY-007 | Amount/reference validation | Callback order reference and amount/currency, where specified by the provider contract, must match the stored transaction before changing payment status. |
| PAY-008 | Browser return handling | Browser redirect/return pages are informational only; they do not independently prove payment success. |
| PAY-009 | Reconciliation | Provide a documented process to identify mismatches, pending transactions, missed callbacks, and provider/internal status differences using supported provider capabilities. |
| PAY-010 | Sandbox verification | Automated and manual Sandbox tests cover success, pending, failure/expiry where supported, invalid signature, repeated callback, amount/reference mismatch, and concurrent processing. No Sandbox payment is to be initiated without explicit authorization. |

## 8. Cross-cutting acceptance criteria

A requirement is not considered complete solely because a route or visual component exists.

- Route exists and is reachable through the intended navigation.
- Loading, empty, validation, unauthorized, and recoverable error states are handled.
- User-owned records are protected by database/backend authorization, not only frontend checks.
- Critical writes validate inputs on the trusted side.
- No secrets or sensitive personal/payment data are exposed to the browser or logs.
- Relevant automated tests cover normal flow and failure cases.
- UI behavior is responsive and usable on mobile and desktop.
- The implemented behavior is verified against the requirement and evidence is recorded.

## 9. Verification matrix

Use these statuses when auditing implementation; do not mark a feature complete without evidence:

- **Existing** — code and behavior have been inspected and match the requirement.
- **Partial** — some behavior exists, but one or more acceptance criteria are unmet.
- **Missing** — no implementation was found in the inspected scope.
- **Unverified** — evidence is insufficient, including live database policies or runtime behavior not tested.
- **Blocked** — implementation depends on an unresolved business, provider, schema, or security decision.

## 10. Priority order

1. **P0 — Security and transaction correctness:** prevent self-escalation to admin; enforce RLS/authorization; trusted price/stock validation; atomic order + items; idempotency.
2. **P1 — Payment integrity:** verify official Duitku POP contract; Create Invoice; callback signature verification; atomic/idempotent status transitions; reconciliation.
3. **P1 — Core customer order journey:** payment status, order confirmation, order detail, and customer-owned order history.
4. **P2 — Fulfillment and account:** address book, profile, shipment management/tracking, inventory operations.
5. **P2 — Discovery and retention:** search results, category landing pages, wishlist, product reviews, coupons/promotions.
6. **P3 — Content and policy pages:** About, Contact, FAQ completion, privacy, terms, shipping, returns/refunds.
7. **P3 — Quality and accessibility:** responsive behavior, accessibility, route/error states, automated tests, and evidence-based verification.

## 11. Out of scope for this document

This requirement baseline does not authorize or claim completion of:
- Supabase project creation or live database changes
- Applying migrations or changing live RLS policies
- Deploying Edge Functions or frontend releases
- Changing secrets or provider credentials
- Initiating Duitku Sandbox or production payments
- Merging or deploying code beyond the documentation change

Those actions require their own explicit approval and verification plan.

## 12. Change log

- **V1.0:** Added storefront page inventory, customer account and order journey, admin capability requirements, navigation structure, Supabase security/data-integrity requirements, Duitku POP requirements, acceptance criteria, and verification statuses.
