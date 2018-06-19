defmodule Kvstore do 
  use Application
  require Logger
  alias Kvstore.Storage

  def start(_args, _opts) do
    import Supervisor.Spec

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Kvstore.Router, [], port: 4000),
      worker(Kvstore.Storage, [], name: Kvstore.Storage)
    ]

    opts = [ strategy: :one_for_one ]
    
    Logger.info("Starting....")
    
    {:ok, pid} = Supervisor.start_link(children, opts)
    Storage.run_db()
    
    {:ok, pid}
  end

end
