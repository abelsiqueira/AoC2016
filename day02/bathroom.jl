using Base.Test

const keymap = Dict("U"=>[0;-1], "D"=>[0;1], "L"=>[-1;0], "R"=>[1;0])

ξ(x, l, u) = max(min(x, u), l)

function find_key(instructions; x = 2, y = 2)
  instructions = [keymap[x] for x in split(instructions, "")]
  N = length(instructions)
  m, n = 3, 3
  for i = 1:N
    d = instructions[i]
    x = ξ(x+d[1], 1, m)
    y = ξ(y+d[2], 1, n)
  end
  return x + 3*(y - 1), x, y
end

function find_key_evil(instructions; x = 1, y = 3)
  instructions = [keymap[x] for x in split(instructions, "")]
  N = length(instructions)
  M = fill("0", 5, 5)
  M[1,3], M[2,2:4], M[3,:], M[4,2:4], M[5,3] = "1", ["2","3","4"], ["5","6","7","8","9"], ["A","B","C"], "D"
  m, n = 5, 5
  for i = 1:N
    d = instructions[i]
    xp = ξ(x+d[1], 1, m)
    yp = ξ(y+d[2], 1, n)
    (x,y) = M[yp,xp] == "0" ? (x,y) : (xp,yp)
  end
  return M[y,x], x, y
end

function find_pass(lines; x = 2, y = 2, evil = false)
  map!(chomp, lines)
  fk = evil ? find_key_evil : find_key
  N = length(lines)
  pass = evil ? fill("0", N) : zeros(Int, N)
  for i = 1:N
    pass[i], x, y = fk(lines[i], x=x, y=y)
  end
  return join(pass)
end

function test()
  @test find_key("ULL") == (1, 1, 1)
  @test find_key("RRDDD", x = 1, y = 1) == (9, 3, 3)
  @test find_pass(["ULL", "RRDDD", "LURDL", "UUUUD"]) == "1985"

  @test find_key_evil("ULL") == ("5", 1, 3)
  @test find_key_evil("RRDDD") == ("D", 3, 5)
  @test find_pass(["ULL", "RRDDD", "LURDL", "UUUUD"], x = 1, y = 3, evil=true) == "5DB3"
end

function run_input()
  pass = find_pass(readlines("input"))
  println("Pass = $pass")
  pass = find_pass(readlines("input"), evil=true)
  println("Evil Pass = $pass")
end

test()

run_input()
