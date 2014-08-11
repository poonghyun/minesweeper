require 'yaml'

DIRECTIONS = [[1, 0], [-1, 0], [0, 1], [0, -1], [1, -1], [1, 1], [-1, 1], [-1, -1]]

class Board
  attr_accessor :tiles, :bomb_list, :empty_tiles
  def initialize(bombs, size = [9,9])
    @tiles = Array.new(size.first) { Array.new(size.last) { Tile.new } }
    @bomb_list = []
    place_bombs(bombs)
    @empty_tiles = find_empty_tiles
  end
  
  def find_empty_tiles
    empty_tiles = []
    @tiles.each do |row|
      row.each do |tile|
        empty_tiles << tile unless tile.has_bomb
      end
    end
    
    empty_tiles
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
    set_adjacent_bombs
  end
  
  def set_adjacent_bombs
    bomb_list.each do |position|
      adjacent_tiles(position).each do |adj_position|
        tiles[adj_position.first][adj_position.last].adjacent_bombs += 1
      end
    end
  end
  
  def valid_position?(position)
    if position.first >= 0 && position.last >= 0
      if position.first < self.tiles.length && position.last < self.tiles.first.length
        return true
      end
    end
    false
  end
  
  def adjacent_tiles(position)
    adjacent_positions = []
    DIRECTIONS.each do |direction|
      x = position.first + direction.first
      y = position.last + direction.last
      adjacent_positions << [x, y] if valid_position?([x, y])
    end
    adjacent_positions
  end
  
  def reveal_adjacent(adjacent_position)
    adjacent_tile = self.tiles[adjacent_position.first][adjacent_position.last]
    return nil if adjacent_tile.has_bomb || adjacent_tile.flipped || adjacent_tile.has_flag
    if adjacent_tile.adjacent_bombs > 0
      adjacent_tile.flipped = true
      return nil
    end
    adjacent_tile.flipped = true
    check_tiles = adjacent_tiles(adjacent_position)
    check_tiles.each do |position|
      reveal_adjacent(position)
    end
    nil
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
  
  def game_over
    board.empty_tiles.all? {|tile| tile.flipped == true}
  end
  
  def run
    render
    while true
      pos = input_pos
      puts "Will you place/remove a (F)lag, (M)inesweep, or (C)hange position? (F/M/C)"
      move = gets.chomp
      case move
      when "F"
        self.board.tiles[pos.first][pos.last].has_flag = !(self.board.tiles[pos.first][pos.last].has_flag)
      when "M"
        if self.board.tiles[pos.first][pos.last].has_bomb
          p "Better luck next time."
          break
        end
        self.board.reveal_adjacent([pos.first, pos.last])
        if game_over
          render
          p "You're a superstar"
          break
        end
        
      when "C"
      else
        p "That choice is invalid."
        next
      end
      render
      
      #p "Would you like to save your game?"  #saving stuff
      puts "(S)ave, (Q)uit, or (C)ontinue?"
      choice = gets.chomp
      case choice
      when "S"
        puts "Name of save file?"
        filename = gets.chomp + ".txt"
        File.open(filename, 'w') do |f|
          f.puts self.to_yaml
        end
      when "Q"
        break
      when "C"
      else
        p "That's not a choice."
      end
      
    end
  end
    
  def input_pos
    p "Where go x?"
    x = gets.chomp.to_i
    p "Where go y?"
    y = gets.chomp.to_i
    [y, x]
  end
  
  def render
    self.board.tiles.each do |row|
      row.each do |col|
        if col.flipped
          print (col.adjacent_bombs.to_s + " ")
        elsif col.has_flag
          print "F "
        else
          print "+ "
        end
      end
      print "\n"
    end
  end
end


while true
  p "Would you like to (S)tart a new game, (L)oad a previous save file, or (Q)uit?"
  choice = gets.chomp
  case choice
  when "S"
    Game.new(5).run
  when "L"
    p "Give me the file name, sir or madam (or neutral)."
    file_name = gets.chomp
    YAML::load(File.read(file_name)).run
    
  when "Q"
    break
  else
    p "You can't read." 
  end

end







#play again












