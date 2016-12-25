using Base.Test

const mapreg = Dict("a"=>1, "b"=>2, "c"=>3, "d"=>4)

function assembunny(lines, reg = zeros(Int, 4))
  n = length(lines)
  last_trans = 1
  max_trans = 100
  status = "End"
  i = 1
  while i <= n
    inst = chomp(lines[i])
    s = split(inst)
    cmd, x, y = length(s) == 2 ? (s[1], s[2], 0) : s
    if cmd == "cpy"
      if y in keys(mapreg)
        reg[mapreg[y]] = x in keys(mapreg) ? reg[mapreg[x]] : parse(x)
      end
    elseif cmd == "inc"
      if x in keys(mapreg)
        reg[mapreg[x]] += 1
      end
    elseif cmd == "dec"
      if x in keys(mapreg)
        reg[mapreg[x]] -= 1
      end
    elseif cmd == "jnz"
      if (x in keys(mapreg) && reg[mapreg[x]] != 0) ||
          ( !(x in keys(mapreg)) && parse(x) != 0 )
        if y in keys(mapreg)
          j = reg[mapreg[y]]
        else
          j = parse(y)
        end
        i += j
        continue
      end
    elseif cmd == "tgl"
      j = i + (x in keys(mapreg) ? reg[mapreg[x]] : parse(x))
      if 1 <= j <= n
        s = split(chomp(lines[j]))
        if length(s) == 2
          s[1] = s[1] == "inc" ? "dec" : "inc"
        else # |s| = 3
          s[1] = s[1] == "jnz" ? "cpy" : "jnz"
        end
        lines[j] = join(s, " ")
      end
    elseif cmd == "out"
      t = reg[mapreg[x]]
      if last_trans == t
        return false
      end
      last_trans = t
      max_trans -= 1
      if max_trans == 0
        return true
      end
    end
    i += 1
  end
  return false
end

function test()
end

function runinput()
  lines = readlines(open("input"))
  for i = 1:100000
    signal = assembunny(copy(lines), [i;0;0;0])
    if signal
      println("Found for $i")
      break
    else
      println("Not for $i")
    end
  end
end

#test()
runinput()
