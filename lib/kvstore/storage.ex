#TODO: Этот модуль должен реализовать механизмы CRUD для хранения данных. Если одного модуля будет мало, то допускается создание модулей с префиксом "Storage" в названии
defmodule Kvstore.Storage do
  alias Kvstore.Utils
  use GenServer
  require Logger

  @default_ttl Application.get_env(:kvstore, :default_ttl)
  
  # Так как нам необходимо предусмотреть возможность
  # отключения программы с сохранением предустановленного
  # времени жизни, то привязка ttl идет не относительному 
  # "через сколько необходимо записи удалиться", а к 
  # абсолютному времени

  def run_db() do
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
      # ttl передается в секунд, его необходимо переделать в "дату смерти"
    date_of_death = Utils.parse(:ttl, now, ttl)
      # сохраняем в dets, чтобы между сеансами ничего не потерялось
    :dets.insert_new(:ttl, {key, date_of_death})
      # send to killing ttl in milliseconds, becouse we hope, that 
      # shit will selfkill in our session
    GenServer.cast(__MODULE__, {:set_timer, key, ttl})
    {:ok}
  end

  def get(key) do
    :dets.match_object(:storage, {key, :"_", :"_"})
    |> Enum.map(&(get(:ttl, &1)))
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
  
  def init([]) do
    :dets.open_file(:storage, [type: :set])
    :dets.open_file(:ttl, [type: :set])
    {:ok, []}
  end

  def handle_cast(:check_after_power_off, []), do: {:noreply, []}

  def handle_cast(:check_after_power_off, state) do
    :dets.match_object(:ttl, :"_") |> Enum.each(&(check(:state, &1)))
    {:noreply, state}
  end

  def handle_cast({:delete, key}, state) do 
    delete(key)
    {:noreply, state}
  end

  def handle_cast({:set_timer, key, ttl}, state) do
    new_state = key |> key_exist?(state) 
    ref = Process.send_after(self(), {:delete, key}, ttl*1000)
    {:noreply, new_state ++ [{key, ref}]}
  end

  def handle_info({:delete, key}, state) do
    GenServer.cast(self(), {:delete, key})
    {:noreply, state}
  end


  def check(:state, {key, date_of_death}) do
    ttl = DateTime.to_unix(date_of_death) - DateTime.to_unix(DateTime.utc_now)
    if ttl<0 do
      GenServer.cast(self(), {:delete, key})
      else
        GenServer.cast(self(), {:set_timer, key, ttl})
    end
  end

  def key_exist?(key, state) do
    state
    |> Enum.filter( fn {k, _} -> k == key end)
    |> key_exist_in(state)
  end

  defp key_exist_in([{_, ref}] = row, state) do
    Process.cancel_timer(ref)
    state -- row
  end

  defp key_exist_in(_, state), do: state

end


