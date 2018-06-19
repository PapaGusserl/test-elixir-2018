defmodule Kvstore.Utils do

  def parse(:ttl, date, sec) do
    now = date |> DateTime.to_unix
    now + sec
    |> DateTime.from_unix!
  end   

end
