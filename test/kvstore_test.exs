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

end
