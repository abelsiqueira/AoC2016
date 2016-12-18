using Base.Test
using Nettle

function otp(salt, xtra=0)
  possible = []
  nkeys = 0
  keys = []
  right_key = 0

  i = 0
  while true
    hex = hexdigest("md5", "$salt$i")
    for x = 1:xtra
      hex = hexdigest("md5", hex)
    end

    # deleting
    I = []
    n = length(possible)
    for j = 1:n
      key, k = possible[j]
      kl = key[1]
      if contains(hex, "$key$kl$kl")
        push!(keys, possible[j])
        nkeys += 1
        push!(I, j)
        #println("$i Key found for $key at $k. So far $nkeys keys")
      end
    end
    if length(I) > 0
      deleteat!(possible, I)
    end
    sort!(keys, by=x->x[2])
    if nkeys >= 64 && i > keys[64][2] + 1000
      break
    end

    filter!(x->x[2] > i - 1000, possible)

    m = matchall(r"(.)\1\1", hex)
    if length(m) > 0
      push!(possible, (m[1],i))
      #println("$i New $(m[1])")
    end

    i += 1
  end

  #for (i,key) in enumerate(keys)
    #println("Key $i at $(key[2])")
  #end
  return keys[64][2]
end

function test()
  #@test otp("abc") == 22728
  #@test otp("abc", 2016) == 22551
end

function runinput()
  #key = otp("yjdafjpo")
  #println("key = $key")
  key = otp("yjdafjpo", 2016)
  println("key = $key")
end

test()
runinput()
