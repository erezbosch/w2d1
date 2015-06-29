require_relative 'tile'
require_relative 'board'

class MinesweeperGame
  def initialize board_size = 9, num_bombs = board_size
    @board = Board.new(board_size, num_bombs)
  end

  def reveal pos
    @board[pos].reveal unless @board[pos].flagged
  end

  def flag pos
    @board[pos].flag
  end

  def run_game
    @board.render
    until @board.over?
      play_turn
    end
    if @board.won?
      puts "You won!"
    else
      puts "You lost!"
    end
  end

  def play_turn
    pos, action = get_move
    action == "f" ? flag(pos) : reveal(pos)
    @board.render
  end

  def get_move
    print "Enter your move, e.g., f,4,5 to flag position (4, 5): "
    move = gets.chomp.split(",")
    [move[1..2].map(&:to_i), move[0]]
  end
end
