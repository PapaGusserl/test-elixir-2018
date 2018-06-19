defmodule Kvstore.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Kvstore.Router.init([])

  setup_all do
    conn = conn(:post, "/create", "id=3&username=router&rules=admin&ttl=6000")
           |> put_req_header("content-type", "application/x-www-form-urlencoded")
           |> Kvstore.Router.call(@opts)
    {:ok, []}
  end
 

  test "connecting" do
    conn = conn(:get, "/connect")
    conn = Kvstore.Router.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Connect"
  end

  test "404" do
    conn = conn(:get, "/music")
           |> Kvstore.Router.call(@opts)
    assert conn.status == 404
  end

  test "unlucky creating" do
    conn = conn(:post, "/create", "itd=1&usename=4000")
           |> put_req_header("content-type", "application/x-www-form-urlencoded")
           |> Kvstore.Router.call(@opts)
    assert conn.status == 200
    assert conn.state == :sent
    assert conn.resp_body == "{:error, \"Key itd isn't exist!;\\nKey usename isn't exist!\"}"
  end

  test "creating" do
    conn = conn(:post, "/create", "id=2&username=router&rules=admin&ttl=6000")
           |> put_req_header("content-type", "application/x-www-form-urlencoded")
           |> Kvstore.Router.call(@opts)
    assert conn.status == 200
    assert conn.state == :sent
    assert conn.resp_body == "{:ok}"
  end

  test "reading" do
    conn = conn(:post, "/read", "id=3")
           |> put_req_header("content-type", "application/x-www-form-urlencoded")
           |> Kvstore.Router.call(@opts)
    assert conn.status == 200
    assert conn.state == :sent
    assert conn.resp_body == "%{date: #DateTime<2018-06-19 08:19:38.112956Z>, date_of_death: #DateTime<2018-06-19 06:39:38Z>, id: \"3\", rules: \"admin\", username: \"router\"}"
  end


end
