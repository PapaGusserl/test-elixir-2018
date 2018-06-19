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
 

  post "/create" do
    params = Utils.parse(:conn, conn.body_params)
             |> Map.merge(%{date: DateTime.utc_now()})
    body = Utils.valid? :data, 
                        params, 
                        &(Storage.create(&1))
    send_resp(conn, 200, "#{inspect body}")    
  end

  post "/read" do
    params = Utils.parse(:conn, conn.body_params)
    body = Utils.valid?(:data, 
                        params,
                        &(Storage.read(&1)))
                        |> Enum.map(fn x -> "#{inspect x}" end)
                        |> Enum.join("\n")
    send_resp(conn, 200, body)    
  end


  #костыльная связка: апдейтить можно только по id 
  post "/update" do 
    key = %{id: conn.body_params["id"]}
    new_params = Utils.parse(:conn, conn.body_params)
             |> Map.merge(%{date: DateTime.utc_now()})
             |> Map.delete(:id)
    body = Utils.valid? :data, 
                        key, 
                        new_params, 
                        &(Storage.update(&1, &2))
    send_resp(conn, 200, "#{inspect body}")
  end

  #здесь тоже пока будет костыль
  post "/delete" do
    keys = Utils.parse(:conn, conn.body_params)
    body = Utils.valid? :data,
                        keys,
                        &(Storage.delete(:keys, &1))
    send_resp(conn, 200, "#{inspect body}")
  end

  match _, do: send_resp(conn, 404, "Ooops..")

end
