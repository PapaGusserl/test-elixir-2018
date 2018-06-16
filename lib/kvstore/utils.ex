defmodule Kvstore.Utils do

  def parse(:ttl, sec) do
    now = DateTime.utc_now |> DateTime.to_unix
    now - sec
    |> DateTime.from_unix!
  end   

end
