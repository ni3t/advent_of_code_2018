puts File.read(File.dirname(__FILE__) + "/input.txt").split("\n").reduce(0) {|m, i| m.send(i[0].to_sym, i[1..-1].to_i)}