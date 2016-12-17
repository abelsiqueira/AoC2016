using Base.Test

const mapreg = Dict("a"=>1, "b"=>2, "c"=>3, "d"=>4)

function run(lines, reg = zeros(Int, 4))
  n = length(lines)
  i = 1
  while i <= n
    inst = chomp(lines[i])
    s = split(inst)
    cmd, x, y = length(s) == 2 ? (s[1], s[2], 0) : s
    if cmd == "cpy"
      reg[mapreg[y]] = x in keys(mapreg) ? reg[mapreg[x]] : parse(x)
    elseif cmd == "inc"
      reg[mapreg[x]] += 1
    elseif cmd == "dec"
      reg[mapreg[x]] -= 1
    elseif cmd == "jnz"
      if (x in keys(mapreg) && reg[mapreg[x]] != 0) || ( !(x in keys(mapreg) && parse(x) != 0) )
        i += parse(y)
        continue
      end
    end
    i += 1
  end
  println(reg)
end

function test()
  lines = readlines(open("test"))
  run(lines)
end

function runinput()
  #lines = readlines(open("input"))
  #run(lines)
  lines = readlines(open("input"))
  run(lines, [0;0;1;0])
end

test()
runinput()
