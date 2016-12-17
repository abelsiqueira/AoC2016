using Base.Test

function printstatus(components, generators, chips, elev)
  L = map(w->uppercase(w)[1:1], components)
  for floor = 4:-1:1
    print("F$floor ")
    print(elev == floor ? "E" : ".")
    for c = 1:length(components)
      print(generators[c] == floor ? " " * L[c] * "G" : " . ")
      print(chips[c] == floor ? " " * L[c] * "M" : " . ")
    end
    println("")
  end
end

function get_component(lines)
  c = []
  for line in lines
    m = matchall(r"(\w+) generator", line)
    append!(c, map(x->split(x)[1], m))
  end
  # Verifying
  nc = 0
  for line in lines
    m = matchall(r"(\w+)-compatible", line)
    nc += length(m)
    for x in m
      @assert split(x, "-")[1] in c
    end
  end
  @assert nc == length(c)
  return c
end

function rtg(lines)
  components = get_component(lines)
  n = length(components)
  generators = zeros(Int, n)
  chips = zeros(Int, n)
  for (floor,line) in enumerate(lines)
    for (c,comp) in enumerate(components)
      if contains(line, "$comp generator")
        generators[c] = floor
      end
      if contains(line, "$comp-compatible")
        chips[c] = floor
      end
    end
  end
  printstatus(components, generators, chips, 1)

  # At this point I realized the math
  count = 0
  for floor = 1:3
    l = sum(generators .<= floor) + sum(chips .<= floor)
    count += max(1, 2l - 3)
  end
  return count
end

function test()
  lines = readlines(open("test"))
  @test rtg(lines) == 9
end

function runinput()
  lines = readlines(open("input"))
  c = rtg(lines)
  println("c = $c")
  lines[1] = chomp(lines[1]) * "Wait, there is more: an elerium generator, an elerium-compatible microchip, a dilithium generator, and a dilithium-compatible microchip.\n"
  c = rtg(lines)
  println("c = $c")
end

test()
runinput()
