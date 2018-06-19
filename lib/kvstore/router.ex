#TODO: Для веб сервера нужен маршрутизатор, место ему именно тут.
defmodule Kvstore.Router do
  use Plug.Router
  alias Kvstore.{Storage, Utils}
  require Logger

    plug Plug.Parsers, parsers: [:urlencoded, :multipart]


  plug Plug.Logger, log: :debug
  plug :match
  plug :dispatch

  get "/connect", do: send_resp(conn, 200, "Connect")
 

  post "/set" do
    
    body = case conn.body_params do
      %{key => value , "ttl" => ttl} -> Storage.create(key, value, ttl)
      %{key => value} -> Storage.create(key, value)
    end

    send_resp(conn, 200, "#{inspect body}")    
  end

  post "/get" do
    
    body = Storage.read(conn.body_params)
           |> Enum.map(fn x -> "#{inspect x}" end)
           |> Enum.join("\n")
    
    send_resp(conn, 200, body)    
  end

  post "/delete" do
    body = Storage.delete(conn.body_params)
    send_resp(conn, 200, "#{inspect body}")
  end

  match _, do: send_resp(conn, 404, "Ooops..")

end
