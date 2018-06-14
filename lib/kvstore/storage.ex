#TODO: Этот модуль должен реализовать механизмы CRUD для хранения данных. Если одного модуля будет мало, то допускается создание модулей с префиксом "Storage" в названии
defmodule Kvstore.Storage do
  alias Kvstore.Utils

  def start() do
    :dets.open_file(:storage, [type: :set])
  end

  def create(data, _ttl) do
    data = Utils.parse(:data, data)
    if :dets.insert_new(:storage, data) do
      {:ok}
    else
      {:error, "This key-field is already exist in storage!"}
    end
  end

  def read(keys) do
    keys = Utils.parse(:keys, keys)
    :dets.match_object(:storage, keys)
  end

  def update(old_data, new_data) do
    Utils.parse(:data, old_data) |> delete
    Utils.parse(:data, new_data) |> create
    {:ok}
  end

  def delete(data) do
    data = Utils.parse(:data, data)
    :dets.delete(:storage, data)
  end

end


