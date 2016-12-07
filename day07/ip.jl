using Base.Test

function separate(ip)
  lines = split(ip, "[")
  good = [lines[1]]
  bad = []
  for line in lines[2:end]
    a, b = split(line, "]")
    push!(bad, a)
    push!(good, b)
  end
  return good, bad
end

function has_abba(str)
  return ismatch(r"(.)((?!\1).)\2\1", str)
end

function tls(ip)
  good, bad = separate(ip)
  for g in good
    if has_abba(g)
      for b in bad
        if has_abba(b)
          return false
        end
      end
      return true
    end
  end
  return false
end

function ssl(ip)
  good, bad = separate(ip)
  for g in good
    matches = matchall(r"(.)((?!\1).)\1", g, true) # overlap=true
    for m in matches
      k = "$(m[2])$(m[1])$(m[2])"
      for b in bad
        if contains(b, k)
          return true
        end
      end
    end
  end
  return false
end

function test()
  @test tls("abba[mnop]qrst") == true
  @test tls("abcd[bddb]xyyx") == false
  @test tls("aaaa[qwer]tyui") == false
  @test tls("ioxxoj[asdfgh]zxcvbn") == true
end

function runinput()
  lines = readlines(open("input"))
  n = 0
  for line in lines
    if tls(chomp(line))
      n += 1
    end
  end
  println("n = $n")
  n = 0
  for line in lines
    if ssl(chomp(line))
      n += 1
    end
  end
  println("n = $n")
end

test()
runinput()
