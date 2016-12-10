using Base.Test

function decompress(code)
  out = ""
  while length(code) > 0
    m = match(r"(\([0-9]+x[0-9]+\))", code)
    if m == nothing
      out *= code
      break
    end
    if m.offset > 1
      out *= code[1:m.offset-1]
      code = code[m.offset:end]
    end
    mark = m[1]
    code = code[length(mark)+1:end]

    le, re = map(parse, split(mark[2:end-1], "x"))
    re_str = code[1:le]
    code = code[le+1:end]
    out *= repeat(re_str, re)
  end
  return out
end

function self_contained(str)
  m = matchall(r"(\([0-9]+x[0-9]+\))", str)
  length(m) == 0 && return true
  a, b = map(parse, split(m[1][2:end-1], "x"))
  if a > length(str) - length(m[1])
    return false
  end

  return self_contained(str[length(m[1])+1:end])
end

function dec2len(code)
  s = 0
  while length(code) > 0
    m = match(r"(\([0-9]+x[0-9]+\))", code)
    if m == nothing
      return s + length(code)
    end
    if m.offset > 1
      s += m.offset - 1
      code = code[m.offset:end]
    end
    mark = m[1]
    code = code[length(mark)+1:end]

    le, re = map(parse, split(mark[2:end-1], "x"))
    re_str = code[1:le]
    code = code[le+1:end]

    # (lexre)re_str...
    if self_contained(re_str)
      s += dec2len(re_str) * re
    else
      code = repeat(re_str, re) * code
    end
  end
  return s
end

function test()
  @test decompress("ADVENT") == "ADVENT"
  @test decompress("A(1x5)BC") == "ABBBBBC"
  @test decompress("(3x3)XYZ") == "XYZXYZXYZ"
  @test decompress("A(2x2)BCD(2x2)EFG") == "ABCBCDEFEFG"
  @test decompress("(6x1)(1x3)A") == "(1x3)A"
  @test decompress("X(8x2)(3x3)ABCY") == "X(3x3)ABC(3x3)ABCY"

  @test dec2len("ADVENT") == 6
  @test dec2len("A(1x5)BC") == 7
  @test dec2len("(3x3)XYZ") == 9
  @test dec2len("X(8x2)(3x3)ABCY") == 20
  @test dec2len("(27x12)(20x12)(13x14)(7x10)(1x12)A") == 241920
  @test dec2len("(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN") == 445
end

function runinput()
  lines = readlines(open("input"))
  s = 0
  for line in lines
    out = decompress(chomp(line))
    s += length(out)
  end
  println("s = $s")

  s = 0
  for line in lines
    s += dec2len(chomp(line))
  end
  println("s = $s")
end

test()
runinput()
