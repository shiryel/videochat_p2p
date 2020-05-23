# WrServer

To start your Phoenix server:

  * Setup the project with `mix setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

# Deploy

```
  SECRET_KEY_BASE=`mix phx.gen.secret`

  podman build \
    --build-arg SECRET_KEY_BASE=$SECRET_KEY_BASE \
    --tag "wr_server:latest" \
    .

  podman run -d "wr_server:latest"
```
