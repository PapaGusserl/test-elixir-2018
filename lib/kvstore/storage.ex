#TODO: Этот модуль должен реализовать механизмы CRUD для хранения данных. Если одного модуля будет мало, то допускается создание модулей с префиксом "Storage" в названии
defmodule Kvstore.Storage do
  alias Kvstore.Utils
  use GenServer
  require Logger

  @default_ttl Application.get_env(:kvstore, :default_ttl)
  ## CRUD построена на :dets, т.к. в 
  ## данном случае не требуется более мощный функционал,
  ## который может предоставить mnesia или Postgres
  
 
  # Так как нам необходимо предусмотреть возможность
  # отключения программы с сохранением предустановленного
  # времени жизни, то привязка ttl идет не относительному 
  # "через сколько необходимо записи удалиться", а к 
  # абсолютному времени

  def start() do
    :dets.open_file(:ttl, [type: :set])
    :dets.open_file(:storage, [type: :set])
    GenServer.cast(__MODULE__, :check_after_power_off)
  end

  ### API

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def set(key, value, ttl \\ @default_ttl) do
    now = DateTime.utc_now()
    :dets.insert(:storage, {key, value, now})
    ttl = if is_binary(ttl), do: String.to_integer(ttl), else: ttl
    # если ttl передается в формате секунд, его необходимо переделать в "дату смерти"
    date_of_death = Utils.parse(:ttl, now, ttl)
      # сохраняем в dets, чтобы между сеансами ничего не потерялось
    :dets.insert_new(:ttl, {key, date_of_death})
      # в state  не отправляем, так как там у нас хранится только то, что
      # осталось с прошлой сессии 
      # and send to killing ttl in milliseconds, becouse we hope, that 
      # shit will selfkill in our session
      # never forget, that ttl was in seconds
      GenServer.cast(__MODULE__, {:set_timer, key_field, ttl*1000})
      {:ok}
 end

  def get(key) do
    result = :dets.match_object(:storage, key)
             |> Enum.map(&(get(:ttl, &1))
 end

  def get(:ttl, {key, _, _} = tuple) do
        [{_, date_of_death}] = :dets.match_object(:ttl, {key, :"_"})
        "object: #{inspect tuple}\n date_of_death: #{inspect date_of_death}"
  end

  def delete(key) do
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

  def handle_cast(:check_after_power_off, state) do
    state
    |>Enum.map( 
                  end)
    {:noreply, state}
  end

  def check(:state, {key, date_of_death}) do
    ttl = DateTime.to_unix(date_of_death) - DateTime.to_unix(DateTime.utc_now)
    if ttl<0 do
      GenServer.cast(self(), {:delete, key})
      else
        Process.send_after(self(), {:delete, key}, ttl*1000)
    end
  end

  def handle_cast({:delete, key}, state) do 
    delete(key)
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
    |> key_exist_in(state)
  end

  defp key_exist_in([{_, _}] = row, state), do: state -- row
  defp key_exist_in(_, state), do: state

end


