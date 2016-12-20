using Base.Test

function firewall(lines)
  blocked = []
  for line in lines
    a,b = map(parse, split(chomp(line), "-"))
    push!(blocked, a:b)
  end
  sort!(blocked, lt=(a,b)->a[1] < b[1])
  nb = length(blocked)
  i = 1
  while i < nb
    if blocked[i][end] >= blocked[i+1][1]-1
      newb = blocked[i][1]:max(blocked[i][end],blocked[i+1][end])
      deleteat!(blocked, [i,i+1])
      insert!(blocked, i, newb)
      i -= 1
      nb -= 1
    end
    i += 1
  end

  s = 2^32 - sum(map(length, blocked))
  if blocked[1][1] > 0
    return 0, s
  else
    return blocked[1][end]+1, s
  end

end

function test()
  lines = readlines(open("test"))
  @test firewall(lines)[1] == 3
  @test firewall(["0-100", "99-2000"])[1] == 2001
  @test firewall(["0-1000000000", "99-2000"])[1] == 1_000_000_001
end

function runinput()
  lines = readlines(open("input"))
  ip, n = firewall(lines)
  println("ip = $ip, n = $n")
end

test()
runinput()
