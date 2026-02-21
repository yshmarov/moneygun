// Network-first with cache fallback for document requests.
// Non-GET requests and non-document fetches are left to the browser default.
self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET') return
  if (event.request.destination !== 'document') return

  event.respondWith(fetch(event.request, { cache: 'no-cache' }).catch(() => caches.match(event.request)))
})

self.addEventListener('push', async event => {
  const { title, options } = await event.data.json()
  event.waitUntil(self.registration.showNotification(title, options))
})

self.addEventListener('notificationclick', function (event) {
  event.notification.close()
  event.waitUntil(
    clients.matchAll({ type: 'window' }).then(clientList => {
      for (let i = 0; i < clientList.length; i++) {
        let client = clientList[i]
        let clientPath = new URL(client.url).pathname

        if (clientPath == event.notification.data.path && 'focus' in client) {
          return client.focus()
        }
      }

      if (clients.openWindow) {
        return clients.openWindow(event.notification.data.path)
      }
    })
  )
})
