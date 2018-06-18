#TODO: Этот модуль должен реализовать механизмы CRUD для хранения данных. Если одного модуля будет мало, то допускается создание модулей с префиксом "Storage" в названии
defmodule Kvstore.Storage do
  alias Kvstore.Utils

  ## CRUD построена на :dets, т.к. в 
  ## данном случае не требуется более мощный функционал,
  ## который может предоставить mnesia или Postgres
  
  def start() do
    :dets.open_file(:storage, [type: :set])
  end

  ##  При входе в любую из структур CRUD 
  ##  и выходе из нее data представляет собой map или struct,
  ##  из-за чего приходится использовать парсеры и ан-парсеры
  ##  этого можно избежать, изменив формат входных и выходных 
  ##  данных, хотя мне представляется наиболее очевидным 
  ##  вариантом использования данных структур

  def create(data) do    
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
    |> Utils.un_parse([])
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


