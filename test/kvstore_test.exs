defmodule KvstoreTest do
  use ExUnit.Case

  test "validation right fields" do
    map = %{id: 1, username: "Vlad", rules: :admin, date: DateTime.utc_now()}
    assert Kvstore.Utils.valid?(:data, map, &(&1)) == map
  end

  test "validation empty fields" do
    map = %{}
    assert Kvstore.Utils.valid?(:data, map, &(&1)) == {:error, "Data is empty!"}
  end

  test "validation wrong fields" do
    map = %{idt: 1, user: :boy}
    assert Kvstore.Utils.valid?(:data, map, &(&1)) == {:error, "Key idt isn't exist!;\nKey user isn't exist!" }
  end

  test "parsing :keys" do
    date = DateTime.utc_now()
    assert Kvstore.Utils.parse(:keys, %{id: 1, date: date}) == {1, :"_", :"_", date}
  end

  test "parsing :data" do 
    date = DateTime.utc_now()
    assert Kvstore.Utils.parse(:data, %{id: 1, date: date, rules: :admin, username: "Vlad"}) == {1, :admin, "Vlad", date}
  end

  test "parsing non-config data" do
    refute Kvstore.Utils.parse(:data, %{vlad: :rules, admin: true}) == {:rules, true}
  end

  test "un_parsing data" do
    assert Kvstore.Utils.un_parse([{1, :admin, "Vlad", nil}, {2, :mod, "Milyausha", nil}], []) == [%{id: 1, rules: :admin, username: "Vlad", date: nil}, %{id: 2, rules: :mod, username: "Milyausha", date: nil}]
  end

  test "parsing of ttl" do
    refute Kvstore.Utils.parse(:ttl, 240) == DateTime.utc_now
  end

  test "existing of key in state" do
    assert Kvstore.Storage.key_exist?(:key, [{"key", "value"}, {1, :value}, {:key, :value}]) == [{"key", "value"}, {1, :value}]
  end

  test "non-existing of key in state" do
    assert Kvstore.Storage.key_exist?(:cluch, [{"key", "value"}, {1, :value}, {:key, :value}]) == [{"key", "value"}, {1, :value}, {:key, :value}]
  end


 

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
