require 'pp'
f = File.read("/Users/nbell/dev/advent2018/problems/2/input.txt").split("\n")

# checksum func
puts->a{a.count(2)*a.count(3)}.call(f.map{|s|s.chars.map{|c|s.count(c)}.uniq}.flatten)

# ids func 
puts->a{(a[0]-(a[0]-a[1])).join}.call(f.map{|s|s.chars}.combination(2).map{|c|c[0].zip(c[1]).map{|p|p.uniq.count-1}.reduce(&:+)==1 ? c : nil}.compact[0])
