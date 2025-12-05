importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js');

// Initialize the Firebase app in the service worker
// Replace these with your actual Firebase config values
firebase.initializeApp({
  apiKey: "AIzaSyDXTb_isY_PZAwY0GeRGcTkJwVMvRAJvJU",
  authDomain: "mis-lab3-13f9f.firebaseapp.com",
  projectId: "mis-lab3-13f9f",
  storageBucket: "mis-lab3-13f9f.firebasestorage.app",
  messagingSenderId: "146775473450",
  appId: "1:146775473450:web:998ded2d6840f80c617253",
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  
  const notificationTitle = payload.notification.title || 'Recipe App';
  const notificationOptions = {
    body: payload.notification.body || 'Check out today\'s recipe!',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: 'recipe-notification',
    requireInteraction: true,
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification click
self.addEventListener('notificationclick', (event) => {
  console.log('[Service Worker] Notification click received.');
  event.notification.close();
  
  event.waitUntil(
    clients.openWindow('/')
  );
});

