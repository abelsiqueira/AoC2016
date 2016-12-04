function realroom(s)
  m = match(r"(.*)\[(.*)\]", s)
  spl = split(m[1], "-")

  dict = Dict()
  for x in spl[1:end-1]
    for i in x
      if i in keys(dict)
        dict[i] += 1
      else
        dict[i] = 1
      end
    end
  end
  (k, v) = collect(keys(dict)), collect(values(dict))
  vu = sort(unique(v), rev=true)
  #println("vu = $vu")
  veri = ""
  for n in vu
    I = find(v .== n)
    veri *= join(sort(k[I]))
  end
  if length(veri) > 5
    veri = veri[1:5]
  end
  #println("k = $k")
  #println("v = $v")
  #println("veri = $veri")
  return veri == m[2], spl[end]
end

function shift(letter, s)
  return Char( (letter-'a'+s)%26 + 'a' )
end

function decrypt(s)
  words = split(s, "-")
  amt = parse(words[end])
  out = ""
  for word in words[1:end-1]
    N = length(word)
    w = ""
    for i = 1:N
      c = shift(word[i], amt)
      w *= "$c"
    end
    out *= "$w "
  end
  return strip(out)
end

function test()
  @assert realroom("aaaaa-bbb-z-y-x-123[abxyz]") == (true, "123")
  @assert realroom("a-b-c-d-e-f-g-h-987[abcde]") == (true, "987")
  @assert realroom("not-a-real-room-404[oarel]") == (true, "404")
  @assert realroom("totally-real-room-200[decoy]") == (false, "200")
  @assert decrypt("qzmt-zixmtkozy-ivhz-343") == "very encrypted name"
end

function runinput()
  lines = readlines("input")
  s = 0
  for line in lines
    valid, id = realroom(chomp(line))
    if valid
      s += parse(id)
      m = match(r"(.*)\[(.*)\]", line)
      d = decrypt(m[1])
      println("$id $d")
    end
  end
  println("s = $s")
end

test()

runinput()
