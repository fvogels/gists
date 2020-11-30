def integers
  Enumerator.new do |yielder|
    i = 0
    while true
      yielder << i
      i += 1
    end
  end
end
