importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyA3jgXc_5Uz3w_RWSzGRVLpyjuVewniko8",
  appId: "1:109289610484:web:291e6e645200ad46c292a1",
  messagingSenderId: "109289610484",
  projectId: "finalboer-3bb5d",
  authDomain: "finalboer-3bb5d.firebaseapp.com",
});

const messaging = firebase.messaging();

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
});

messaging.onBackgroundMessage((payload) => {
  const title = (payload && payload.notification && payload.notification.title) || 'Nova Notificação';
  const body = (payload && payload.notification && payload.notification.body) || '';
  const options = { body, icon: '/icons/Icon-192.png' };
  self.registration.showNotification(title, options);
});

