require 'pp'
f = File.read('/Users/nbell/dev/advent2018/problems/8/input.txt').split(" ").map(&:to_i)

# f = %w(2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2).map(&:to_i)

Struct.new("Node", :header, :remainder, :children, :metadata)

def build_subtree struct
  struct.children = (0...struct.header[0]).map do |i|
    cc = struct.remainder.shift
    mc = struct.remainder.shift
    s = Struct::Node.new([cc,mc], struct.remainder, [],[])
    if cc == 0 || struct.header[0] == struct.children.count
      mc.times do
        s.metadata << s.remainder.shift
      end
      s.remainder = []
      struct.children << s
    else
      struct.children << build_subtree(s)
    end
    if i == struct.header[0] - 1
      struct.header[1].times do
        struct.metadata << struct.remainder.shift
      end
      struct.remainder = []
    end
    s
  end
  struct
end

s = Struct::Node.new([f[0],f[1]], f[2..-1], [], [])
root = build_subtree(s)

def count_metadata node
  n = node.metadata.reduce(&:+)
  c = 0
  if node.children.any? 
    c = node.children.map{|c| count_metadata(c)}.flatten.reduce(&:+)
  end
  n + c
end

puts "total count #{count_metadata(root)}"

# part 2

@count = 1

def derive_value node
  @res = 0
  @count += 1
  if node.children.length > 0
    @res = node.metadata.select{|m| (1..node.children.length).include? m}.map{|m|
      new_node = node.children[m-1]
      derive_value(new_node) || 0
    }.inject(&:+)
  else
    @res = node.metadata.inject(&:+)
  end
  @res
end

total_value = derive_value(root)
puts "total value #{total_value}"