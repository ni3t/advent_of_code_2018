file = File.read(File.dirname(__FILE__) + "/input.txt")

lines = file.split("\n")

@output = 0

lines.each do |line|
  operator = line[0]
  number = line[1..-1].to_i
  if operator == "+"
    @output += number
  end
  if operator == "-"
    @output -= number
  end
end

puts @output