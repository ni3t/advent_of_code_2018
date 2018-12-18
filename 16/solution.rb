require "pp"
f = File.read(File.dirname(__FILE__) + "/input.txt")
  .split("\n\n\n")  

# f = <<-EOS
# Before: [0, 0, 0, 0] ### addr example 
# 13 0 1 0
# After:  [0, 0, 0, 0] ### add register 0 (0) and register 1 (0) and put in register 0

# Before: [1, 0, 0, 0] ### addi example 
# 13 0 7 0
# After:  [8, 0, 0, 0] ### add register 0 (1) and value 7 and put in register 0

# Before: [2, 2, 0, 0] ### mulr example 
# 13 0 1 0
# After:  [4, 0, 0, 0] ### multiply register 0 (2) and register 1 (2) and put in register 0 (4)

# Before: [2, 2, 0, 0] ### muli example 
# 13 0 5 0
# After:  [10, 0, 0, 0] ### multiply register 0 (2) and value 5 and put in register 0 (10)

# Before: [2, 3, 0, 0] ### banr example 
# 13 0 1 0
# After:  [10, 0, 0, 0] ###bitwise AND register 0 (10) and register 1 (11) and put in register 0 (10)

# Before: [2, 1, 0, 0] ### bani example 
# 13 0 3 0
# After:  [10, 0, 0, 0] ### bitwise AND register 0 (2)->(10) and value 3 (11) and put in register 0 (10)

# Before: [4, 0, 1, 0] ### borr example 
# 13 0 2 0
# After:  [101, 0, 0, 0] ### bitwise AND register 0 (4)->(100) and register 1 (1)->(001) and put in register 0 (101)

# Before: [4, 6, 0, 0] ### bori example 
# 13 0 1 0
# After:  [101, 0, 0, 0] ### bitwise AND register 0 (4)->(100) and value 1 (001) and put in register 0 (101)

# Before: [8, 0, 0, 0] ### setr example 
# 13 0 1 1
# After:  [0, 8, 0, 0] ### take register 0 (8) and put it in register 1

# Before: [0, 0, 0, 0] ### seti example 
# 13 5 0 1
# After:  [0, 5, 0, 0] ### take value 5 and put it in register 1

# Before: [1, 25, 0, 0] ### gtir example 
# 13 3 0 1
# After:  [0, 1, 0, 0] ### if value 3 is greater than register 0 (1) then 1 else 0 in register 1

# Before: [5, 2, 0, 0] ### gtri example 
# 13 0 1 1
# After:  [0, 1, 0, 0] ### if register 0 (3) greater than value 1 then 1 else 0 in register 1

# Before: [0, 0, 1, 2] ### gtrr example 
# 13 3 2 1
# After:  [0, 1, 0, 0] ### if register 0 (3) greater than register 1 (2) then 1 else 0 in register 1

# Before: [5, 5, 1, 2] ### eqir example 
# 13 5 1 1
# After:  [0, 1, 0, 0] ### if value 5 equal to register 1 (5) then 1 else 0 in register 1

# Before: [5, 5, 1, 2] ### eqri example 
# 13 1 5 1
# After:  [0, 1, 0, 0] ### if register 1 (5) equal to value 5 then 1 else 0 in register 1

# Before: [5, 5, 1, 2] ### eqrr example 
# 13 0 1 1
# After:  [0, 1, 0, 0] ### if register 0 (5) equal to register 1 (5) then 1 else 0 in register 1


# 1 2 3 4
# EOS
# f=f.split("\n\n\n")

a = f[0].split("\n\n")
c = f[1].split("\n")
c.shift

op_map = {
  :gtri=>{:idx => nil, fn: ->(a,b,c,r){ r[c] = r[a] > b ? 1 : 0;r } },
  :gtrr=>{:idx => nil, fn: ->(a,b,c,r){ r[c] = r[a] > r[b] ? 1 : 0;r } },
  :eqri=>{:idx => nil, fn: ->(a,b,c,r){ r[c] = r[a] = b ? 1 : 0;r } },
  :eqir=>{:idx => nil, fn: ->(a,b,c,r){ r[c] = a == r[b] ? 1 : 0;r } },
  :eqrr=>{:idx => nil, fn: ->(a,b,c,r){ r[c] = r[a] == r[b] ? 1 : 0;r } },
  :gtir=>{:idx => nil, fn: ->(a,b,c,r){ r[c] = a > r[b] ? 1 : 0;r } },
  :banr=>{:idx => nil, fn: ->(a,b,c,r){ r[c] = r[a] & r[b];r } },
  :setr=>{:idx => nil, fn: ->(a,b,c,r){ r[c] = r[a];r } },
  :bani=>{:idx => nil, fn: ->(a,b,c,r){ r[c] = r[a] & b;r } },
  :seti=>{:idx => nil, fn: ->(a,b,c,r){ r[c] = a;r } },
  :addr=>{:idx => nil, fn: ->(a,b,c,r){ r[c] = r[a] + r[b];r } },
  :mulr=>{:idx => nil, fn: ->(a,b,c,r){ r[c] = r[a] * r[b];r } },
  :muli=>{:idx => nil, fn: ->(a,b,c,r){ r[c] = r[a] * b;r } },
  :addi=>{:idx => nil, fn: ->(a,b,c,r){ r[c] = r[a] + b;r } },
  :bori=>{:idx => nil, fn: ->(a,b,c,r){ r[c] = r[a] | b;r } },
  :borr=>{:idx => nil, fn: ->(a,b,c,r){ r[c] = r[a] | r[b];r} }
}


Instruction = Struct.new(:opcode,:input1,:input2,:output){
  def acts_like(before,after,ig)
    #puts "#{before} => [#{opcode}, #{input1}, #{input2}, #{output}] => #{after}"
    {
      #addr
      addr: ->{
          invalid = self.input1 > 3 || self.input2 > 3 || ig.include?(:addr)
          if invalid
            #puts "addr invalid"
            return false
          end
          res = before[self.input1] + before[self.input2] == after[self.output]
          #puts "addr #{res}"
          res
        }.call,

      #addi
      addi: ->{
          if (self.input1 > 3 || ig.include?(:addi))
            #puts "addi invalid"
            return false
          end
          res = before[self.input1] + self.input2 == after[self.output]
          #puts "addi #{res}"
          res
        }.call,

      #mulr
      mulr: ->{
          if (self.input1 > 3 || self.input2 > 3 || ig.include?(:mulr))
            #puts "mulr invalid"
            return false
          end
          res = before[self.input1] * before[self.input2] == after[self.output]
          #puts "mulr #{res}"
          res
        }.call,
      
      #muli
      muli:->{
          if (self.input1 > 3 || ig.include?(:muli))
            #puts "muli invalid"
            return false
          end
          res = before[self.input1] * self.input2 == after[self.output]
          #puts "muli #{res}"
          res
        }.call,

      #banr
      banr: ->{
          if (self.input1 > 3 || self.input2 > 3 || ig.include?(:banr))
            #puts "banr invalid"
            return false
          end
          res = (before[self.input1] & before[self.input2]).to_s(2) == after[self.output].to_s
          #puts "banr #{res}"
          res
        }.call,

      #bani
      bani: ->{
          if (self.input1 > 3 || ig.include?(:bani))
            #puts "bani invalid"
            return false
          end
          res = (before[self.input1] & self.input2).to_s(2) == after[self.output].to_s
          #puts "bani #{res}"
          res
        }.call,

      #borr
      borr: ->{
          if (self.input1 > 3 || self.input2 > 3 || ig.include?(:borr))
            #puts "borr invalid"
            return false
          end
          res = (before[self.input1] | before[self.input2]).to_s(2) == after[self.output].to_s
          #puts "borr #{res}"
          res
        }.call,

      #bori
      bori: ->{
          if (self.input1 > 3 || ig.include?(:bori))
            #puts "bori invalid"
            return false
          end
          res = (before[self.input1] | self.input2).to_s(2) == after[self.output].to_s
          #puts "borr #{res}"
          res
        }.call,

      #setr
      setr: ->{
          if (self.input1 > 3 || ig.include?(:setr))
            #puts "setr invalid"
            return false
          end
          res = before[self.input1] == after[self.output]
          #puts "setr #{res}"
          res
        }.call,
      #seti
      seti: ->{
          if ig.include?(:seti)
            return false
          end
          res = self.input1 == after[self.output]
          #puts "setr #{res}"
          res
      }.call,
      #gtir
      gtir: ->{
        if (self.input2 > 3 || ig.include?(:gtir))
          #puts "gtir invalid"
          return false
        end
        res = (self.input1 - before[self.input2] > 0) ? (after[self.output] == 1) : (after[self.output] == 0)
        #puts "gtir #{res}"
        res  
      }.call,
        #gtri
      gtri: ->{
        if (self.input1 > 3 || ig.include?(:gtri))
          #puts "gtri invalid"
          return false
        end
        res = (before[self.input1] - self.input2 > 0) ? (after[self.output] == 1) : (after[self.output] == 0)
        #puts "gtri #{res}"
        res
      }.call,
      #gtrr
      gtrr: ->{
        if (self.input1 > 3 || self.input2 > 3 || ig.include?(:gtrr))
          #puts "gtrr invalid"
          return false
        end
        res = (before[self.input1] - before[self.input2] > 0) ? (after[self.output] == 1) : (after[self.output] == 0)
        #puts "gtrr #{res}"
        res
      }.call,
      #eqir
      eqir: ->{
        if (self.input2 > 3 || ig.include?(:eqir))
          #puts "eqir invalid"
          return false
        end
        res = (self.input1 == before[self.input2]) ? (after[self.output] == 1) : (after[self.output] == 0)
        #puts "eqir #{res}"
        res
      }.call,
      #eqri
      eqri: ->{
        if (self.input1 > 3 || ig.include?(:eqri))
          #puts "eqri invalid"
          return false
        end
        res = (before[self.input1] == self.input2) ? (after[self.output] == 1) : (after[self.output] == 0)
        #puts "eqri #{res}"
        res
      }.call,
      #eqrr
      eqrr: ->{
        if (self.input1 > 3 || self.input2 > 3 || ig.include?(:eqrr))
          #puts "eqrr invalid"
          return false
        end
        res = (before[self.input1] == before[self.input2]) ? (after[self.output] == 1) : (after[self.output] == 0)
        #puts "eqrr #{res}"
        res
      }.call
    }
  end
  def perform
    op_map.select{|op| op.idx == self.opcode}.fn.call
  end
}

Set = Struct.new(:before,:instruction,:after,:ignored_ops){
  def get_acts_like
    instruction.acts_like(self.before,self.after,ignored_ops)
  end
}

first_part = a.map do |set|
  b,i,a = set.split("\n")
  next if [b,i,a].none?
  Set.new(
    b.split("[")[1].split("]")[0].split(",").map(&:to_i),
    Instruction.new(*(i.split(" ").map(&:to_i))),
    a.split("[")[1].split("]")[0].split(",").map(&:to_i),
    []
  )
end


second_part = c.map{|line| 
  Instruction.new(*(line.split(" ").map(&:to_i)))
}

ans1 = first_part.map(&:get_acts_like).select{|i| i.values.count{|j| j == true} >= 3}.count
pp ans1
@fp = ([]<<first_part).flatten

@count = 0
@ignored = []
until @count == 17
  @op=nil
  @opcode=nil
  @fp.map do |set|
    if set.get_acts_like.values.select{|v|v}.count == 1
      @op = set.get_acts_like.select{|k,v|v}.first.first
      @opcode = set.instruction.opcode
      op_map[@op][:idx] = @opcode
      @ignored << @op
    end
  end
  @ignored = @ignored.uniq.flatten
  @fp.map{|set| set.ignored_ops = @ignored}
  @fp = @fp.reject{|set| set.instruction.opcode == @opcode}
  @count += 1
end

puts c.reduce([0,0,0,0]){|a,i| 
  i = i.split(" ").map(&:to_i)
  op = op_map.select{|op| op_map[op][:idx] == i.first}.first
  a = op[1][:fn].call(i[1],i[2],i[3],a)
  a
}