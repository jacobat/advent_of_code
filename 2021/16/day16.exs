defmodule Day16 do
  def input do
    File.read!("input")
    |> String.trim
  end

  def parse_literal(<<0::1, bits::4, rest::bits>>, data) do
    {data * 16 + bits, rest}
  end

  def parse_literal(<<1::1, bits::4, rest::bits>>, data) do
    parse_literal(rest, data * 16 + bits)
  end

  def parse_n_packets(0, rest, acc), do: { acc |> Enum.reverse, rest }

  def parse_n_packets(count, rest, acc) do
    { packet, left } = parse_packet(rest)
    parse_n_packets(count - 1, left, [packet | acc])
  end

  def parse_packet(<<version::3, 4::3, rest::bits>>) do
    {data, left} = parse_literal(rest, 0)
    {%{version: version, type: 4, data: data}, left}
  end

  def parse_packet(<<version::3, type::3, 0::1, length::15, rest::bits>>) do
    <<sub_packet::bits-size(length),left::bits>> = rest
    {%{version: version, type: type, data: parse_packets(sub_packet)}, left}
  end

  def parse_packet(<<version::3, type::3, 1::1, subpack_count::11, rest::bits>>) do
    { data, left } = parse_n_packets(subpack_count, rest, [])
    {%{version: version, type: type, data: data }, left}
  end

  def parse_packet(_), do: nil

  def parse_packets(bits, packets) do
    case parse_packet(bits) do
      { packet, left } -> parse_packets(left, packets ++ [packet])
      nil -> packets
    end
  end

  def parse_packets(packet), do: parse_packets(packet, [])

  def hex_to_binary(hex) do
    size = String.length(hex) * 4
    hex
    |> String.to_integer(16)
    |> then(&<<&1::big-integer-size(size)>>)
  end

  def display_hex(hex) do
    hex
    |> String.to_integer(16)
    |> Integer.to_string(2)
    |> IO.inspect(label: "Binary")
    hex
  end

  def version_sum(packets) when is_list(packets) do
    Enum.reduce(packets, 0, fn %{version: version, data: data}, acc ->
      acc + version_sum(data) + version
    end)
  end

  def version_sum(_), do: 0

  def compare(data, operator) do
    [a, b] = Enum.map(data, &evaluate/1)
    if operator.(a, b) do 1 else 0 end
  end

  def reduce(data, func), do: Enum.map(data, &evaluate/1) |> func.()

  def evaluate(%{type: 0, data: data}), do: reduce(data, &Enum.sum/1)
  def evaluate(%{type: 1, data: data}), do: reduce(data, &Enum.product/1)
  def evaluate(%{type: 2, data: data}), do: reduce(data, &Enum.min/1)
  def evaluate(%{type: 3, data: data}), do: reduce(data, &Enum.max/1)
  def evaluate(%{type: 4, data: data}), do: data
  def evaluate(%{type: 5, data: data}), do: compare(data, &Kernel.>/2)
  def evaluate(%{type: 6, data: data}), do: compare(data, &Kernel.</2)
  def evaluate(%{type: 7, data: data}), do: compare(data, &Kernel.==/2)

  def first(input) do
    input
    |> hex_to_binary
    |> parse_packets
    |> version_sum
  end

  def second(input) do
    input
    |> hex_to_binary
    |> parse_packets
    |> List.first
    |> evaluate
  end

  def run do
    with input <- input()
    do
      first(input)
      |> IO.inspect(charlists: :as_lists, limit: :infinity, label: "First")
      second(input)
      |> IO.inspect(charlists: :as_lists, limit: :infinity, label: "Second")
    end
  end
end
IO.puts("")
IO.puts("***************************")
IO.puts("******** New run **********")
IO.puts("***************************")
IO.puts("")

:timer.tc(Day16, :run, [])
|> elem(0)
|> div(1000)
|> then(&IO.puts("Runtime: #{&1}ms"))
