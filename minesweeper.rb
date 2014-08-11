DIRECTIONS = [[1, 0], [-1, 0], [0, 1], [0, -1], [1, -1], [1, 1], [-1, 1], [-1, -1]]

class Board
  attr_accessor :tiles, :bomb_list
  def initialize(bombs, size = [9,9])
    @tiles = Array.new(size.first) { Array.new(size.last) { Tile.new } }
    @bomb_list = []
    place_bombs(bombs)
  end
  
  def place_bombs(num_bombs)
    placed = 0
    while placed < num_bombs
      y = rand(0...tiles.first.length)
      x = rand(0...tiles.length)
      unless tiles[x][y].has_bomb
        tiles[x][y].has_bomb = true 
        bomb_list << [x,y]
        placed += 1
      end
    end
    get_adjacent_bombs
  end
  
  def get_adjacent_bombs
    bomb_list.each do |position|
      DIRECTIONS.each do |direction|
        x = position.first + direction.first
        y = position.last + direction.last
        afflicted_square = [x, y]
        p valid_position?(afflicted_square)
        tiles[x][y].adjacent_bombs += 1 if valid_position?(afflicted_square)
      end
    end
  end
  
  def valid_position?(position)
    p position
    if position.first >= 0 && position.last >= 0
      if position.first < self.tiles.length && position.last < self.tiles.first.length
        return true
      end
    end
    false
  end
  
end


class Tile
  attr_accessor :has_flag, :has_bomb, :flipped, :adjacent_bombs
  
  def initialize
    @has_flag = false
    @has_bomb = false
    @flipped = false
    @adjacent_bombs = 0
  end
  
end

class Game
  attr_accessor :board
  def initialize(bombs)
    @board = Board.new(bombs)
  end
  
  def reveal(move)
    raise "go to hell" if self.board.tiles[move.first][move.last].flipped
    
  end
end

class Output
  def initialize
    
  end
  
  
end

#
# test = Board.new([9,9], 10)
# test.board.each do |row|
#   row.each do |height|
#     height.has_bomb
#   end
# end
#

