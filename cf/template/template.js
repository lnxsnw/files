// Hear me out, this format somehow fixes the headaches of workers code not working "sometimes".
addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request));
});

async function handleRequest(request) {
  // Code Goes Here
}