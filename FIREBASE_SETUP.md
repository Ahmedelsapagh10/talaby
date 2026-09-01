# Talaby Firebase setup

## 1. Authentication providers

In Firebase Console, open **Authentication → Sign-in method** and enable:

- Email/Password
- Google
- Apple, after configuring the Apple Services ID, Team ID, Key ID, and private key

Add every production storefront domain to **Authentication → Settings →
Authorized domains**. Configure the same domains in the Google and Apple OAuth
settings when applicable.

## 2. Bootstrap a tenant

Create the tenant with an Admin SDK script or the Firebase Console. Client rules
intentionally do not permit tenant or membership creation.

Create `owners/{OWNER_ID}` with at least:

```json
{
  "name": "Store name",
  "slug": "store-slug",
  "active": true
}
```

After creating an administrator in Firebase Authentication, create
`owners/{OWNER_ID}/members/{ADMIN_UID}`:

```json
{
  "role": "admin"
}
```

Supported membership roles are `admin` and `staff`. Customers do not need a
membership document.

Create `owners/{OWNER_ID}/settings/general` if the defaults should be
overridden. Set `public` to `true` so the storefront can read the settings.

## 3. Configure ImageKit

The app uploads directly to ImageKit, so both the public and private keys must
be supplied as Dart defines. This exposes the private key in the compiled app;
rotate it before switching back to a server-signed production upload flow.

## 4. Install and deploy Firebase resources

```sh
firebase deploy --only firestore:rules,firestore:indexes --project talabyx
```

## 5. Build the storefront

```sh
flutter build web \
  --dart-define=OWNER_ID=owner_001 \
  --dart-define=IMAGEKIT_PUBLIC_KEY=your_public_key \
  --dart-define=IMAGEKIT_PRIVATE_KEY=your_private_key \
  --dart-define=IMAGEKIT_UPLOAD_FOLDER=/talaby/uploads
```

`OWNER_ID` is the tenant selector used by application repositories. Use a
separate build for each subscribed business.

## 6. Search backfill and local rules verification

The first administrator visit to products, customers, and orders fills the
normalized search fields in batches. Completion is recorded in
`owners/{OWNER_ID}/settings/searchBackfills`, so each backfill runs only once.
New records always write their search fields directly.

Run the local authorization smoke tests before deploying rule changes:

```sh
firebase emulators:exec --only auth,firestore --project demo-talaby \
  "zsh firebase_tests/firestore_rules_smoke.sh"
```

The test uses only the local emulators and never connects to production data.
