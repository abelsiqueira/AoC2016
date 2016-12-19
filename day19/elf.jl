using Base.Test

function elfs(n; verbose=false)
  v = collect(1:n)
  i = 2
  verbose && println(length(v) > 100 ? "# $(length(v))" : v)
  while length(v) > 1
    m = length(v)
    I = i:2:m
    deleteat!(v, I)
    i = I[end] == m ? 2 : 1
    verbose && println(length(v) > 100 ? "# $(length(v))" : v)
  end
  return v[1]
end

function elfa2(n; verbose=false)
  v = collect(1:n)
  i = 1
  verbose && println(length(v) > 100 ? "# $(length(v))" : v)
  while length(v) > 1
    j = (i + div(length(v), 2) - 1) % length(v) + 1
    if verbose
      print("i = $i, j = $j ")
      println("$(v[i]) -> $(v[j])")
    end
    j < i && (i -= 1)
    deleteat!(v, j)
    i = i % length(v) + 1
    verbose && println(length(v) > 100 ? "# $(length(v))" : v)
  end
  return v[1]
end

function elfa(n; verbose=false)
  v = collect(1:n)
  verbose && println(length(v) > 100 ? "# $(length(v))" : v)
  while length(v) > 3
    m = length(v)
    if m % 2 == 0
      I1 = collect( (1+div(m,2)):3:m )
      I2 = (2+div(m,2)):3:m
    else
      I1 = collect( (3+div(m,2)):3:m )
      I2 = (1+div(m,2)):3:m
    end
    if I1[end] > I2[end]
      pop!(I1)
    end
    I = sort(union(I1,I2))
    if length(I) == 0
      error("FU")
    end
    j = length(I) + 1
    deleteat!(v, I)
    v = [v[j:end]; v[1:j-1]]
    verbose && println(length(v) > 100 ? "# $(length(v))" : v)
  end
  if length(v) == 1
    return v[1]
  elseif length(v) == 2
    return v[1]
  elseif length(v) == 3
    return v[3]
  end
end

function test()
  @test elfs(5) == 3
  @test elfs(7) == 7
  @test elfa(5) == 2
  for n = 1:100
    @test elfa(n) == elfa2(n)
  end
end

function runinput()
  e = elfs(3017957)
  println("e = $e")
  e = elfa(3017957)
  println("e = $e")
end

test()
runinput()
