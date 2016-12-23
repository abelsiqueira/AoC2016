using Base.Test

function print_char_matrix(M)
  m, n = size(M)
  for j = 1:n
    for i = 1:m
      print(M[i,j])
      print(" ")
    end
    println("")
  end
  println("")
end

function print_path(S, U, P, data; only_last=false)
  m, n = size(S)
  M = fill('.', m, n)
  for i = 1:m
    for j = 1:n
      if U[i,j] >= 100
        M[i,j] = '#'
      elseif U[i,j] == 0
        M[i,j] = '_'
      end
    end
  end
  M[data...] = 'G'
  only_last || print_char_matrix(M)
  for (i,j,ii,jj) in P
    if M[ii,jj] != '_'
      error("?")
    end
    M[ii,jj] = M[i,j]
    M[i,j] = '_'
    only_last || print_char_matrix(M)
  end
  only_last && print_char_matrix(M)
end

function get_size(lines)
  m, n = 0, 0
  for line in lines
    x = match(r"node-x([0-9]+)-y([0-9]+)", line)
    if x != nothing
      m = max(parse(x[1])+1, m)
      n = max(parse(x[2])+1, n)
    end
  end
  return m, n
end

function parse_lines(lines)
  m, n = get_size(lines)
  S, U = zeros(Int, m, n), zeros(Int, m, n)
  for line in lines
    x = match(r"node-x([0-9]+)-y([0-9]+)\s+([0-9]+)T\s+([0-9]+)T", line)
    if x != nothing
      i, j = parse(x[1])+1, parse(x[2])+1
      S[i,j] = parse(x[3])
      U[i,j] = parse(x[4])
    end
  end
  return S, U
end

function shortest_path(S, U, start, data)
  m, n = size(S)
  ktoij(k) = ((k-1)%m+1, div(k-1,m)+1)
  ei, ej = ktoij(findfirst(U .== 0))
  Solutions = Any[]
  short = []
  Visited = [(start..., ei, ej)]

  for (i,j) in [(ei-1,ej), (ei+1,ej), (ei,ej-1), (ei,ej+1)]
    if i < 1 || j < 1 || i > m || j > n || !(isviable(S, U, i, j, ei, ej))
      continue
    end
    sol = [(i,j,ei,ej)]
    push!(Solutions, sol)
  end

  sort!(Solutions, by=P->score_path(U, P, data))

  found = false
  iter = 0
  while !found
    iter += 1
    #println("Iter $iter")
    P = shift!(Solutions)
    #println("P = $P")
    Uc, datac = apply_path(U, P, data)
    if datac == start
      short = P
      found = true
      continue
    end
    ei, ej = ktoij(findfirst(Uc .== 0))
    #println("Empty: ($ei,$ej)")
    #println("Data:  ($(datac[1]),$(datac[2]))")
    for (i,j) in [(ei-1,ej), (ei+1,ej), (ei,ej-1), (ei,ej+1)]
      if i < 1 || j < 1 || i > m || j > n
        continue
      end
      if !isviable(S, Uc, i, j, ei, ej)
        #println("($i,$j) is not viable")
        continue
      end
      sol = [P; (i,j,ei,ej)]
      sc = score_path(U, sol, data)
      #println("  Testing sol ($sc)")
      #print_path(S, U, sol, data, only_last=true)
      _, datac2 = apply_path(U, sol, data)
      if (datac2...,ei,ej) in Visited
        #println("  Already visited")
        continue
      end
      if !(sol in Solutions)
        push!(Solutions, sol)
      end
    end
    push!(Visited, (datac...,ei,ej))
    sort!(Solutions, by=P->score_path(U, P, data))
  end
  println("$iter iterations")

  return short
end

function apply_path(U, P, data)
  Uc = copy(U)
  for (i,j,ii,jj) in P
    Uc[ii,jj] += Uc[i,j]
    Uc[i,j] = 0
    if data == (i,j)
      data = (ii,jj)
    end
  end
  return Uc, data
end

function score_path(U, P, data)
  Uc, data = apply_path(U, P, data)
  m, n = size(U)
  ktoij(k) = ((k-1)%m+1, div(k-1,m)+1)
  empty = ktoij(findfirst(Uc .== 0))
  d(i,j,ii,jj) = abs(i-ii)+abs(j-jj)
  return length(P) + 10d(1,1,data...) + d(data...,empty...)
end

isviable(S, U, i, j, ii, jj) = U[i,j] > 0 && S[ii,jj]-U[ii,jj] > U[i,j]

function grid(lines)
  S, U = parse_lines(lines)
  m, n = size(S)
  viables = 0
  I = ((i,j) for i = 1:m, j = 1:n)
  for (i,j) in I
    for (ii,jj) in I
      if ii == i && jj == j
        continue
      end
      if isviable(S, U, i, j, ii, jj)
        viables += 1
      end
    end
  end

  P = shortest_path(S, U, (1,1), (m,1))
  #print_path(S, U, P, (m,1))

  return viables, P
end

function test()
  lines = readlines(open("test"))
  v, P = grid(lines)
  println("Viables = $v")
  println("#P = $(length(P))")
  # (.). # . G
  #  _ . # . .
  #  . . # . .
  #  . . . . .
  #  . . . . .
  S = 100*ones(Int, 5, 5)
  U = 51*ones(Int, 5, 5)
  U[1,2] = 0
  for j = 1:3
    S[3,j], U[3,j] = 1000, 999
  end
  P = shortest_path(S, U, (1,1), (5,1))
  #print_path(S, U, P, (5,1))
  #println("P = $P")
  println("#P = $(length(P))")
  # (.). # . G
  #  _ . # . .
  #  . . # . .
  #  . . . . .
  #  . . # . .
  #  . . . . .
  S = 100*ones(Int, 5, 6)
  U = 51*ones(Int, 5, 6)
  U[1,2] = 0
  for j = union(1:3,5)
    S[3,j], U[3,j] = 1000, 999
  end
  P = shortest_path(S, U, (1,1), (5,1))
  println("P = $P")
  println("#P = $(length(P))")
end

function runinput()
  lines = readlines(open("input"))
  v, P = grid(lines)
  println("Viables = $v")
  println("#P = $(length(P))")
end

test()
runinput()
