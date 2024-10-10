defmodule TrainServer do
  @moduledoc """
  Train FSM on GenServer
  """

  use GenServer

  @spec start_link(nonempty_list(String.t())) :: {:ok, pid()} | {:error, String.t()}
  def start_link(route), do: GenServer.start(__MODULE__, route)

  @spec open_doors(pid()) :: {:ok, Train.t()} | {:error, String.t()}
  def open_doors(pid), do: GenServer.call(pid, :open_doors)

  @spec close_doors(pid()) :: {:ok, Train.t()}
  def close_doors(pid), do: GenServer.call(pid, :close_doors)

  @spec move_to_next_station(pid()) :: {:ok, Train.t()} | {:error, String.t()}
  def move_to_next_station(pid), do: GenServer.call(pid, :move_to_next_station)

  @spec stop_at_station(pid()) :: {:ok, Train.t()}
  def stop_at_station(pid), do: GenServer.call(pid, :stop_at_station)

  @impl true
  def init(route) do
    with %Train{} = train <- Train.init(route) do
      {:ok, train}
    else
      {:error, msg} -> {:stop, msg}
    end
  end

  @impl true
  def handle_call(msg, _from, train)
      when msg in [:stop_at_station, :move_to_next_station, :close_doors, :open_doors] do
    with %Train{} = new_train <- apply(Train, msg, [train]) do
      {:reply, {:ok, new_train}, new_train}
    else
      {:error, msg} -> {:reply, {:error, msg}, train}
    end
  end
end
