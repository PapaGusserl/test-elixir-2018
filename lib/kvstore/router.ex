#TODO: Для веб сервера нужен маршрутизатор, место ему именно тут.
defmodule Kvstore.Router do
  use Plug.Router
  alias Kvstore.Storage

  plug :match
  plug :dispatch
  plug Plug.Logger, log: :debug

  get "/", do: send_resp(conn, 200, "Connect")

  post "/create" do
    body = valid? :data, 
                  conn.body_params, 
                  Storage.create
    send_resp(conn, 200, body)    
  end

  post "/read" do
    body = valid? :keys, 
                  conn.body_params,
                  Storage.read
    send_resp(conn, 200, body)    
  end


  post "/update" do
    body = valid? :data, 
                  conn.body_params.old_data, 
                  conn.body_params.new_data, 
                  Storage.update
    send_resp(conn, 200, body)
  end

  post "/delete" do
    body = valid? :data,
                  conn.body_params,
                  Storage.delete
    send_resp(conn, 200, body)
  end

  match _, do: send_resp(conn, 404, "Ooops..")

end
