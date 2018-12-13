require 'pp'
# 435 players; last marble is worth 71184 points

player_count = 435
last_marble = 7118400

# player_count = 13
# last_marble = 7999
circle = [0]

Struct.new("Game", :circle, :active_marble, :scores, :active_player)

@game = Struct::Game.new(circle,0,Array.new(player_count){0},1)

(1..last_marble).each do |i|
  if i%23 == 0
    player = i % player_count
    active_index = @game.circle.index(@game.active_marble)
    take_index = active_index - 7
    @game.active_marble = @game.circle[take_index+1]
    addl_score = @game.circle.delete_at(take_index)
    @game.scores[player] += i + addl_score
    @game.active_player = i % player_count
    @game.circle = @game.circle.rotate(@game.circle.index(@game.active_marble)-1)
  else
    @game.circle = @game.circle.rotate(2).insert(1,i)
    @game.active_marble = i
    @game.active_player = i % player_count
  end
  # puts @game
end
# @game.circle = @game.circle.rotate(@game.circle.index(0))
# puts @game

puts @game.scores.max