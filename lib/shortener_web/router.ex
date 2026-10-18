defmodule ShortenerWeb.Router do
  use ShortenerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ShortenerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Shortener.Features do
    pipe_through :browser

    live "/", ShortenTargetUrlForVisitor.Live
    live "/user-links", ShortenTargetUrlForUser.Live
    live "/plans", AssignPlanToUser.Live
  end

  # Other scopes may use custom stacks.
  # scope "/api", ShortenerWeb do
  #   pipe_through :api
  # end
end
