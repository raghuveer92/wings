importScripts("https://www.gstatic.com/firebasejs/7.5.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/7.5.0/firebase-messaging.js");
firebase.initializeApp({
   apiKey: "AIzaSyA2Bm0CvMAaf0kemKt5_S8mYlUy6emV73w",
     authDomain: "wings-7862b.firebaseapp.com",
     databaseURL: "https://wings-7862b.firebaseio.com",
     projectId: "wings-7862b",
     storageBucket: "wings-7862b.appspot.com",
     messagingSenderId: "904843918958",
     appId: "1:904843918958:web:c59d7490c11cb25374707f",
     measurementId: "G-CR31Q6BPD7"
});
const messaging = firebase.messaging();
messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            return registration.showNotification("New Message");
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});