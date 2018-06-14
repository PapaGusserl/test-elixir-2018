defmodule Kvstore.Utils do

  def valid?(:data, data, fun) do
    valid?(:keys, data, &(&1))
     valid?(:values, data)
    fun(data)
  end

  def valid?(:data, old_data, new_data, fun) do
    valid?(:data, old_data, &(&1))
    valid?(:data, new_data, &(&1))
    fun(old_data, new_data)
  end

  def valid?(:keys, data, fun) do
    unless Enum.empty?(data) do
      result = data
               |> Map.keys
               |> Enum.map(fn key ->
                 exist = Application.get_env(:kvstore, :keys) |> Map.has_key?(key)
                 unless exist, do: "Key #{key} isn't exist!"
                 end)
      unless Enum.empty?(result), do: {:error, Enum.join(result, ";/n")} else: fun(data)
      else
      {:error, "Data is empty!"}
    end

  end

  def valid?(:values, data) do
    unless Enum.empty?(data) do
       result = Application.get_env(:kvstore, :keys)
                |> Enum.map( fn {key, value} ->
                  case value do
                    :atom   -> unless Enum.fetch!(data, key) |> is_atom , do: "#{key} must be atom!"
                    :string -> unless Enum.fetch!(data, key) |> is_binary , do: "#{key} must be string!"
                    :int    -> unless Enum.fetch!(data, key) |> is_integer , do: "#{key} must be integer!"
                    :date   -> unless Enum.fetch!(data, key) |> is_date , do: "#{key} must be date!"
                    _       -> "There aren't so type of data!"
                  end
                end)
      unless Enum.empty?(result), do: {:error, Enum.join(result, ";/n")} else: data
      else
      {:error, "Data is empty!"}
    end
  end


    defp is_date(%DateTime{}), do: :true
    defp is_date(_), do: :false

end
