using Base.Test

const value_line = r"value ([0-9]+) goes to bot ([0-9]+)"
const instr_line = r"bot ([0-9]+) gives low to (\w+) ([0-9]+) and high to (\w+) ([0-9]+)"

function printbots(bots)
  for (i,bot) in enumerate(bots)
    line = join(bot, " ")
    println(" Π⋅Π$i : $line")
  end
end

function printbins(bins)
  for (i,bin) in enumerate(bins)
    line = join(bin, " ")
    println(" ⋓$i : $line")
  end
end

function bots(lines, c1, c2)
  n_bots = 0
  n_bins = 0
  bots = [ [] for i = 1:1 ]
  rules = []
  comp_bot = 0
  c1, c2 = sort([c1, c2])

  for line in lines
    line = chomp(line)
    if contains(line, "value")
      m = match(value_line, line)
      value = parse(m[1])
      bot = parse(m[2]) + 1
      if n_bots < bot
        resize!(bots, bot)
        for i = n_bots+1:bot
          bots[i] = []
        end
        n_bots = bot
      end
      push!(bots[bot], value)
    else
      m = match(instr_line, line)
      push!(rules, (m[1], m[2], m[3], m[4], m[5]))
      if m[2] == "output"
        n_bins = max(n_bins, parse(m[3])+1)
      else
        bot = parse(m[3]) + 1
        if n_bots < bot
          resize!(bots, bot)
          for i = n_bots+1:bot
            bots[i] = []
          end
          n_bots = bot
        end
      end
      if m[4] == "output"
        n_bins = max(n_bins, parse(m[5])+1)
      else
        bot = parse(m[5]) + 1
        if n_bots < bot
          resize!(bots, bot)
          for i = n_bots+1:bot
            bots[i] = []
          end
          n_bots = bot
        end
      end
    end
  end

  bins = [ [] for i = 1:n_bins ]

  botrules = Array{Any}(n_bots)
  for rule in rules
    bot = parse(rule[1]) + 1
    n1 = parse(rule[3]) + 1
    n2 = parse(rule[5]) + 1
    v1 = rule[2] == "output" ? bins[n1] : bots[n1]
    v2 = rule[4] == "output" ? bins[n2] : bots[n2]
    botrules[bot] = (l,h) -> begin
      push!(v1, l)
      push!(v2, h)
    end
  end

  printbots(bots)
  printbins(bins)

  @assert all(map(length, bots) .<= 2)

  while any(map(length, bots) .> 0)
    i = findfirst(map(length, bots) .== 2)
    l, h = pop!(bots[i]), pop!(bots[i])
    l, h = sort([l,h])
    if l == c1 && h == c2
      comp_bot = i
    end
    botrules[i](l, h)
    printbots(bots)
    printbins(bins)
  end

  p = prod(bins[1]) * prod(bins[2]) * prod(bins[3])

  return comp_bot - 1, p
end

function test()
  lines = readlines(open("test"))
  @test bots(lines, 2, 5) == (2, 30)
end

function runinput()
  lines = readlines(open("input"))
  comp_bot, p = bots(lines, 61, 17)
  println("comp_bot = $comp_bot")
  println("p = $p")
end

test()
runinput()
