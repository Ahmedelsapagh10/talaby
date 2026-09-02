#!/bin/zsh
set -euo pipefail

project_id="demo-talaby"
owner_id="qmxG99t1LAfLbikszDWWoqnxYPA3"
auth_url="http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key"
document_root="projects/${project_id}/databases/(default)/documents"
firestore_url="http://127.0.0.1:8080/v1/${document_root}"
fixed_time="2026-01-01T00:00:00Z"
response_file="$(mktemp)"
trap 'rm -f "$response_file"' EXIT

sign_up() {
  curl --silent --show-error --fail \
    -H 'Content-Type: application/json' \
    -d "{\"email\":\"$1\",\"password\":\"Test@123456\",\"returnSecureToken\":true}" \
    "$auth_url"
}

expect_status() {
  local expected="$1" method="$2" url="$3" token="$4" body="${5:-}"
  local http_status
  if [[ -n "$body" ]]; then
    http_status="$(curl --silent --show-error -o "$response_file" -w '%{http_code}' \
      -X "$method" -H "Authorization: Bearer ${token}" \
      -H 'Content-Type: application/json' -d "$body" "$url")"
  else
    http_status="$(curl --silent --show-error -o "$response_file" -w '%{http_code}' \
      -X "$method" -H "Authorization: Bearer ${token}" "$url")"
  fi
  if [[ "$http_status" != "$expected" ]]; then
    print -u2 "Expected ${expected}, received ${http_status} for ${method} ${url}"
    cat "$response_file" >&2
    exit 1
  fi
}

document_body() {
  jq -nc --argjson fields "$1" '{fields: $fields}'
}

order_fields() {
  local number="$1"
  jq -nc \
    --arg number "$number" \
    --arg owner "$owner_id" \
    --arg customer "$customer_id" \
    --arg time "$fixed_time" '
    {
      readableOrderNumber: {stringValue: $number},
      ownerId: {stringValue: $owner},
      customerId: {stringValue: $customer},
      customerName: {stringValue: "Customer"},
      phone: {stringValue: "01012345678"},
      email: {stringValue: "customer@talaby.test"},
      defaultCity: {stringValue: "Cairo"},
      defaultAddress: {stringValue: "Nasr City"},
      searchName: {stringValue: "customer"},
      searchPhone: {stringValue: "01012345678"},
      searchPrefixes: {arrayValue: {values: [{stringValue: "ord"}]}},
      city: {stringValue: "Cairo"},
      address: {stringValue: "Nasr City"},
      notes: {nullValue: null},
      items: {arrayValue: {values: [{mapValue: {fields: {
        productId: {stringValue: "product-1"},
        productName: {stringValue: "Product"},
        variantId: {nullValue: null},
        sku: {stringValue: "SKU-1"},
        imageUrl: {nullValue: null},
        colorId: {nullValue: null},
        colorName: {nullValue: null},
        sizeId: {nullValue: null},
        quantity: {integerValue: "1"},
        unitPrice: {integerValue: "1000"},
        discountAmount: {integerValue: "0"},
        lineTotal: {integerValue: "1000"}
      }}}]}},
      subtotal: {integerValue: "1000"},
      discountAmount: {integerValue: "0"},
      deliveryFee: {nullValue: null},
      total: {integerValue: "1000"},
      paidAmount: {integerValue: "0"},
      remainingAmount: {integerValue: "1000"},
      paymentStatus: {stringValue: "unpaid"},
      orderStatus: {stringValue: "pending"},
      payments: {arrayValue: {values: []}},
      events: {arrayValue: {values: [{mapValue: {fields: {
        type: {stringValue: "orderCreated"},
        timestamp: {timestampValue: $time},
        customerVisible: {booleanValue: true},
        metadata: {mapValue: {fields: {}}}
      }}}]}},
      createdAt: {timestampValue: $time},
      updatedAt: {timestampValue: $time}
    }'
}

stock_commit() {
  local order_id="$1" number="$2" product_fields="$3" order_count="$4"
  local fields
  fields="$(order_fields "$number" | jq -c 'del(.createdAt, .updatedAt)')"
  jq -nc \
    --arg order_name "${document_root}/owners/${owner_id}/orders/${order_id}" \
    --arg product_name "${document_root}/owners/${owner_id}/products/product-1" \
    --arg customer_name "${document_root}/owners/${owner_id}/customers/${customer_id}" \
    --arg customer_id "$customer_id" \
    --arg order_id "$order_id" \
    --arg order_count "$order_count" \
    --argjson order_fields "$fields" \
    --argjson product_fields "$product_fields" '
    {writes: [
      {
        update: {name: $order_name, fields: $order_fields},
        updateTransforms: [
          {fieldPath: "createdAt", setToServerValue: "REQUEST_TIME"},
          {fieldPath: "updatedAt", setToServerValue: "REQUEST_TIME"}
        ]
      },
      {
        update: {name: $product_name, fields: $product_fields},
        updateMask: {fieldPaths: ($product_fields | keys)},
        updateTransforms: [
          {fieldPath: "updatedAt", setToServerValue: "REQUEST_TIME"}
        ]
      },
      {
        update: {name: $customer_name, fields: {
          orderCount: {integerValue: $order_count},
          lastOrderId: {stringValue: $order_id}
        }},
        updateMask: {fieldPaths: ["orderCount", "lastOrderId"]},
        updateTransforms: [
          {fieldPath: "lastOrderAt", setToServerValue: "REQUEST_TIME"},
          {fieldPath: "updatedAt", setToServerValue: "REQUEST_TIME"}
        ]
      }
    ]}'
}

admin_auth="$(sign_up 'admin@talaby.test')"
customer_auth="$(sign_up 'customer@talaby.test')"
other_auth="$(sign_up 'other@talaby.test')"
admin_id="$(print -r -- "$admin_auth" | jq -r '.localId')"
customer_id="$(print -r -- "$customer_auth" | jq -r '.localId')"
other_id="$(print -r -- "$other_auth" | jq -r '.localId')"
admin_token="$(print -r -- "$admin_auth" | jq -r '.idToken')"
customer_token="$(print -r -- "$customer_auth" | jq -r '.idToken')"
other_token="$(print -r -- "$other_auth" | jq -r '.idToken')"

bootstrap_owner_fields="$(jq -nc --arg time "$fixed_time" '{
  active: {booleanValue: true},
  createdAt: {timestampValue: $time},
  updatedAt: {timestampValue: $time}
}')"
bootstrap_member_fields="$(jq -nc --arg time "$fixed_time" '{
  role: {stringValue: "admin"},
  createdAt: {timestampValue: $time},
  updatedAt: {timestampValue: $time}
}')"
expect_status 200 PATCH "${firestore_url}/owners/${other_id}" \
  "$other_token" "$(document_body "$bootstrap_owner_fields")"
expect_status 403 PATCH "${firestore_url}/owners/${customer_id}" \
  "$other_token" "$(document_body "$bootstrap_owner_fields")"
expect_status 200 PATCH "${firestore_url}/owners/${other_id}/members/${other_id}" \
  "$other_token" "$(document_body "$bootstrap_member_fields")"
expect_status 403 PATCH "${firestore_url}/owners/${other_id}/members/${other_id}?updateMask.fieldPaths=role" \
  "$other_token" '{"fields":{"role":{"stringValue":"staff"}}}'

expect_status 200 PATCH "${firestore_url}/owners/${owner_id}" owner \
  '{"fields":{"active":{"booleanValue":true},"name":{"stringValue":"Talaby"}}}'
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/members/${admin_id}" owner \
  '{"fields":{"role":{"stringValue":"admin"}}}'
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}?updateMask.fieldPaths=active" \
  "$admin_token" '{"fields":{"active":{"booleanValue":false}}}'
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}?updateMask.fieldPaths=active" \
  "$admin_token" '{"fields":{"active":{"booleanValue":true}}}'
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/categories/category-1" \
  "$admin_token" \
  '{"fields":{"name":{"stringValue":"Category"},"active":{"booleanValue":true},"sortOrder":{"integerValue":"1"}}}'

product_fields="$(jq -nc --arg owner "$owner_id" '{
  ownerId: {stringValue: $owner},
  name: {stringValue: "Product"},
  active: {booleanValue: true},
  stock: {integerValue: "5"},
  variants: {arrayValue: {values: [{mapValue: {fields: {
    id: {stringValue: "variant-1"},
    sku: {stringValue: "SKU-1"},
    stock: {integerValue: "5"},
    active: {booleanValue: true}
  }}}]}}
}')"
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/products/product-1" \
  "$admin_token" "$(document_body "$product_fields")"
expect_status 403 PATCH "${firestore_url}/owners/${owner_id}/products/product-1?updateMask.fieldPaths=active" \
  "$customer_token" '{"fields":{"active":{"booleanValue":false}}}'
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/products/product-1?updateMask.fieldPaths=active" \
  "$admin_token" '{"fields":{"active":{"booleanValue":false}}}'
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/products/product-1?updateMask.fieldPaths=active" \
  "$admin_token" '{"fields":{"active":{"booleanValue":true}}}'

wishlist_fields="$(jq -nc --arg owner "$owner_id" --arg time "$fixed_time" '{
  productId: {stringValue: "product-1"},
  ownerId: {stringValue: $owner},
  createdAt: {timestampValue: $time}
}')"
expect_status 200 PATCH "${firestore_url}/users/${customer_id}/wishlist/product-1" \
  "$customer_token" "$(document_body "$wishlist_fields")"
expect_status 403 PATCH "${firestore_url}/users/${other_id}/wishlist/product-1" \
  "$customer_token" "$(document_body "$wishlist_fields")"

customer_fields="$(jq -nc --arg time "$fixed_time" '{
  name: {stringValue: "Customer"}, phone: {stringValue: "01012345678"},
  email: {stringValue: "customer@talaby.test"},
  defaultCity: {stringValue: "Cairo"},
  defaultAddress: {stringValue: "Nasr City"},
  searchName: {stringValue: "customer"},
  searchPhone: {stringValue: "01012345678"},
  orderCount: {integerValue: "0"}, lastOrderAt: {nullValue: null},
  createdAt: {timestampValue: $time}, updatedAt: {timestampValue: $time}
}')"
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/customers/${customer_id}" \
  "$customer_token" "$(document_body "$customer_fields")"
expect_status 403 GET "${firestore_url}/owners/${owner_id}/customers/${other_id}" \
  "$customer_token"

order_fields_json="$(order_fields 'ORD-1')"
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/orders/order-1" \
  "$customer_token" "$(document_body "$order_fields_json")"
bad_order_fields="$(print -r -- "$order_fields_json" | jq -c '.orderStatus.stringValue = "delivered"')"
expect_status 403 PATCH "${firestore_url}/owners/${owner_id}/orders/order-bad" \
  "$customer_token" "$(document_body "$bad_order_fields")"

customer_update_commit="$(jq -nc \
  --arg name "${document_root}/owners/${owner_id}/customers/${customer_id}" '
  {writes: [{
    update: {name: $name, fields: {
      orderCount: {integerValue: "1"},
      lastOrderId: {stringValue: "order-1"}
    }},
    updateMask: {fieldPaths: ["orderCount", "lastOrderId"]},
    updateTransforms: [
      {fieldPath: "lastOrderAt", setToServerValue: "REQUEST_TIME"},
      {fieldPath: "updatedAt", setToServerValue: "REQUEST_TIME"}
    ]
  }]}')"
expect_status 403 POST "${firestore_url}:commit" "$customer_token" \
  "$customer_update_commit"
expect_status 403 PATCH "${firestore_url}/owners/${owner_id}/customers/${customer_id}?updateMask.fieldPaths=orderCount" \
  "$customer_token" '{"fields":{"orderCount":{"integerValue":"3"}}}'

top_stock_fields="$(jq -nc '{
  stock: {integerValue: "4"},
  stockMutation: {mapValue: {fields: {
    orderId: {stringValue: "order-stock-1"},
    orderItemIndex: {integerValue: "0"},
    items: {arrayValue: {values: [{mapValue: {fields: {
      variantIndex: {integerValue: "-1"}, quantity: {integerValue: "1"}
    }}}]}}
  }}}
}')"
expect_status 200 POST "${firestore_url}:commit" "$customer_token" \
  "$(stock_commit 'order-stock-1' 'ORD-STOCK-1' "$top_stock_fields" '1')"

variant_fields="$(jq -nc '{
  variants: {arrayValue: {values: [{mapValue: {fields: {
    id: {stringValue: "variant-1"}, sku: {stringValue: "SKU-1"},
    stock: {integerValue: "4"}, active: {booleanValue: true}
  }}}]}},
  stockMutation: {mapValue: {fields: {
    orderId: {stringValue: "order-stock-2"},
    orderItemIndex: {integerValue: "0"},
    items: {arrayValue: {values: [{mapValue: {fields: {
      variantIndex: {integerValue: "0"}, quantity: {integerValue: "1"}
    }}}]}}
  }}}
}')"
expect_status 200 POST "${firestore_url}:commit" "$customer_token" \
  "$(stock_commit 'order-stock-2' 'ORD-STOCK-2' "$variant_fields" '2')"

tampered_fields="$(print -r -- "$variant_fields" | jq -c '
  .variants.arrayValue.values[0].mapValue.fields.sku.stringValue = "HACKED" |
  .variants.arrayValue.values[0].mapValue.fields.stock.integerValue = "3" |
  .stockMutation.mapValue.fields.orderId.stringValue = "order-stock-hack"
')"
expect_status 403 POST "${firestore_url}:commit" "$customer_token" \
  "$(stock_commit 'order-stock-hack' 'ORD-STOCK-HACK' "$tampered_fields" '3')"

payment_fields="$(jq -nc --arg time "$fixed_time" '{
  payments: {arrayValue: {values: [{mapValue: {fields: {
    id: {stringValue: "payment-1"},
    proofUrl: {stringValue: "https://example.com/proof.jpg"},
    claimedAmount: {integerValue: "500"}, confirmedAmount: {nullValue: null},
    status: {stringValue: "proofSubmitted"},
    createdAt: {timestampValue: $time}, reviewedAt: {nullValue: null},
    reviewedBy: {nullValue: null}
  }}}]}},
  paidAmount: {integerValue: "0"}, remainingAmount: {integerValue: "1000"},
  paymentStatus: {stringValue: "proofSubmitted"},
  events: {arrayValue: {values: [
    {mapValue: {fields: {
      type: {stringValue: "orderCreated"}, timestamp: {timestampValue: $time},
      customerVisible: {booleanValue: true}, metadata: {mapValue: {fields: {}}}
    }}},
    {mapValue: {fields: {
      type: {stringValue: "paymentProofSubmitted"},
      timestamp: {timestampValue: $time}, customerVisible: {booleanValue: true},
      metadata: {mapValue: {fields: {}}}
    }}}
  ]}},
  updatedAt: {timestampValue: $time}
}')"
payment_masks='updateMask.fieldPaths=payments&updateMask.fieldPaths=paidAmount&updateMask.fieldPaths=remainingAmount&updateMask.fieldPaths=paymentStatus&updateMask.fieldPaths=events&updateMask.fieldPaths=updatedAt'
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/orders/order-1?${payment_masks}" \
  "$customer_token" "$(document_body "$payment_fields")"
expect_status 403 PATCH "${firestore_url}/owners/${owner_id}/orders/order-1?updateMask.fieldPaths=paymentStatus" \
  "$customer_token" '{"fields":{"paymentStatus":{"stringValue":"paid"}}}'

audit_fields="$(jq -nc --arg customer "$customer_id" --arg time "$fixed_time" '{
  type: {stringValue: "paymentProofSubmitted"},
  performedBy: {stringValue: $customer}, metadata: {mapValue: {fields: {}}},
  timestamp: {timestampValue: $time}
}')"
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/orders/order-1/adminEvents/event-1" \
  "$customer_token" "$(document_body "$audit_fields")"
expect_status 403 PATCH "${firestore_url}/owners/${owner_id}/orders/order-1/adminEvents/event-2" \
  "$other_token" "$(document_body "$audit_fields")"

review_fields="$(jq -nc --arg customer "$customer_id" --arg time "$fixed_time" '{
  productId: {stringValue: "product-1"}, productName: {stringValue: "Product"},
  customerId: {stringValue: $customer}, displayName: {stringValue: "Customer"},
  rating: {integerValue: "5"}, feedback: {stringValue: "Great"},
  approved: {booleanValue: false}, createdAt: {timestampValue: $time}
}')"
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/reviews/review-1" \
  "$customer_token" "$(document_body "$review_fields")"
expect_status 403 PATCH "${firestore_url}/owners/${owner_id}/reviews/review-1?updateMask.fieldPaths=approved" \
  "$customer_token" '{"fields":{"approved":{"booleanValue":true}}}'
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/reviews/review-1?updateMask.fieldPaths=approved" \
  "$admin_token" '{"fields":{"approved":{"booleanValue":true}}}'

counter_fields="$(jq -nc --arg time "$fixed_time" '{
  value: {integerValue: "10452"}, updatedAt: {timestampValue: $time}
}')"
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/counters/smokeCounter" \
  "$customer_token" "$(document_body "$counter_fields")"
counter_jump="$(print -r -- "$counter_fields" | jq -c '.value.integerValue = "10454"')"
expect_status 403 PATCH "${firestore_url}/owners/${owner_id}/counters/smokeCounter?updateMask.fieldPaths=value&updateMask.fieldPaths=updatedAt" \
  "$customer_token" "$(document_body "$counter_jump")"
counter_next="$(print -r -- "$counter_fields" | jq -c '.value.integerValue = "10453"')"
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/counters/smokeCounter?updateMask.fieldPaths=value&updateMask.fieldPaths=updatedAt" \
  "$customer_token" "$(document_body "$counter_next")"

expect_status 403 GET "${firestore_url}/owners/${owner_id}/customers" "$customer_token"
expect_status 200 GET "${firestore_url}/owners/${owner_id}/customers" "$admin_token"
expect_status 403 PATCH "${firestore_url}/owners/${owner_id}/settings/general" \
  "$customer_token" '{"fields":{"currencyCode":{"stringValue":"EGP"}}}'
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/settings/general" \
  "$admin_token" '{"fields":{"currencyCode":{"stringValue":"EGP"}}}'
expect_status 200 DELETE "${firestore_url}/owners/${owner_id}/reviews/review-1" \
  "$admin_token"
expect_status 200 DELETE "${firestore_url}/owners/${owner_id}/products/product-1" \
  "$admin_token"

print 'Firestore rules smoke tests passed.'
