/**
 * https://github.com/simonw/til/blob/main/cloudflare/robots-txt-cloudflare-workers.md
 */

addEventListener("fetch", (event) => {
  event.respondWith(
    handleRequest(event.request).catch(
      (err) => new Response(err.stack, { status: 500 })
    )
  );
});

async function handleRequest(request) {
  const { pathname } = new URL(request.url);
  if (pathname == "/robots.txt") {
    return new Response("User-agent: *\nDisallow: /", {
      headers: { "Content-Type": "text/plain" },
    });
  }
}
