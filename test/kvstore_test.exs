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
    refute Kvstore.Utils.parse(:ttl, DateTime.utc_now(), 240) == DateTime.utc_now
  end

  test "existing of key in state" do
    assert Kvstore.Storage.key_exist?(:key, [{"key", "value"}, {1, :value}, {:key, :value}]) == [{"key", "value"}, {1, :value}]
  end

  test "non-existing of key in state" do
    assert Kvstore.Storage.key_exist?(:cluch, [{"key", "value"}, {1, :value}, {:key, :value}]) == [{"key", "value"}, {1, :value}, {:key, :value}]
  end


 
  @data %{id: "1", ttl: "10000", username: "vlad", rules: "admin", date: DateTime.utc_now()}

  @date_of_death Kvstore.Utils.parse(:ttl, @data.date, String.to_integer(@data.ttl))

  @result_for_read %{id: "1", date_of_death: @date_of_death, username: "vlad", rules: "admin", date: DateTime.utc_now()}


  setup_all do
    Kvstore.Storage.create(@data)
    {:ok, []}
  end

  test "read row on field id" do
    result = Kvstore.Storage.read(%{id: "1"}) |> Enum.at(0)
    assert result.id == @result_for_read.id
    assert result.username == @result_for_read.username
    assert result.rules == @result_for_read.rules
    assert_in_delta DateTime.to_unix(result.date_of_death), DateTime.to_unix(@result_for_read.date_of_death), 1
    assert result.date_of_death == @result_for_read.date_of_death
  end

  test "read row on field :username" do
    result = Kvstore.Storage.read(%{username: "vlad"}) |> Enum.at(0)
    assert result.id == @result_for_read.id
    assert result.username == @result_for_read.username
    assert result.rules == @result_for_read.rules
    assert_in_delta DateTime.to_unix(result.date_of_death), DateTime.to_unix(@result_for_read.date_of_death), 1
    assert result.date_of_death == @result_for_read.date_of_death
  end

  test "update row" do
    assert Kvstore.Storage.update(%{id: "1"}, %{id: "1", rules: "admin", username: "Akhtyamov"}) == {:ok}
  end

end
