defmodule Kvstore.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Kvstore.Router.init([])

  setup_all do
    conn = conn(:post, "/set", "username=router&ttl=3600")
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

  test "set" do
    conn = conn(:post, "/set", "username=router&ttl=6000")
           |> put_req_header("content-type", "application/x-www-form-urlencoded")
           |> Kvstore.Router.call(@opts)
    assert conn.status == 200
    assert conn.state == :sent
    assert conn.resp_body == "{:ok}"
  end

  test "get" do
    conn = conn(:post, "/read", "username")
           |> put_req_header("content-type", "application/x-www-form-urlencoded")
           |> Kvstore.Router.call(@opts)
    assert conn.status == 200
    assert conn.state == :sent
  end


end
