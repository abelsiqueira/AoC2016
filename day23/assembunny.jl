using Base.Test

const mapreg = Dict("a"=>1, "b"=>2, "c"=>3, "d"=>4)

# Do lines lps to lpe represent a (simple) loop?
function try_loop(reg, lines, lps, lpe)
  # First, a simple
  loop_arg = split(chomp(lines[lpe]))[2]
  for i = lps:lpe-1
    if contains(lines[i], "tgl")
      return false
    end
  end
  reg_change = assembunny(copy(lines[lps:lpe-1]), copy(reg))
  reg_change = reg_change - reg
  if reg_change[mapreg[loop_arg]] * reg[mapreg[loop_arg]] >= 0
    error("Assumption error")
  end
  N = reg[mapreg[loop_arg]]
  for i = 1:4
    reg[i] += N * reg_change[i]
  end

  return true
end

function assembunny(lines, reg = zeros(Int, 4))
  n = length(lines)
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
      if (x in keys(mapreg) && reg[mapreg[x]] != 0) || ( !(x in keys(mapreg) && parse(x) != 0) )
        if y in keys(mapreg)
          j = reg[mapreg[y]]
        else
          j = parse(y)
        end
        if j < 0
          worked = try_loop(reg, lines, i+j, i)
          if !worked
            i += j
            continue
          end
        else
          i += j
          continue
        end
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
    end
    i += 1
  end
  return reg
end

function test()
  lines = readlines(open("test"))
  assembunny(lines)
end

function runinput()
  lines = readlines(open("input"))
  for eggs = 6:12
    reg = assembunny(copy(lines), [eggs;0;0;0])
    println(reg)
  end
end

test()
runinput()
