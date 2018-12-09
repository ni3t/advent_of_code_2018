require 'pp'
f = File.read("/Users/nbell/dev/advent2018/problems/3/input.txt").split("\n")

# part 1
puts->g{f.map{|c|r=/^#(.*) @ (.*),(.*): (.*)x(.*)$/.match(c);->h{h.each{|k,v|h[k]=v.to_i}}.call({i:r[1],x:r[2],y:r[3],w:r[4],h:r[5]})}.each{|h|h[:w].times{|x|h[:h].times{|y|g[h[:y] + y][h[:x] + x] << h[:i]}}};g.map{|x|x.map{|y|y.count>1}.flatten}.flatten.count(true)}.call(Array.new(1100){Array.new(1100){[]}})

#part 2
puts->h{h.each{|h1|return(h1[:i])unless(h-[h1]).map{|h2|[[:x,:w],[:y,:h]].map{|d|->p{(p[0]-p[1]).length!=p[0].length}.call([h1,h2].map{|h|(h[d[0]]..h[d[0]]+h[d[1]]).to_a})}.all?&&break}.nil?}}.call(f.map{|c|r=/^#(.*) @ (.*),(.*): (.*)x(.*)$/.match(c);->h{h.each{|k,v|h[k]=v.to_i}}.call({i:r[1],x:r[2],y:r[3],w:r[4],h:r[5]})})
