file = File.read(File.dirname(__FILE__) + "/input.txt").split("\n")

@count = 0
@history = []
@matched = false

until @matched == true
  file.each do |i|
    @count += i.to_i
    if @history.include? @count
      @matched = true
      puts "FOUND IT #{@count}"
    end
    @history << @count
  end
end

puts @count