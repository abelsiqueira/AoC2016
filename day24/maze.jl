using Base.Test
using JuMP

function parse_maze(lines)
  m = length(lines)
  n = length(chomp(lines[1]))
  M = fill("#", m, n)
  for i = 1:m
    line = chomp(lines[i])
    M[i,:] = split(line, "")
  end
  positions = []
  k = 0
  while true
    f = findfirst(M .== "$k")
    if f > 0
      push!(positions, ((f-1)%m+1, div(f-1,m)+1))
      k += 1
    else
      break
    end
  end
  return M, positions
end

function print_maze(M)
  m, n = size(M)
  for i = 1:m
    for j = 1:n
      print(M[i,j])
    end
    println("")
  end
  println("")
end

function find_distance_matrix(M, positions)
  m, n = size(M)
  npos = length(positions)
  D = zeros(Int, npos, npos)
  for pos = 1:npos
    S = 2m*n*ones(Int, m, n)
    done = []
    todo = [positions[pos]]
    S[positions[pos]...] = 0
    while length(todo) > 0
      ci, cj = shift!(todo)
      for (i,j) in [(ci+1,cj), (ci-1,cj), (ci,cj-1), (ci,cj+1)]
        if i < 1 || j < 1 || i > m || j > n || (i,j) in done || M[i,j] == "#"
          continue
        end
        if M[i,j] != "."
          k = parse(M[i,j])
          if k != pos-1
            if D[pos,k+1] == 0
              D[pos,k+1] = D[k+1,pos] = S[ci,cj]+1
            end
            continue
          end
        end
        if !( (i,j) in todo)
          push!(todo, (i,j))
        elseif S[i,j] <= S[ci,cj]
          continue
        end
        S[i,j] = S[ci,cj] + 1
      end
      push!(done, (ci,cj))
    end
    sort!(todo, by=a->S[a[1],a[2]])
  end
  return D
end

function find_route(D)
  npos = size(D, 1)
  bestf = Inf
  # Where does it end ?
  for e = 2:npos
    m = Model()
    @variable(m, x[1:npos,1:npos], Bin)
    @objective(m, Min, sum(x[i,j]*D[i,j] for i = 1:npos, j = 1:npos))
    for i = 1:npos
      for j = 1:npos
        if D[i,j] == 0
          @constraint(m, x[i,j] == 0)
        end
      end
    end
    for i = 1:npos
      k = i == 1 ? 1 : (i == e ? -1 : 0)
      @constraint(m, sum(x[i,j] for j = 1:npos) -
                  sum(x[j,i] for j = 1:npos) == k)
      k = i == e ? 0 : 1
      @constraint(m, sum(x[i,j] for j = 1:npos) >= k)
      k = i == 1 ? 0 : 1
      @constraint(m, sum(x[j,i] for j = 1:npos) >= k)
    end

    solve(m)
    X = map(Int, getvalue(x))
    loop = get_loop_nodes(X)
    while length(loop) > 0
      nloop = setdiff(1:npos, loop)
      @constraint(m, sum(x[i,j] for i=nloop, j=loop) >= 1)
      solve(m)
      X = map(Int, getvalue(x))
      loop = get_loop_nodes(X)
    end
    #println(m)

    #=
    for i = 1:npos
      for j = 1:npos
        if X[i,j] == 1
          println("$(i-1) -> $(j-1)")
        end
      end
    end
    =#
    f = getobjectivevalue(m)
    bestf = min(f, bestf)
    #println(x)
    #println(f)
  end
  return bestf
end

function find_route_and_back(D)
  npos = size(D, 1)
  bestf = Inf
  # Where does it end ?
  m = Model()
  @variable(m, x[1:npos,1:npos], Bin)
  @objective(m, Min, sum(x[i,j]*D[i,j] for i = 1:npos, j = 1:npos))
  for i = 1:npos
    for j = 1:npos
      if D[i,j] == 0
        @constraint(m, x[i,j] == 0)
      end
    end
  end
  for i = 1:npos
    @constraint(m, sum(x[i,j] for j = 1:npos) -
                sum(x[j,i] for j = 1:npos) == 0)
    @constraint(m, sum(x[i,j] for j = 1:npos) >= 1)
    @constraint(m, sum(x[j,i] for j = 1:npos) >= 1)
  end

  solve(m)
  X = map(Int, getvalue(x))
  loop = get_loop_nodes(X)
  while length(loop) > 0
    nloop = setdiff(1:npos, loop)
    @constraint(m, sum(x[i,j] for i=nloop, j=loop) >= 1)
    solve(m)
    X = map(Int, getvalue(x))
    loop = get_loop_nodes(X)
  end
  #println(m)

  #=
  for i = 1:npos
    for j = 1:npos
      if X[i,j] == 1
        println("$(i-1) -> $(j-1)")
      end
    end
  end
  =#
  f = getobjectivevalue(m)
  bestf = min(f, bestf)
  #println(x)
  #println(f)
end

function get_loop_nodes(X)
  n = size(X,1)
  v = fill(false, n)
  v[1] = true
  todo = [1]
  done = []
  while length(todo) > 0
    i = shift!(todo)
    for j = 1:n
      X[i,j] == 0 && continue
      j in done && continue
      if !(j in todo)
        push!(todo, j)
      end
      v[j] = true
    end
    push!(done, i)
  end
  I = find(!v)
  return I
end

function maze(lines)
  M, positions = parse_maze(lines)

  D = find_distance_matrix(M, positions)
  best = find_route(D)
  best2 = find_route_and_back(D)
  return best, best2
end

function test()
  lines = readlines(open("test"))
  best, best2 = maze(lines)
  println("best = $best")
  println("best2 = $best2")
  lines = readlines(open("test2"))
  best, best2 = maze(lines)
  println("best = $best")
  println("best2 = $best2")
end

function runinput()
  lines = readlines(open("input"))
  best, best2 = maze(lines)
  println("best2 = $best2")
  println("best = $best")
end

test()
runinput()
