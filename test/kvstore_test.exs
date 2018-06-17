defmodule KvstoreTest do 
  use ExUnit.Case

  test "parsing of ttl" do
    refute Kvstore.Utils.parse(:ttl, 240) == DateTime.utc_now
  end

  test "existing of key in state" do
    assert Kvstore.Storage.key_exist?(:key, [{"key", "value"}, {1, :value}, {:key, :value}]) == [{"key", "value"}, {1, :value}]
  end

  test "non-existing of key in state" do
    assert Kvstore.Storage.key_exist?(:cluch, [{"key", "value"}, {1, :value}, {:key, :value}]) == [{"key", "value"}, {1, :value}, {:key, :value}]
  end


 

end 
