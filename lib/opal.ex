defmodule Opal do
  use Agent

  def init() do
    Agent.start_link(fn -> %{kv: [%{}], count: [%{}]} end, name: :state)
  end

  def run do
    get_input()
    |> handle_command()

    run()
  end

  defp get_input() do
    IO.read(:stdio, :line)
    |> String.split()
  end

  defp handle_command([]) do
  end

  defp handle_command(["SET", key, value]) do
    set(key, value)
  end

  defp handle_command(["GET", key]) do
    case get(key) do
      nil ->
        IO.puts("=> key not set")

      result ->
        IO.puts("=> #{result}")
    end
  end

  defp handle_command(["DELETE", key]) do
    case get(key) do
      nil ->
        IO.puts("=> key not set")

      value ->
        delete(key, value)
    end
  end

  defp handle_command(["COUNT", value]) do
    case count(value) do
      nil ->
        IO.puts("=> value not seen")

      result ->
        IO.puts("=> #{result}")
    end
  end

  defp handle_command(["BEGIN"]) do
    Agent.update(:state, fn %{
                              kv: [kv | _kv_rest] = kv_all,
                              count: [count | _count_rest] = count_all
                            } ->
      %{kv: [kv | kv_all], count: [count | count_all]}
    end)
  end

  defp handle_command(["COMMIT"]) do
    case get_all() |> in_transaction?() do
      true ->
        Agent.update(:state, fn %{
                                  kv: [kv_0, kv_1 | kv_rest],
                                  count: [count_0, count_1 | count_rest]
                                } ->
          %{
            kv: [Map.merge(kv_1, kv_0) | kv_rest],
            count: [Map.merge(count_1, count_0) | count_rest]
          }
        end)

      false ->
        IO.puts("=> no transaction")
    end
  end

  defp handle_command(["ROLLBACK"]) do
    case get_all() |> in_transaction?() do
      true ->
        Agent.update(:state, fn %{
                                  kv: [_kv | kv_rest],
                                  count: [_count | count_rest]
                                } ->
          %{
            kv: kv_rest,
            count: count_rest
          }
        end)

      false ->
        IO.puts("=> no transaction")
    end
  end

  defp handle_command(["state"]) do
    IO.inspect(get_all())
  end

  defp handle_command(_) do
    IO.puts("=> invalid command")
  end

  defp in_transaction?(%{
         kv: [_kv_0, _kv_1 | _kv_rest],
         count: [_count_0, _count_1 | _count_rest]
       }) do
    true
  end

  defp in_transaction?(_) do
    false
  end

  defp set(key, value) do
    Agent.update(:state, fn %{kv: [kv | kv_rest], count: [count | count_rest]} ->
      count =
        case Map.get(kv, key) do
          nil ->
            count

          value ->
            dec_or_delete(count, value)
        end

      %{
        kv: [Map.put(kv, key, value) | kv_rest],
        count: [
          Map.update(count, value, 1, fn existing_value -> existing_value + 1 end) | count_rest
        ]
      }
    end)
  end

  defp get(key) do
    Agent.get(:state, fn %{kv: [kv | _kv_rest]} ->
      Map.get(kv, key)
    end)
  end

  defp get_all() do
    Agent.get(:state, fn state ->
      state
    end)
  end

  defp count(value) do
    Agent.get(:state, fn %{count: [count | _count_rest]} ->
      Map.get(count, value)
    end)
  end

  defp dec_or_delete(count, value) do
    case Map.get(count, value) do
      1 ->
        Map.delete(count, value)

      _ ->
        Map.update!(count, value, fn existing_value -> existing_value - 1 end)
    end
  end

  defp delete(key, value) do
    Agent.update(:state, fn %{kv: [kv | kv_rest], count: [count | count_rest]} ->
      count_result = dec_or_delete(count, value)

      %{
        kv: [Map.delete(kv, key) | kv_rest],
        count: [
          count_result | count_rest
        ]
      }
    end)
  end
end
