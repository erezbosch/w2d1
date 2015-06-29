class Board
  attr_reader :grid

  ADJACENT_POSITIONS = [
    [1, -1],
    [1, 0],
    [1, 1],
    [0, -1],
    [0, 1],
    [-1, -1],
    [-1, 0],
    [-1, 1]
  ]

  def initialize size = 9, num_bombs = size
    @grid = Array.new(size) { Array.new(size) }
    populate(num_bombs)
  end

  def populate num_bombs
    tiles = []
    num_bombs.times { tiles << Tile.new(true)}
    (@grid.flatten.size - num_bombs).times {tiles << Tile.new }
    tiles.shuffle!
    @grid.map! do |grid_row|
      grid_row.map! { tiles.shift }
    end
  end

  def [] pos
    row, col = pos
    @grid[row][col]
  end

  def []= pos, mark
    row, col = pos
    @grid[row][col] = mark
  end

  def link_neighbors
    @grid.each_with_index do |grid_row, grid_row_idx|
      grid_row.each_index do |grid_col_idx|

      end
    end

  end

  def add_neighbors row, col
    adjacents = ADJACENT_POSITIONS.map do |adj_pos|
      [row + adj_pos[0], col + adj_pos[1]]
    end.select {|adj_pos| adj_pos.all? { |el| el.between?(0, @grid.size - 1) } }


  end
end
