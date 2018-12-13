require 'pp'
f = File.read('/Users/nbell/dev/advent2018/problems/5/input.txt').split("\n").join

@new = []


# puts->(ords,n){ords.each{|c| (n<<c && next)if(n.empty?);(n.pop)if((c-n.last).abs==32);n.push(c);end}}.call(f.chars.map(&:ord),[f[0].ord]).map(&:chr).join.length

f.chars.map(&:ord).each do |c|
  if @new.empty?
    @new << c
    next
  end
  if (c-@new.last).abs == 32
    @new.pop
    next
  else
    @new.push(c)
  end
end

puts @new.map(&:chr).join.length

res = ("a".."z").map do |letter|
  ff = f.gsub(/[#{letter}#{letter.upcase}]/, "")
  @new = []

  ff.chars.map(&:ord).each do |c|
    if @new.empty?
      @new << c
      next
    end
    if (c-@new.last).abs == 32
      @new.pop
      next
    else
      @new.push(c)
    end
  end
  {char: letter, final: @new.map(&:chr).join.length}
end

pp res.min_by{|r| r[:final]}[:final]