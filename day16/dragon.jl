using Base.Test

function dragon(L, init)
  s = init
  while length(s) < L
    a = s
    b = map(x->x == '0' ? '1' : '0', reverse(a))
    s = "$(a)0$b"
  end
  s = s[1:L]
  while length(s) % 2 == 0
    s = [s[(1:2)+i] for i = 0:2:length(s)-2]
    s = join(map(x->x[1]==x[2] ? '1' : '0', s))
  end
  return s
end

function test()
  @test dragon(12, "110010110100") == "100"
  @test dragon(20, "10000") == "01100"
end

function runinput()
  s = dragon(272, "01111010110010011")
  println("checksum = $s")
  s = dragon(35651584, "01111010110010011")
  println("checksum = $s")
end

test()
runinput()
