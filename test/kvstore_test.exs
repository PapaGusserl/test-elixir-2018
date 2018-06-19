defmodule KvstoreTest do
  use ExUnit.Case

  test "parsing of ttl" do
    refute Kvstore.Utils.parse(:ttl, DateTime.utc_now(), 240) == DateTime.utc_now
  end

end
