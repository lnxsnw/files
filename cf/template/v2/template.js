export default {
  async fetch(request, env, ctx) {
    //
    // https://developers.cloudflare.com/workers/reference/migrate-to-module-workers/
    //
    // Example: parse the request URL
    const url = new URL(request.url);

    // You can use different routing strategies here
    switch (url.pathname) {
      case "/":
        return new Response("Welcome to the homepage!", {
          status: 200,
          headers: { "Content-Type": "text/plain" }
        });

      case "/about":
        return new Response("About us page", {
          status: 200,
          headers: { "Content-Type": "text/plain" }
        });

      case "/redirect":
        return Response.redirect("https://example.com", 302);

      default:
        return new Response("Not found", {
          status: 404,
          headers: { "Content-Type": "text/plain" }
        });
    }
  }
};
