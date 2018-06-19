defmodule Kvstore.Utils do

  @cliche Application.get_env(:kvstore, :keys)

  def parse(:conn, params) do
    params
    |> Map.to_list
    |> Enum.map(fn {key, value} -> {String.to_atom(key), value} end)
    |> Enum.into(%{})
  end

  def valid?(:data, data, fun) do
    valid?(:keys, data, &(&1))
#   |> have_errors?(&(valid?(:values, &1)))
    |> have_errors?(fun)
  end

  def valid?(:data, old_data, new_data, fun) do
    valid?(:data, old_data, &(&1))
    |> have_errors?( fn data ->
                      valid?(:data, new_data, &(&1))
                      |> have_errors?(data, fun)
                    end)
  end

  def valid?(:keys, data, fun) do
    unless Enum.empty?(data) do
      data
      |> Map.keys
      |> Enum.map(
        fn key ->
          Application.get_env(:kvstore, :keys) 
          |> Enum.into(%{}) 
          |> Map.has_key?(key)
          |> (fn
            false -> "Key #{key} isn't exist!"
            true -> nil
          end).()
        end)
        |> empty?(data, fun)
      else
      {:error, "Data is empty!"}
    end

  end

  def valid?(:values, data) do
    unless Enum.empty?(data) do
       Application.get_env(:kvstore, :keys)
       |> Enum.map( fn {key, value} ->
         case value do
           :atom   -> unless data[key] |> is_atom , do: "#{key} must be atom!", else: nil
           :string -> unless data[key] |> is_binary , do: "#{key} must be string!", else: nil
           :int    -> unless data[key] |> is_integer , do: "#{key} must be integer!", else: nil
           :date   -> unless data[key] |> is_date , do: "#{key} must be date!", else: nil
           _       -> "There aren't so type of data!"
           end
       end)
       |> empty?(data, &(&1))
      else
      {:error, "Data is empty!"}
    end
  end


    defp is_date(%DateTime{}), do: :true
    defp is_date(_), do: :false
    defp have_errors?({:error, reason}, _fun), do: {:error, reason}
    defp have_errors?(data, fun), do: fun.(data)
    defp have_errors?(new, old, fun), do: fun.(old, new)
    defp empty?(arr, data, fun) do
      arr
      |> Enum.filter(fn x -> x != nil end)
      |> case do
        [] -> fun.(data)
        errors -> {:error, Enum.join(errors, ";\n")}
      end
    end



  def parse(:keys, keys) do
    @cliche
    |> Enum.map(
      fn {key, _value} -> 
        if Map.has_key?(keys, key) do
          keys[key]
        else
          :"_"
        end
      end)
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
    |> Enum.map(fn {k, _} -> k end) #takes keys
    |> Enum.zip(data)               #zip with data
    |> Enum.into(%{})               #transform
  end

  def parse(:ttl, date, sec) do
    now = date |> DateTime.to_unix
    now - sec
    |> DateTime.from_unix!
  end   

end
