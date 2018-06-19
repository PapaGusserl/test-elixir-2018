#TODO: Этот модуль должен реализовать механизмы CRUD для хранения данных. Если одного модуля будет мало, то допускается создание модулей с префиксом "Storage" в названии
defmodule Kvstore.Storage do
  alias Kvstore.Utils

  require Logger
  ## CRUD построена на :dets, т.к. в 
  ## данном случае не требуется более мощный функционал,
  ## который может предоставить mnesia или Postgres
  
  ##  При входе в любую из структур CRUD 
  ##  и выходе из нее data представляет собой map или struct,
  ##  из-за чего приходится использовать парсеры и ан-парсеры
  ##  этого можно избежать, изменив формат входных и выходных 
  ##  данных, хотя мне представляется наиболее очевидным 
  ##  вариантом использования данных структур

 use GenServer
  alias Kvstore.Utils
 
  # Так как нам необходимо предусмотреть возможность
  # отключения программы с сохранением предустановленного
  # времени жизни, то привязка ttl идет не относительному 
  # "через сколько необходимо записи удалиться", а к 
  # абсолютному времени

  def start() do
    :dets.open_file(:ttl, [type: :set])
    :dets.open_file(:storage, [type: :set])
    {:ok, pid} = start_link()
    GenServer.cast(pid, :check_after_power_off)
    {:ok, pid}
  end

  ### API

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def create(data) do
    data_rec = Utils.parse(:data, data)
    if :dets.insert_new(:storage, data_rec) do
      key_field = data_rec |> Tuple.to_list |> Enum.at(0)
      ttl = unless Map.has_key?(data, :ttl), do:  Application.get_env(:kvstore, :default_ttl), else: String.to_integer(data.ttl)
      # если ttl передается в формате секунд, его необходимо переделать в "дату смерти"
      date_of_death = Utils.parse(:ttl, data.date, ttl)
      # сохраняем в dets, чтобы между сеансами ничего не потерялось
      :dets.insert_new(:ttl, {key_field, date_of_death})
      # в state  не отправляем, так как там у нас хранится только то, что
      # осталось с прошлой сессии 
      # and send to killing ttl in milliseconds, becouse we hope, that 
      # shit will selfkill in our session
      # never forget, that ttl was in seconds
      GenServer.cast(__MODULE__, {:set_timer, key_field, ttl*1000})
      {:ok}
    else
      {:error, "This key-field is already exist in storage!"}
    end
 end

  def read(keys) do
    keys = Utils.parse(:keys, keys)
    result = :dets.match_object(:storage, keys)
    |> Enum.map( 
      fn tuple -> 
        ttl = :dets.match_object(:ttl, {elem(tuple, 0), :"_"})
        |> Enum.at(0) #выбираем значение из списка(единственное, поэтому первое)
        |> elem(1) #выбираем дату смерти
        [tuple] |> Utils.un_parse([]) |> Enum.at(0)
        |> Map.merge(%{date_of_death: ttl})
      end)
  end

  def update(key, new_data) do
    old_data = read(key) |> Enum.at(0)
    key = key |> Map.values |> Enum.at(0) 
    delete(:key, key)
    Map.merge(old_data, new_data)
    |> create
  end

  def delete(:keys, keys) do
    Logger.info("delete #{inspect keys} from data_base")
    keys = Utils.parse(:data, keys)
    :dets.match_object(:storage, keys)
    |> Enum.map(
       fn obj ->
         :dets.delete(:storage, elem(obj,0))
         :dets.delete(:ttl, elem(obj, 0))
       end)  
   end

  def delete(:key, key) do
    Logger.info("delete #{key} from data_base")
    :dets.delete(:storage, key)
    :dets.delete(:ttl, key)
  end
  

  ### Callbacks
  
  def init(state) do
    state = :dets.match_object(:ttl, {:"_", :"_"}) 
    {:ok, state}
  end

  def handle_cast(:check_after_power_off, []), do: {:noreply, []}

  require Logger
  def handle_cast(:check_after_power_off, state) do
    state
    |>Enum.map( 
      fn {key, date_of_death} ->
          if DateTime.to_unix(date_of_death) <= DateTime.to_unix(DateTime.utc_now()) do
            GenServer.cast(self(), {:delete, key})
          else
            Process.send_after(self(), {:delete, key}, (DateTime.to_unix(date_of_death) - DateTime.to_unix(DateTime.utc_now))*1000)
          end
      end)
    {:noreply, state}
  end

  def handle_cast({:delete, key}, state) do 
    delete(:key, key)
    # if in state exist key, then delete this too
    new_state = key |> key_exist?(state) 
    {:noreply, new_state}
  end

  def handle_info({:delete, key}, state) do
    GenServer.cast(self(), {:delete, key})
    {:noreply, state}
  end

  def handle_cast({:set_timer, key, ttl}, state) do
    Process.send_after(self(), {:delete, key}, ttl)
    {:noreply, state}
  end


  def key_exist?(key, state) do
    state
    |> Enum.filter( fn {k, v} -> k == key end)
    |> (fn
      [{key, value}] -> state -- [{key, value}]
      ______________ -> state
    end).()
  end

end


