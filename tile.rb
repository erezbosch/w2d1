require 'colorize'

class Tile
  attr_reader :is_bomb, :neighbors, :flagged, :revealed

  def initialize is_bomb = false
    @is_bomb = is_bomb
    @flagged = false
    @revealed = false
    @neighbors = []
  end

  def flag
    @flagged = !@flagged unless @revealed
  end

  def add_neighbor neighbor
    @neighbors << neighbor
  end

  def neighboring_bombs
    @neighbors.inject(0) { |bombs, el| el.is_bomb ? bombs + 1 : bombs}
  end

  def reveal
    unless @revealed
      @revealed = true
      if neighboring_bombs == 0 && !@is_bomb
        @neighbors.each do |neighbor|
          neighbor.flag if neighbor.flagged
          neighbor.reveal
        end
      end
    end
  end

  def to_s
    if @flagged
      "⚑".green
    elsif !@revealed
      "*"
    elsif @is_bomb
      "B".red
    else
      neighboring_bombs == 0 ? "_".yellow : neighboring_bombs.to_s.yellow
    end
  end

  def bomb_revealed?
    @is_bomb && @revealed
  end

  def plant_bomb
    @is_bomb = true
  end
end
