using Base.Test

function unscramble(code, lines)
  code = split(code, "")
  n = length(lines)
  for i = n:-1:1
    line = lines[i]
    if contains(line, "swap position")
      m = match(r" ([0-9]+) with position ([0-9]+)", line)
      x, y = parse(m[1])+1, parse(m[2])+1
      code[x], code[y] = code[y], code[x]
    elseif contains(line, "swap letter")
      m = match(r"letter (.) with letter (.)", line)
      x = findfirst(code .== m[1])
      y = findfirst(code .== m[2])
      code[x], code[y] = code[y], code[x]
    elseif contains(line, "rotate right")
      m = match(r"right ([0-9]+) step", line)
      x = parse(m[1])
      x > length(code) && ( x = (x - 1) % length(code) + 1 )
      code = [code[1+x:end]; code[1:x]]
    elseif contains(line, "rotate left")
      m = match(r"left ([0-9]+) step", line)
      x = parse(m[1])
      x > length(code) && ( x = (x - 1) % length(code) + 1 )
      code = [code[end-x+1:end]; code[1:end-x]]
    elseif contains(line, "rotate based")
      m = match(r"letter (.)", line)
      y = findfirst(code .== m[1])
      x = y % 2 == 0 ? div(y, 2) : (y == 1 ? 1 : div(y,2) + 5)
      code = [code[1+x:end]; code[1:x]]
    elseif contains(line, "reverse")
      m = match(r"positions ([0-9]+) through ([0-9]+)", line)
      x, y = parse(m[1])+1, parse(m[2])+1
      reverse!(code, x, y)
    elseif contains(line, "move")
      m = match(r"position ([0-9]+) to position ([0-9]+)", line)
      y, x = parse(m[1])+1, parse(m[2])+1
      a = code[x]
      deleteat!(code, x)
      insert!(code, y, a)
    end
  end
  return join(code)
end

function scramble(code, lines)
  code = split(code, "")
  for line in lines
    if contains(line, "swap position")
      m = match(r" ([0-9]+) with position ([0-9]+)", line)
      x, y = parse(m[1])+1, parse(m[2])+1
      code[x], code[y] = code[y], code[x]
    elseif contains(line, "swap letter")
      m = match(r"letter (.) with letter (.)", line)
      x = findfirst(code .== m[1])
      y = findfirst(code .== m[2])
      code[x], code[y] = code[y], code[x]
    elseif contains(line, "rotate right")
      m = match(r"right ([0-9]+) step", line)
      x = parse(m[1])
      x > length(code) && ( x = (x - 1) % length(code) + 1 )
      code = [code[end-x+1:end]; code[1:end-x]]
    elseif contains(line, "rotate left")
      m = match(r"left ([0-9]+) step", line)
      x = parse(m[1])
      x > length(code) && ( x = (x - 1) % length(code) + 1 )
      code = [code[1+x:end]; code[1:x]]
    elseif contains(line, "rotate based")
      m = match(r"letter (.)", line)
      x = findfirst(code .== m[1])
      x += (x >= 5)
      x > length(code) && ( x = (x - 1) % length(code) + 1 )
      code = [code[end-x+1:end]; code[1:end-x]]
    elseif contains(line, "reverse")
      m = match(r"positions ([0-9]+) through ([0-9]+)", line)
      x, y = parse(m[1])+1, parse(m[2])+1
      reverse!(code, x, y)
    elseif contains(line, "move")
      m = match(r"position ([0-9]+) to position ([0-9]+)", line)
      x, y = parse(m[1])+1, parse(m[2])+1
      a = code[x]
      deleteat!(code, x)
      insert!(code, y, a)
    end
  end
  return join(code)
end

function test()
  lines = readlines(open("test"))
  @test scramble("abcde", lines) == "decab"
  push!(lines, "rotate right 1 step\n")
  @test scramble("abcde", lines) == "bdeca"
  @test scramble(unscramble("abcdefgh", lines), lines) == "abcdefgh"
end

function runinput()
  lines = readlines(open("input"))
  println(scramble("abcdefgh", lines))
  code = unscramble("fbgdceah", lines)
  println("uns = $code")
end

test()
runinput()
