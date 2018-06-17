defmodule KvstoreTest do
  use ExUnit.Case

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

end
