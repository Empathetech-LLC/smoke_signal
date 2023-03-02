// The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access Firestore.
const admin = require('firebase-admin');
admin.initializeApp();

// Notify signal members when someone has joined
exports.sendPush = functions.https.onCall(async (data, context) => {
  // Gather the tokens
  const tokens = Array(data.tokens)

  // Send the notifications
  tokens.forEach(token => 
    admin.messaging().sendToDevice(
      token,
      {
        notification: {
          title: String(data.title),
          body: String(data.body)
        }
      }
    )
  );
});
