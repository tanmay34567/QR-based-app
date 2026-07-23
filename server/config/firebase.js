const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

let firebaseApp = null;

const initFirebase = () => {
  if (firebaseApp) return firebaseApp;

  const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH || './config/firebase-service-account.json';
  const resolvedPath = path.resolve(serviceAccountPath);

  try {
    if (fs.existsSync(resolvedPath)) {
      const serviceAccount = require(resolvedPath);
      firebaseApp = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
      });
      console.log('Firebase Admin SDK initialized successfully with Service Account file.');
    } else if (process.env.FIREBASE_SERVICE_ACCOUNT_KEY) {
      const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_KEY);
      firebaseApp = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
      });
      console.log('Firebase Admin SDK initialized successfully with ENV JSON string.');
    } else {
      console.warn('⚠️ Warning: Firebase Service Account file not found at:', resolvedPath);
      console.warn('Firebase Admin SDK initializing with default app credential / applicationDefault fallback.');
      firebaseApp = admin.initializeApp({
        credential: admin.credential.applicationDefault()
      });
    }
  } catch (err) {
    console.error('Firebase Admin SDK initialization warning:', err.message);
  }

  return firebaseApp;
};

module.exports = {
  admin,
  initFirebase
};
