using Base.Test

function disc(lines)
  n = length(lines)
  M = zeros(Int, n)
  R = zeros(Int, n)
  for i = 1:n
    m = match(r"([0-9]+) positions.* position ([0-9]+).", lines[i])
    M[i] = parse(m[1])
    R[i] = parse(m[2]) + i
  end
  I = sortperm(M, rev=true)
  M = M[I]
  R = R[I]
  for i = 1:n
    R[i] = mod(M[i]-R[i], M[i])
  end

  t = R[1]
  while true
    found = true
    for i = 2:n
      if t % M[i] != R[i]
        found = false
        break
      end
    end
    if found
      return t
    end
    t += M[1]
  end
end

function test()
  lines = readlines(open("test"))
  @test disc(lines) == 5
  println("")
end

function runinput()
  lines = readlines(open("input"))
  t = disc(lines)
  println("t = $t")
  push!(lines, "11 positions position 0.")
  t = disc(lines)
  println("t = $t")
end

test()
runinput()
