using Base.Test
using Nettle

function walk(directions)
  (i,j) = (1,1)
  for c in directions
    if c == 'D'
      i += 1
    elseif c == 'U'
      i -= 1
    elseif c == 'R'
      j += 1
    elseif c == 'L'
      j -= 1
    end
  end
  return i, j
end

function steps(pass)
  (i,j) = (1,1)
  done = []
  todo = [pass]
  paths = []

  score = Dict()
  score[pass] = 0

  while length(todo) > 0
    code = shift!(todo)
    ci, cj = walk(code)
    if (ci, cj) == (4,4)
      push!(paths, code[length(pass)+1:end])
      println("Found path: $(paths[end]), $(length(paths[end]))")
      push!(done, code)
      continue
    end

    hex = hexdigest("md5", code)
    vals = map(x->parse(Int, x, 16), split(hex[1:4],""))
    dirs = ['U','D','L','R']
    I = []
    for i = 1:4
      if vals[i] <= 10
        push!(I, i)
      end
    end
    deleteat!(dirs, I)

    for c in dirs
      newcode = "$code$c"
      newcode in done && continue
      i, j = walk("$code$c")
      if i < 1 || j < 1 || i > 4 || j > 4
        continue
      end
      if !( newcode in todo )
        push!(todo, newcode)
      end
      score[newcode] = score[code] + 1
    end
    push!(done, code)

    sort!(todo, by=a->score[a])
  end

  sort!(paths, by=length)

  return paths[1], length(paths[end])
end

function test()
  @test steps("ihgpwlah") == ("DDRRRD", 370)
  @test steps("kglvqrro") == ("DDUDRLRRUDRD", 492)
  @test steps("ulqzkmiv") == ("DRURDRUDDLLDLUURRDULRLDUUDDDRR", 830)
end

function runinput()
  path = steps("mmsxrhfx")
  println("path = $path")
end

test()
runinput()
