using Base.Test

function openspace(y, x, seed)
  z = x^2 + 3x + 2x*y + y + y^2 + seed
  z = sum(map(parse, split(bin(z),"")))
  return z % 2 == 0
end

function gen_maze(rows = 7, cols = 10, seed = 10)
  M = fill(false, rows, cols)
  for i = 1:rows
    for j = 1:cols
      M[i,j] = openspace(i-1, j-1, seed)
    end
  end
  return M
end

function printmaze(M, path=[])
  rows, cols = size(M)
  for i = 1:rows
    for j = 1:cols
      if (i,j) in path
        print("O")
      else
        print(M[i,j] ? '.' : '#')
      end
    end
    println("")
  end
  println("")
end

function printscore(S)
  rows, cols = size(S)
  for i = 1:rows
    for j = 1:cols
      if S[i,j] == Inf
        print("###")
      else
        @printf("%03d", Int(S[i,j]))
      end
    end
    println("")
  end
  println("")
end

function findpath(seed, x, y)
  gi, gj = y+1,x+1
  rows = gi + 2
  cols = gj + 2
  M = gen_maze(rows, cols, seed)
  S = Inf * ones(Int, rows, cols)

  done = []
  todo = [(2,2)]
  camefrom = Dict()
  S[2,2] = 0

  found_target = false
  L = [S[i,j] for (i,j) in todo]

  #println("todo = $todo")
  while !found_target || any(L .<= 50)
    ci,cj = shift!(todo)
    if (ci,cj) == (gi,gj)
      found_target = true
    end

    for (i,j) in [(ci+1,cj), (ci-1,cj), (ci,cj+1), (ci,cj-1)]
      if i < 1 || j < 1 || (i,j) in done
        continue
      end
      if i > rows || j > cols
        rn, cn = rows + 2, cols + 2
        M = gen_maze(rn, cn, seed)
        S2 = Inf * ones(rn, cn)
        for k = 1:rows
          for l = 1:cols
            S2[k,l] = S[k,l]
          end
        end
        rows, cols = rn, cn
        S = S2
      end
      if !M[i,j]
        continue
      end
      if !( (i,j) in todo )
        #println("Pushing $i,$j")
        push!(todo, (i,j))
      elseif S[i,j] <= S[ci,cj]
        continue
      end
      camefrom[(i,j)] = (ci,cj)
      S[i,j] = S[ci,cj] + 1
    end
    push!(done, (ci,cj))

    sort!(todo, by=a->S[a[1],a[2]])
    L = [S[i,j] for (i,j) in todo]
    #=
    println("$ci,$cj")
    for next in todo
      println("  $next, $(S[next[1],next[2]])")
    end
    =#
    #println("todo = $todo")
  end

  path = [(gi,gj)]
  (i,j) = (gi,gj)
  while (i,j) != (2,2)
    try
      i,j = camefrom[(i,j)]
    catch
      println("Failed to find a path")
      break
    end
    push!(path, (i,j))
  end
  reverse!(path)

  printmaze(M)
  printmaze(M, path)
  printscore(S)
  println("steps = $(length(path)-1)")
  println("sum = $(sum(S .<= 50))")
end

function test()
  findpath(10, 7, 4)
  findpath(10, 16, 18)
end

function runinput()
  findpath(1364, 31, 39)
end

test()
runinput()
