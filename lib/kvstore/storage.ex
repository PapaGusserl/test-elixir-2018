#TODO: Этот модуль должен реализовать механизмы CRUD для хранения данных. Если одного модуля будет мало, то допускается создание модулей с префиксом "Storage" в названии
defmodule Kvstore.Storage do
  alias Kvstore.Utils

  def start() do
    :dets.open_file(:storage, [type: :set])
  end

  def create(data, _ttl) do
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
    :dets.delete(old_data)
    :dets.insert_new(new_data)
    {:ok}
  end

  def delete(data) do
    :dets.delete(:storage, data)
  end

end


