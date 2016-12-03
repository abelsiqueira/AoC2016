# path = "R2, L3"
function walk(path)
  path = split(path, ", ")
  pos = [0; 0]
  d = [0; 1]
  R(d) = [d[2]; -d[1]]
  L(d) = -R(d)
  for instruction in path
    d = instruction[1] == 'L' ? L(d) : R(d)
    mov = parse(Int, instruction[2:end])
    pos += d * mov
  end
  return sum(abs.(pos)) # norm(v, 1) returns float, and it bothers me
end

function find_first_repeat(path)
  path = split(path, ", ")
  pos = [0; 0]
  road = Any[pos]
  roadf = [1]
  d = [0; 1]
  R(d) = [d[2]; -d[1]]
  L(d) = -R(d)
  for instruction in path
    d = instruction[1] == 'L' ? L(d) : R(d)
    mov = parse(Int, instruction[2:end])
    for i = 1:mov
      pos += d
      j = indexin(Any[pos], road)[1] # There should be a better way
      if j == 0
        push!(road, pos)
        push!(roadf, 1)
      else
        roadf[j] += 1
      end
    end
  end
  j = findfirst(roadf .> 1)
  return sum(abs.(road[j])) # norm(v, 1) returns float, and it bothers me
end

function test()
  @assert walk("R2, L3") == 5
  @assert walk("R2, R2, R2") == 2
  @assert walk("R5, L5, R5, R3") == 12
  @assert find_first_repeat("R8, R4, R4, R8") == 4
end

function runinput()
  w = walk(readchomp(open("input")))
  println("walk = $w")
  f = find_first_repeat(readchomp(open("input")))
  println("find = $f")
end

test()

runinput()
