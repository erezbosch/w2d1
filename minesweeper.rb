require_relative 'tile'
require_relative 'board'
require 'yaml'

class MinesweeperGame
  SAVE_FILE = "minesweeper_save.yml"

  def initialize board_size = 9, num_bombs = board_size
    @board = Board.new(board_size, num_bombs)
    @time_played = 0
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
      if prompt_to_save
        save_game
        return
      end
      play_turn
    end
    if @board.won?
      puts "You won! Your time is #{@time_played}!"
    else
      puts "You lost!"
    end
  end

  def play_turn
    clock_start = Time.now
    pos, action = get_move
    action == "f" ? flag(pos) : reveal(pos)
    @time_played += Time.now - clock_start
    @board.render
    puts "Your time...#{@time_played.to_i}\n"
  end

  def get_move
    print "Enter your move, e.g., f,4,5 to flag position (4, 5): "
    move = gets.chomp.split(",")
    [move[1..2].map(&:to_i), move[0]]
  end

  def prompt_to_save
    print "Save and quit? (y/n) "
    gets.chomp.downcase == "y"
  end

  def save_game
    f = File.new(SAVE_FILE, "w")
    f.puts self.to_yaml
    f.close
  end

  def self.play_from_file file_name = SAVE_FILE
    YAML.load_file(file_name).run_game
  end

  def self.determine_play
    MinesweeperGame.new.run_game unless File.exist?(SAVE_FILE)
    print "Would you like to load your game? (y/n) "
    if gets.chomp.downcase == "y"
      MinesweeperGame.play_from_file(SAVE_FILE)
    else
      MinesweeperGame.new.run_game
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  MinesweeperGame.determine_play
end
