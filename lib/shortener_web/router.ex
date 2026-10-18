defmodule ShortenerWeb.Router do
  use ShortenerWeb, :router

  import ShortenerWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ShortenerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # The pages that a visitor needs. A logged-in user also reaches them.
  scope "/", Shortener.Features do
    pipe_through :browser

    live_session :current_user, on_mount: [{ShortenerWeb.UserAuth, :mount_current_scope}] do
      live "/", ShortenTargetUrlForVisitor.Live
      live "/log-in", SendLoginLinkToUser.Live
      live "/log-in/:token", RedeemLoginTokenOfUser.Live
    end

    post "/log-in", RedeemLoginTokenOfUser.Controller, :create
    delete "/log-out", EndLoginSessionOfUser.Controller, :delete
  end

  # The pages of a logged-in user. The plug guards each HTTP request, and the
  # callback guards each live navigation.
  scope "/", Shortener.Features do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ShortenerWeb.UserAuth, :require_authenticated}] do
      live "/user-links", ShortenTargetUrlForUser.Live
      live "/plans", AssignPlanToUser.Live
    end
  end

  if Application.compile_env(:shortener, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  # The resolution of a short URL needs no session and no layout. Its route
  # is after each page route, and a page path is not a short code.
  scope "/", Shortener.Features do
    get "/:short_code", ResolveTargetUrlOfShortUrl.Controller, :show
  end
end
