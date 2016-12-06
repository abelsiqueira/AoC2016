using Base.Test

function decode(lines)
  n = length(lines)
  m = length(lines[1])
  msg = fill("_", m)
  msg2 = fill("_", m)
  for i = 1:m
    col = [lines[k][i] for k = 1:n]
    un = unique(col)
    most = 0
    least = Inf
    for a in un
      s = sum(col .== a)
      if s > most
        most = s
        msg[i] = "$a"
      end
      if s < least
        least = s
        msg2[i] = "$a"
      end
    end
  end
  return join(msg), join(msg2)
end

function test()
  lines = split("eedadn
           drvtee
           eandsr
           raavrd
           atevrs
           tsrnev
           sdttsa
           rasrtv
           nssdts
           ntnada
           svetve
           tesnvt
           vntsnd
           vrdear
           dvrsen
           enarar")
  @test decode(lines) == ("easter", "advent")
end

function runinput()
  msg, msg2 = decode(readlines(open("input")))
  println("msg = $msg")
  println("msg2 = $msg2")
end

test()
runinput()
