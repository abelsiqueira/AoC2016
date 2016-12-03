function valid_triangle(a, b, c)
  a,b,c = sort([a,b,c])
  return a + b > c
end

function run_input()
  lines = readlines("input")
  n = 0
  for line in lines
    a, b, c = map(parse, split(line))
    valid_triangle(a, b, c) && (n += 1)
  end
  println("$n are valid")

  N = length(lines)
  full = split(join(map(chomp, lines)))
  full = [full[1:3:end]; full[2:3:end]; full[3:3:end]]
  n = 0
  for i = 1:N
    a, b, c = map(parse, full[3(i-1) + [1;2;3]])
    valid_triangle(a, b, c) && (n += 1)
  end
  println("$n are valid")
end

run_input()
