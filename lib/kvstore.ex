defmodule Kvstore do 
  use Application
  require Logger
  alias Kvstore.{Storage, Router}

  def start(_args, _opts) do
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Router, [], port: 8080)
                ]
    opts = [strategy: :one_for_one ]
    Logger.info("Starting....")
    Storage.start()
    Supervisor.start_link(children, opts)
  end

end
