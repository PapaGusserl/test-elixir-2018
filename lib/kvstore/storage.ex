#TODO: Этот модуль должен реализовать механизмы CRUD для хранения данных. Если одного модуля будет мало, то допускается создание модулей с префиксом "Storage" в названии
defmodule Kvstore.Storage do

  use GenServer
  alias Kvstore.Utils
 
  # Так как нам необходимо предусмотреть возможность
  # отключения программы с сохранением предустановленного
  # времени жизни, то привязка ttl идет не относительному 
  # "через сколько необходимо записи удалиться", а к 
  # абсолютному времени

  def start() do
    :dets.open_file(:ttl, [type: :set])
    {:ok, pid} = start_link()
    GenServer.cast(pid, :check_after_power_off)
    {:ok, pid}
  end

  ### API

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def create(data) do
    key_field = Enum.first(data)
    ttl = if data.ttl == nil, do:  Application.get_env(:kvstore, :default_ttl), else: data.ttl
    # если ttl передается в формате секунд, его необходимо переделать в "дату смерти"
    date_of_death = Utils.parse(:ttl, ttl)
    # сохраняем в dets, чтобы между сеансами ничего не потерялось
    :dets.insert_new(:ttl, {key_field, date_of_death})
    # в state  не отправляем, так как там у нас хранится только то, что
    # осталось с прошлой сессии 
    # and send to killing ttl in milliseconds, becouse we hope, that 
    # shit will selfkill in our session
    GenServer.cast(__MODULE__, {:set_timer, key_field, data.ttl})
  end

  def read(data) do
    data #result 
    |> Enum.map( 
      fn map -> 
        :dets.match_object(:ttl, {Enum.first(map), :"_"})
        |>Map.merge(map) 
      end)
  end

  def update(old_data, new_data) do
  end

  def delete(data) do
    :dets.delete(:ttl, data)
  end

  ### Callbacks
  
  def init(state) do
    state = [state | :dets.match_object(:ttl, {:"_", :"_"}) ]
    {:ok, state}
  end

  def handle_cast(:check_after_power_off, state) do
    state
    |> Enum.map( 
      fn {key, date_of_death} ->
        if date_of_death - DateTime.utc_now <= 0 do
            GenServer.cast(self(), {:delete, key})
          else
            Process.send_after(self(), {:delete, key}, date_of_death - DateTime.utc_now)
        end
      end)
    {:noreply, state}
  end

  def handle_cast({:delete, key}, state) do 
    key |> delete
    # if in state exist key, then delete this too
    new_state = key |> key_exist?(state) 
    {:noreply, new_state}
  end

  def handle_info({:delete, key}, _state) do
    GenServer.cast(self(), {:delete, key})
  end

  def handle_cast({:set_timer, key, ttl}, _state) do
    Process.send_after(self(), {:delete, key}, ttl)
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


