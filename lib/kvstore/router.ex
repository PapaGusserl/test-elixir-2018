#TODO: Для веб сервера нужен маршрутизатор, место ему именно тут.
defmodule Kvstore.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get("/", do: send_resp(conn, 200, "Connect"))
  match(_, do: send_resp(conn, 404, "Ooops.."))

end
