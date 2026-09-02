#!/usr/bin/env node

const os = require('node:os');
const path = require('node:path');

const projectId = process.argv[2] || 'talabyx';
const ownerId = process.argv[3] || 'qmxG99t1LAfLbikszDWWoqnxYPA3';
const firebaseToolsLib = path.join(
  os.homedir(),
  '.cache/firebase/tools/lib/node_modules/firebase-tools/lib',
);

function firebaseToolsModule(moduleName) {
  try {
    return require(path.join(firebaseToolsLib, moduleName));
  } catch (_) {
    throw new Error(
      'Firebase CLI runtime was not found. Install Firebase CLI and run firebase login first.',
    );
  }
}

async function main() {
  const auth = firebaseToolsModule('auth.js');
  const scopes = firebaseToolsModule('scopes.js');
  const account = auth.getProjectDefaultAccount(process.cwd());

  if (!account?.tokens?.refresh_token) {
    throw new Error('Firebase CLI is not logged in. Run firebase login first.');
  }

  const token = await auth.getAccessToken(account.tokens.refresh_token, [
    scopes.CLOUD_PLATFORM,
    scopes.FIREBASE_PLATFORM,
  ]);
  const ownerDocumentUrl =
    `https://firestore.googleapis.com/v1/projects/${encodeURIComponent(projectId)}` +
    `/databases/(default)/documents/owners/${encodeURIComponent(ownerId)}`;
  const headers = {Authorization: `Bearer ${token.access_token}`};
  const settingsDocumentUrl = `${ownerDocumentUrl}/settings/general`;

  const owner = await seedDocument(ownerDocumentUrl, headers, {});
  const legacyActive = owner.fields?.active?.booleanValue;
  await seedDocument(settingsDocumentUrl, headers, {
    active: {
      booleanValue: typeof legacyActive === 'boolean' ? legacyActive : true,
    },
    currencyCode: {stringValue: 'EGP'},
    currencyMinorDigits: {integerValue: '2'},
    stockControlEnabled: {booleanValue: true},
    manualPaymentEnabled: {booleanValue: true},
    cashOnDeliveryEnabled: {booleanValue: true},
    bannerEnabled: {booleanValue: true},
    bannerTitleAr: {stringValue: ''},
    bannerSubtitleAr: {stringValue: ''},
    bannerImageUrl: {nullValue: null},
    public: {booleanValue: true},
  });
  if (typeof legacyActive === 'boolean') {
    await removeLegacyOwnerActive(ownerDocumentUrl, headers);
  }

  const [verifiedOwner, verifiedSettings] = await Promise.all([
    readDocument(ownerDocumentUrl, headers),
    readDocument(settingsDocumentUrl, headers),
  ]);
  if (verifiedOwner.fields?.active) {
    throw new Error('Legacy owner active field still exists after migration.');
  }
  const active = verifiedSettings.fields?.active?.booleanValue;
  if (typeof active !== 'boolean') {
    throw new Error('Store settings were written without a valid active flag.');
  }

  console.log(
    `Seeded settings for owners/${ownerId} in Firebase project ${projectId}; active=${active}.`,
  );
}

async function readDocument(documentUrl, headers) {
  const response = await fetch(documentUrl, {headers});
  if (!response.ok) {
    throw new Error(
      `Unable to verify Firestore document (${response.status}): ${await response.text()}`,
    );
  }
  return response.json();
}

async function seedDocument(documentUrl, headers, defaults) {
  const current = await fetch(documentUrl, {headers});
  if (!current.ok && current.status !== 404) {
    throw new Error(
      `Unable to read Firestore document (${current.status}): ${await current.text()}`,
    );
  }

  const currentDocument = current.status === 404 ? null : await current.json();
  const now = new Date().toISOString();
  const fields = {updatedAt: {timestampValue: now}};
  const updateFields = ['updatedAt'];

  for (const [field, value] of Object.entries(defaults)) {
    if (!currentDocument?.fields?.[field]) {
      fields[field] = value;
      updateFields.push(field);
    }
  };

  if (current.status === 404) {
    fields.createdAt = {timestampValue: now};
    updateFields.push('createdAt');
  }

  const updateMask = updateFields
    .map((field) => `updateMask.fieldPaths=${encodeURIComponent(field)}`)
    .join('&');
  const updated = await fetch(`${documentUrl}?${updateMask}`, {
    method: 'PATCH',
    headers: {...headers, 'Content-Type': 'application/json'},
    body: JSON.stringify({fields}),
  });

  if (!updated.ok) {
    throw new Error(
      `Unable to seed owner document (${updated.status}): ${await updated.text()}`,
    );
  }

  return updated.json();
}

async function removeLegacyOwnerActive(documentUrl, headers) {
  const updateMask =
    'updateMask.fieldPaths=active&updateMask.fieldPaths=updatedAt';
  const updated = await fetch(`${documentUrl}?${updateMask}`, {
    method: 'PATCH',
    headers: {...headers, 'Content-Type': 'application/json'},
    body: JSON.stringify({
      fields: {updatedAt: {timestampValue: new Date().toISOString()}},
    }),
  });

  if (!updated.ok) {
    throw new Error(
      `Unable to remove legacy owner active field (${updated.status}): ${await updated.text()}`,
    );
  }
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
