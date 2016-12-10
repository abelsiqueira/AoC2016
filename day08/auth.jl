using Base.Test

function parse_line(line)
  line = chomp(line)
  if contains(line, "rect")
    m = match(r"rect ([0-9]+)x([0-9]+)", line)
    return "rect", parse(m[1]), parse(m[2])
  elseif contains(line, "rotate row")
    m = match(r"rotate row y=([0-9]+) by ([0-9]+)", line)
    return "row", parse(m[1]), parse(m[2])
  else
    m = match(r"rotate column x=([0-9]+) by ([0-9]+)", line)
    return "col", parse(m[1]), parse(m[2])
  end
end

function img(M)
  C = map(x->x ? '#' : '.', M)
  out = ""
  for i = 1:size(C, 1)
    out *= join(C[i,:]) * "\n"
  end
  return out
end

function led(lines, rows = 6, cols = 50)
  M = fill(false, rows, cols)
  for line in lines
    #println(img(M))
    t, a, b = parse_line(line)
    if t == "rect"
      M[1:b, 1:a] = true
    elseif t == "row"
      M[a+1, [b+1:end;1:b]] = M[a+1,:]
    else
      M[[b+1:end;1:b], a+1] = M[:,a+1]
    end
  end
  return M
end

function test()
  lines = ["rect 3x2", "rotate column x=1 by 1", "rotate row y=0 by 4", "rotate column x=1 by 1"]
  @test img(led(lines, 3, 7)) == ".#..#.#\n#.#....\n.#.....\n"
end

function runinput()
  M = led(readlines(open("input")))
  println(img(M))
  s = sum(M)
  println("sum = $s")
end

test()
runinput()
