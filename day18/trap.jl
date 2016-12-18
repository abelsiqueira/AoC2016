using Base.Test

function printmap(M)
  m, n = size(M)
  for i = 1:m
    println(join(map(x->x ? '^' : '.', M[i,2:n-1])))
  end
end

function traps(str, L)
  m = length(str)
  M = fill(false, L, m+2)
  M[1, 2:m+1] = split(str,"") .== "^"
  for i = 2:L
    for k = 2:m+1
      M[i,k] = (M[i-1,k-1] && M[i-1,k] && !M[i-1,k+1]) ||
               (M[i-1,k+1] && M[i-1,k] && !M[i-1,k-1]) ||
               (M[i-1,k-1] && !M[i-1,k] && !M[i-1,k+1]) ||
               (M[i-1,k+1] && !M[i-1,k] && !M[i-1,k-1])
    end
  end

  return sum(!M) - 2L
end

function test()
  @test traps("..^^.", 3) == 6
  @test traps(".^^.^.^^^^", 10) == 38
end

function runinput()
  safe = traps(".^^^.^.^^^.^.......^^.^^^^.^^^^..^^^^^.^.^^^..^^.^.^^..^.^..^^...^.^^.^^^...^^.^.^^^..^^^^.....^....", 40)
  println("There are $safe safe tiles")
  safe = traps(".^^^.^.^^^.^.......^^.^^^^.^^^^..^^^^^.^.^^^..^^.^.^^..^.^..^^...^.^^.^^^...^^.^.^^^..^^^^.....^....", 400_000)
  println("There are $safe safe tiles")
end

test()
runinput()
