defmodule Kvstore.Utils do

  def parse(:keys, keys) do
    Application.get_env(:kvstore, :keys)
    |> Map.new(fn {key, value} -> {key, :"_"} end)
    |> Map.merge(keys)
  end

end
