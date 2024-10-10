defmodule TrainServerTest do
  use ExUnit.Case, async: true

  alias TrainServer

  test "stop and open doors at last station" do
    {:ok, pid} = TrainServer.start_link(["Station1", "Station2", "Station3"])
    TrainServer.close_doors(pid)
    TrainServer.move_to_next_station(pid)
    TrainServer.move_to_next_station(pid)
    TrainServer.stop_at_station(pid)
    {:ok, train} = TrainServer.open_doors(pid)

    assert train == %Train{
             action: :stopping,
             doors: :opened,
             route: ["Station3"],
             current_station: "Station3",
             next_station: nil
           }
  end

  test "start server with short route" do
    assert {:error, "Route must contain at least two stations"} ==
             TrainServer.start_link(["Station1"])
  end

  test "start server with empty route" do
    assert {:error, "Route must contain at least two stations"} ==
             TrainServer.start_link([])
  end

  test "start server with invalid route" do
    assert {:error, "Invalid Route"} == TrainServer.start_link(:foo)
  end

  test "open doors while moving" do
    {:ok, pid} = TrainServer.start_link(["Station1", "Station2", "Station3"])
    TrainServer.close_doors(pid)
    TrainServer.move_to_next_station(pid)
    assert {:error, "Invalid action state"} == TrainServer.open_doors(pid)
  end

  test "open doors while doos are opened" do
    {:ok, pid} = TrainServer.start_link(["Station1", "Station2", "Station3"])
    TrainServer.close_doors(pid)
    TrainServer.move_to_next_station(pid)
    TrainServer.stop_at_station(pid)
    {:ok, train} = TrainServer.open_doors(pid)
    assert {:ok, ^train} = TrainServer.open_doors(pid)
  end

  test "close doors while moving" do
    {:ok, pid} = TrainServer.start_link(["Station1", "Station2", "Station3"])
    TrainServer.close_doors(pid)
    {:ok, train} = TrainServer.move_to_next_station(pid)
    assert {:ok, ^train} = TrainServer.close_doors(pid)
  end

  test "move to next station with opened doors" do
    {:ok, pid} = TrainServer.start_link(["Station1", "Station2", "Station3"])
    assert {:error, "Invalid route or doors status"} == TrainServer.move_to_next_station(pid)
  end

  test "move to next station from last station" do
    {:ok, pid} = TrainServer.start_link(["Station1", "Station2"])
    TrainServer.close_doors(pid)
    TrainServer.move_to_next_station(pid)
    assert {:error, "Invalid route or doors status"} == TrainServer.move_to_next_station(pid)
  end

  test "stop at station while train action is stopping" do
    {:ok, pid} = TrainServer.start_link(["Station1", "Station2"])
    TrainServer.close_doors(pid)
    TrainServer.move_to_next_station(pid)
    {:ok, train} = TrainServer.stop_at_station(pid)
    assert {:ok, ^train} = TrainServer.stop_at_station(pid)
  end
end
