class Tile
  attr_reader :is_bomb

  def initialize is_bomb = false
    @is_bomb = is_bomb
    @flagged = false
    @revealed = false
    @neighbors = []
  end

  def flag
    @flagged = !@flagged
  end

  def add_neighbor neighbor
    @neighbors << neighbor
  end

  def neighboring_bombs
    @neighbors.inject(0) { |bombs, el| bombs + 1 if el.is_bomb }
  end

  def to_s
    if @flagged
      "F"
    elsif !@revealed
      "*"
    elsif @is_bomb
      "B"
    else
      if neighboring_bombs == 0
        "_"
      else
        neighboring_bombs.to_s
      end
    end
  end
end
