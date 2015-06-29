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
    @grid = Array.new(size) { Array.new(size) { Tile.new } }
    populate(num_bombs)
    link_neighbors
  end

  def populate num_bombs
    bombs_planted = 0
    until bombs_planted == num_bombs
      pos = [rand(@grid.size), rand(@grid.size)]
      unless self[pos].is_bomb
        self[pos].plant_bomb
        bombs_planted += 1
      end
    end
  end

  def [] pos
    row, col = pos
    @grid[row][col]
  end

  def link_neighbors
    @grid.each_with_index do |grid_row, grid_row_idx|
      grid_row.each_index do |grid_col_idx|
        add_neighbors([grid_row_idx, grid_col_idx])
      end
    end
  end

  def add_neighbors pos
    row, col = pos
    adjacents = ADJACENT_POSITIONS.map do |adj_pos|
      [row + adj_pos[0], col + adj_pos[1]]
    end
    adjacents = adjacents.select do |adj_pos|
      adj_pos.all? { |el| el.between?(0, @grid.size - 1) }
    end
    adjacents.each do |adj_pos|
      self[pos].add_neighbor(self[adj_pos])
    end
  end

  def bomb_revealed?
    @grid.flatten.any? { |el| el.bomb_revealed? }
  end

  def over?
    won? || bomb_revealed?
  end

  def won?
    @grid.flatten.all? do |el|
      (el.is_bomb && el.flagged) || (!el.is_bomb && el.revealed)
    end
  end

  def render_with_cursor(cursor)
    system "clear"
    puts "Press IJKL to move your cursor. "
    puts "Press the space bar to reveal a square or f to flag it. "
    puts "Press shift-S to save and quit. "

    (0...@grid.size).each do |row|
      (0...@grid.size).each do |col|
        print [row, col] == cursor ? "^ " : "#{self[[row, col]].to_s} "
      end
      puts
    end
  end
end
