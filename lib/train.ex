defmodule Train do
  defstruct action: nil, doors: :opened, route: nil, current_station: nil, next_station: nil

  @type t :: %Train{
          action: :moving | :stopping,
          doors: :opened | :closed,
          route: nonempty_list(String.t()),
          current_station: String.t(),
          next_station: String.t() | nil
        }

  @spec init(nonempty_list(String.t())) :: Train.t() | {:error, String.t()}
  def init([current_station, next_station | _] = route) do
    %Train{
      action: :stopping,
      doors: :opened,
      route: route,
      current_station: current_station,
      next_station: next_station
    }
  end

  def init(route) when is_list(route) and length(route) < 2,
    do: {:error, "Route must contain at least two stations"}

  def init(_), do: {:error, "Invalid Route"}

  @spec open_doors(Train.t()) :: Train.t() | {:error, String.t()}
  def open_doors(%Train{action: :stopping} = train), do: %Train{train | doors: :opened}
  def open_doors(_), do: {:error, "Invalid action state"}

  @spec close_doors(Train.t()) :: Train.t()
  def close_doors(%Train{} = train), do: %Train{train | doors: :closed}

  @spec stop_at_station(Train.t()) :: Train.t()
  def stop_at_station(%Train{} = train), do: %Train{train | action: :stopping}

  @spec move_to_next_station(Train.t()) :: Train.t() | {:error, String.t()}
  def move_to_next_station(
        %Train{
          doors: :closed,
          route: [_ | [new_current_station, new_next_station | _] = new_route]
        } = train
      ) do
    %Train{
      train
      | action: :moving,
        route: new_route,
        current_station: new_current_station,
        next_station: new_next_station
    }
  end

  def move_to_next_station(%Train{doors: :closed, route: [_, new_current_station]} = train) do
    %Train{
      train
      | action: :moving,
        route: [new_current_station],
        current_station: new_current_station,
        next_station: nil
    }
  end

  def move_to_next_station(_), do: {:error, "Invalid route or doors status"}
end
