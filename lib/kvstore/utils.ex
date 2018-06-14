defmodule Kvstore.Utils do

  @cliche Application.get_env(:kvstore, :keys)

  def parse(:keys, keys) do
    @cliche
    |> Map.new(fn {key, value} -> {key, :"_"} end)
    |> Map.merge(keys)
    |> Map.values
  end

  def parse(:data, data), do: parse(:keys, data)

  def un_parse([], state), do: state

  def un_parse([head | tail], state) do
    state = un_parse(head)
    un_parse([tail], state)
  end

  def un_parse(data) do
    @cliche |> Map.keys |> Enum.zip(data)
  end

end
