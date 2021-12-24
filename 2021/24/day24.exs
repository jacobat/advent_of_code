defmodule Day24 do
  def input do
    File.read!("input")
  end

  def compile_line("asi " <> things) do
    [register, number] = String.split(things)
    "#{register} = #{number}\n"
  end

  def compile_line("brk " <> things) do
    [register, number] = String.split(things)
    """
    #{register} = if #{number} != 1, do: false, else: #{register}
    """
  end

  def compile_line("add " <> things) do
    [register, number] = String.split(things)
    "#{register} = Kernel.+(#{register}, #{number})\n"
  end

  def compile_line("mul " <> things) do
    [register, number] = String.split(things)
    "#{register} = Kernel.*(#{register}, #{number})\n"
  end

  def compile_line("div " <> things) do
    [register, number] = String.split(things)
    "#{register} = Kernel.div(#{register}, #{number})\n"
  end

  def compile_line("mod " <> things) do
    [register, number] = String.split(things)
    "#{register} = Integer.mod(#{register}, #{number})\n"
  end

  def compile_line("eql " <> things) do
    [register, number] = String.split(things)
    "#{register} = if #{register} == #{number}, do: 1, else: 0\n"
  end

  def compile_line(_) do
    raise "What?"
  end

  def wrap_in_module(string) do
    """
    defmodule ALU do
    #{string}
    end
    """
  end

  def wrap_in_fun(string, index) do
    """
    def sub(#{index}, z, input) do
      #{string}
      z
    end
    """
  end

  def optimize_assigns(program) do
    Enum.reduce(program, {[], nil}, fn stmt, {output, carry} ->
      if carry == nil do
        m = Regex.run(~r/mul (.*) 0/, stmt)
        if m do
          {output, Enum.at(m, 1)}
        else
          {[stmt | output], nil}
        end
      else
        [^carry, c] = Regex.run(~r/add (.*) (.*)/, stmt, capture: :all_but_first)
        {["asi #{carry} #{c}" | output], nil}
      end
    end)
    |> elem(0)
    |> Enum.reverse
  end

  def optimize_input(program) do
    program
    |> Enum.reject(&(&1 == "inp w"))
    |> Enum.map(fn stmt ->
      case stmt do
        "eql x w" -> "eql x input"
        "asi y w" -> "asi y input"
        _ -> stmt
      end
    end)
  end

  def optimize_case1(program) do
    if Enum.at(program, 2) == "div z 1" do
      adder = Enum.at(program, 11)
      [_, _, y] = String.split(adder)
      ["mul z 26", "add z input", "add z #{y}"]
    else
      program
    end
  end

  def optimize_case2(program) do
    if Enum.at(program, 2) == "div z 26" do
      Enum.slice(program, 0, 5) ++ ["brk z x"]
    else
      program
    end
  end

  def optimize(program) do
    program
    |> optimize_assigns
    |> optimize_input
    |> optimize_case1
    |> optimize_case2
  end

  def compile_program({program, index}) do
    program
    |> optimize
    |> Enum.map(&compile_line/1)
    |> Enum.join
    |> wrap_in_fun(index)
  end

  def compile(string) do
    string
    |> String.split("\n", trim: true)
    |> Enum.chunk_every(18)
    |> Enum.with_index
    |> Enum.map(&compile_program/1)
    |> Enum.join
    |> wrap_in_module
    # |> then(fn s -> IO.puts(s); s end)
    |> Code.eval_string
    nil
  end

  def find_valid_monad(false, _, _, _), do: false

  def find_valid_monad(z, _, 14, acc) do
    if z == 0 do
      acc |> Enum.reverse
    else
      false
    end
  end

  def find_valid_monad(z, range, pos, acc) do
    Enum.find_value(range, fn n ->
      ALU.sub(pos, z, n)
      |> find_valid_monad(range, pos + 1, [n | acc])
    end)
  end

  def first() do
    find_valid_monad(0, 9..1, 0, [])
    |> Enum.join
  end

  def second() do
    find_valid_monad(0, 1..9, 0, [])
    |> Enum.join
  end

  def run do
    input() |> compile
    first()
    |> IO.inspect(charlists: :as_lists, limit: :infinity, label: "First")
    second()
    |> IO.inspect(charlists: :as_lists, limit: :infinity, label: "Second")
  end
end

IO.puts("")
IO.puts("***************************")
IO.puts("******** New run **********")
IO.puts("***************************")
IO.puts("")


:timer.tc(Day24, :run, [])
|> elem(0)
|> div(1000)
|> then(&IO.puts("Runtime: #{&1}ms"))
