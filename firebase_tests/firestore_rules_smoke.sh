#!/bin/zsh
set -euo pipefail

project_id="demo-talaby"
owner_id="qmxG99t1LAfLbikszDWWoqnxYPA3"
auth_url="http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key"
firestore_url="http://127.0.0.1:8080/v1/projects/${project_id}/databases/(default)/documents"
response_file="$(mktemp)"
trap 'rm -f "$response_file"' EXIT

sign_up() {
  local email="$1"
  curl --silent --show-error --fail \
    -H 'Content-Type: application/json' \
    -d "{\"email\":\"${email}\",\"password\":\"Test@123456\",\"returnSecureToken\":true}" \
    "$auth_url"
}

expect_status() {
  local expected="$1"
  local method="$2"
  local url="$3"
  local token="$4"
  local body="${5:-}"
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

admin_auth="$(sign_up 'admin@talaby.test')"
customer_auth="$(sign_up 'customer@talaby.test')"
other_auth="$(sign_up 'other@talaby.test')"
admin_id="$(print -r -- "$admin_auth" | jq -r '.localId')"
customer_id="$(print -r -- "$customer_auth" | jq -r '.localId')"
other_id="$(print -r -- "$other_auth" | jq -r '.localId')"
admin_token="$(print -r -- "$admin_auth" | jq -r '.idToken')"
customer_token="$(print -r -- "$customer_auth" | jq -r '.idToken')"

expect_status 200 PATCH "${firestore_url}/owners/${owner_id}" owner \
  '{"fields":{"active":{"booleanValue":true},"name":{"stringValue":"Talaby"}}}'
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/members/${admin_id}" owner \
  '{"fields":{"role":{"stringValue":"admin"}}}'
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/categories/category-1" \
  "$admin_token" \
  '{"fields":{"name":{"stringValue":"Category"},"active":{"booleanValue":true},"sortOrder":{"integerValue":"1"}}}'
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/products/product-1" \
  "$admin_token" \
  "{\"fields\":{\"ownerId\":{\"stringValue\":\"${owner_id}\"},\"name\":{\"stringValue\":\"Product\"},\"active\":{\"booleanValue\":true}}}"

expect_status 403 PATCH "${firestore_url}/owners/${owner_id}/products/product-1?updateMask.fieldPaths=active" \
  "$customer_token" '{"fields":{"active":{"booleanValue":false}}}'
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/products/product-1?updateMask.fieldPaths=active" \
  "$admin_token" '{"fields":{"active":{"booleanValue":false}}}'
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/products/product-1?updateMask.fieldPaths=active" "$admin_token" \
  '{"fields":{"active":{"booleanValue":true}}}'

expect_status 200 PATCH "${firestore_url}/users/${customer_id}/wishlist/product-1" \
  "$customer_token" '{"fields":{"productId":{"stringValue":"product-1"}}}'
expect_status 403 PATCH "${firestore_url}/users/${other_id}/wishlist/product-1" \
  "$customer_token" '{"fields":{"productId":{"stringValue":"product-1"}}}'
customer_body="{\"fields\":{\"name\":{\"stringValue\":\"Customer\"},\"phone\":{\"stringValue\":\"01012345678\"},\"email\":{\"stringValue\":\"customer@talaby.test\"},\"defaultCity\":{\"stringValue\":\"Cairo\"},\"defaultAddress\":{\"stringValue\":\"Nasr City\"},\"searchName\":{\"stringValue\":\"customer\"},\"searchPhone\":{\"stringValue\":\"01012345678\"},\"orderCount\":{\"integerValue\":\"0\"},\"lastOrderAt\":{\"nullValue\":null}}}"
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/customers/${customer_id}" \
  "$customer_token" "$customer_body"
expect_status 403 GET "${firestore_url}/owners/${owner_id}/customers/${other_id}" \
  "$customer_token"
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/orders/order-1" \
  "$customer_token" "{\"fields\":{\"customerId\":{\"stringValue\":\"${customer_id}\"}}}"

review_body="{\"fields\":{\"productId\":{\"stringValue\":\"product-1\"},\"productName\":{\"stringValue\":\"Product\"},\"customerId\":{\"stringValue\":\"${customer_id}\"},\"displayName\":{\"stringValue\":\"Customer\"},\"rating\":{\"integerValue\":\"5\"},\"feedback\":{\"stringValue\":\"Great\"},\"approved\":{\"booleanValue\":false}}}"
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/reviews/review-1" \
  "$customer_token" "$review_body"
expect_status 403 PATCH "${firestore_url}/owners/${owner_id}/reviews/review-1?updateMask.fieldPaths=approved" \
  "$customer_token" '{"fields":{"approved":{"booleanValue":true}}}'
expect_status 200 PATCH "${firestore_url}/owners/${owner_id}/reviews/review-1?updateMask.fieldPaths=approved" \
  "$admin_token" '{"fields":{"approved":{"booleanValue":true}}}'

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
