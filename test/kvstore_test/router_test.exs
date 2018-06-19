defmodule Kvstore.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Kvstore.Router.init([])

  setup_all do
    conn(:post, "/set", "key=key&value=value&ttl=3600")
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
    conn = conn(:post, "/set", "key=yek&value=eulav&ttl=6000")
           |> put_req_header("content-type", "application/x-www-form-urlencoded")
           |> Kvstore.Router.call(@opts)
    assert conn.status == 200
    assert conn.state == :sent
    assert conn.resp_body == "{:ok}"
  end

  test "set without ttl" do
    conn = conn(:post, "/set", "key=kek&value=vulav")
           |> put_req_header("content-type", "application/x-www-form-urlencoded")
           |> Kvstore.Router.call(@opts)
    assert conn.status == 200
    assert conn.state == :sent
    assert conn.resp_body == "{:ok}"
  end

  test "un-lucky set" do
    conn = conn(:post, "/set", "kexy=yek&vxalue=eulav&ttlx=6000")
           |> put_req_header("content-type", "application/x-www-form-urlencoded")
           |> Kvstore.Router.call(@opts)
    assert conn.status == 200
    assert conn.state == :sent
    assert conn.resp_body == "Invalid! Keys aren't found!"
  end

  test "get" do
    conn = conn(:post, "/get", "key=key")
           |> put_req_header("content-type", "application/x-www-form-urlencoded")
           |> Kvstore.Router.call(@opts)
    assert conn.state == :sent
    assert conn.status == 200
  end

  test "un-lucky get" do
    conn = conn(:post, "/get", "value=eulav")
           |> put_req_header("content-type", "application/x-www-form-urlencoded")
           |> Kvstore.Router.call(@opts)
    assert conn.status == 200
    assert conn.state == :sent
    assert conn.resp_body == "Invalid! Keys aren't found!"
  end

  test "delete" do
    conn = conn(:post, "/delete", "key=key")
           |> put_req_header("content-type", "application/x-www-form-urlencoded")
           |> Kvstore.Router.call(@opts)
    assert conn.status == 200
    assert conn.state == :sent
    assert conn.resp_body == ":ok"
  end


end
