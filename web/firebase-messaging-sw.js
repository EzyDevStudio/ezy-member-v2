// Import Firebase scripts for messaging
importScripts('https://www.gstatic.com/firebasejs/9.22.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.1/firebase-messaging-compat.js');

// Initialize Firebase with your Web config
firebase.initializeApp({
  apiKey: 'AIzaSyBxHSxAZOWhB1RONdZLEITiw1297auhXT0',
  authDomain: 'ezymember-1a58c.firebaseapp.com',
  projectId: 'ezymember-1a58c',
  storageBucket: 'ezymember-1a58c.firebasestorage.app',
  messagingSenderId: '551410384420',
  appId: '1:551410384420:web:a9b56df81a2c002bdae2b1',
  measurementId: 'G-9R1ZCK87FY'
});

// Retrieve an instance of Firebase Messaging
const messaging = firebase.messaging();

// Optional: Handle background messages
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/favicon.png' // optional
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});