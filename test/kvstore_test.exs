defmodule KvstoreTests do
  use ExUnit.Case

  @result_for_read {:ok, %{id: 1, username: "Vlad", rules: :admin, date: DateTime.utc_now()}}

  test "creating new row" do
    assert Kvstore.Storage.create(%{id: 1, username: "Vlad", rules: :admin, date: DateTime.utc_now()}, %{ttl: :infinit}) == {:ok}
  end

  test "read row on field :id" do
    assert Kvstore.Storage.read(%{id: 1}) == @result_for_read
  end

  test "read row on field :username" do
    assert Kvstore.Storage.read(%{username: "Vlad"}) == @result_for_read
  end

  test "read row on field :rules" do
    assert Kvstore.Storage.read(%{rules: :admin}) == @result_for_read
  end

  test "update row" do
    assert Kvstore.Storage.update(%{id: 1}, %{username: "Akhtyamov"}) == {:ok, %{id: 1, username: "Akhtyamov", rules: :admin}}
  end

  test "temple?" do
    Kvstore.Storage.create(%{id: 2, date: DateTime.utc_now()}, %{ ttl: 1})
    refute Kvstore.Storage.read(%{id: 2}) == @result_for_read
  end
end
