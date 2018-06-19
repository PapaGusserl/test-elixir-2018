#TODO: Для веб сервера нужен маршрутизатор, место ему именно тут.
defmodule Kvstore.Router do
  use Plug.Router
  alias Kvstore.Storage
  require Logger

  @req_invalid "Invalid! Keys aren't found!"


  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  plug Plug.Logger, log: :debug
  plug :match
  plug :dispatch

  get "/connect", do: send_resp(conn, 200, "Connect")
 

  post "/set" do
    
    body = case conn.body_params do
      %{"key" => key, "value" => value , "ttl" => ttl} -> Storage.set(key, value, ttl) |> inspect
      %{"key" => key, "value" => value} -> Storage.set(key, value) |> inspect
      _ -> @req_invalid
    end

    send_resp(conn, 200, body)    
  end

  post "/get" do
    body = case conn.body_params do
      %{"key" => key} -> Storage.get(key)
      _ -> @req_invalid
    end
    send_resp(conn, 200, body)    
  end

  post "/delete" do
    body = case conn.body_params do
      %{"key" => key} -> Storage.delete(key)
      _ -> @req_invalid
    end
    send_resp(conn, 200, inspect body)
  end

  match _, do: send_resp(conn, 404, "Ooops..")

end
