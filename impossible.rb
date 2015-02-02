def euclid(x, y)
  until x == y
    if x > y
      x = x - y
    else
      y = y - x
    end
  end
  x
end

euclid(18, 12)
