defmodule Kvstore.Utils do

  @cliche Application.get_env(:kvstore, :keys)

  def parse(:keys, keys) do
    @cliche
    |> Enum.into(%{})
    |> Map.new(fn {key, value} -> {key, :"_"} end)
    |> Map.merge(keys)
    |> Map.values
    |> Enum.sort
    |> List.to_tuple
  end

  def parse(:data, data), do: parse(:keys, data)

  def un_parse([], state), do: state

  def un_parse([head | tail], state) do
    state = state ++ [un_parse(head)]
    un_parse(tail, state)
  end

  def un_parse(data) do
    data = data |> Tuple.to_list
    @cliche 
    |> Enum.map(fn {k, v} -> k end) #takes keys
    |> Enum.zip(data)               #zip with data
    |> Enum.into(%{})               #transform
  end

end
