using Nettle
using Base.Test

function findpass(id)
  n = 0
  pass = fill("_", 8)
  k = 1
  while any(pass .== "_")
    hex = hexdigest("md5", "$id$n")
    if hex[1:5] == "00000"
      pass[k] = hex[6:6]
      k += 1
      println(join(pass))
    end
    n += 1
  end
  return join(pass)
end

function findpasshard(id)
  n = BigInt(0)
  pass = fill("_", 8)
  while any(pass .== "_")
    hex = hexdigest("md5", "$id$n")
    if hex[1:5] == "00000"
      try
        i = parse(hex[6:6])
        if isa(i, Integer) && 0 <= i <= 7 && pass[i+1] == "_"
          pass[i+1] = hex[7:7]
          println(join(pass))
        end
      end
    end
    n += 1
  end
  return join(pass)
end

function test()
  @test findpass("abc") == "18f47a30"
  @test findpasshard("abc") == "05ace8e3"
end

function runinput()
  pass = findpass("uqwqemis")
  println("pass = $pass")
  pass = findpasshard("uqwqemis")
  println("pass = $pass")
end

test()
runinput()
