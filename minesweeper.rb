require_relative 'tile'
require_relative 'board'
require 'yaml'
require 'io/console'

class MinesweeperGame
  SAVE_FILE = "minesweeper_save.yml"
  BEST_TIMES = "minesweeper_high_scores.yml"

  def initialize board_size = 9, num_bombs = board_size
    @board = Board.new(board_size, num_bombs)
    @board_size = board_size
    @time_played = 0
    @cursor = [board_size / 2, board_size / 2]
  end

  def reveal pos
    @board[pos].reveal unless @board[pos].flagged
  end

  def flag pos
    @board[pos].flag
  end

  def render_board_with_cursor
    @board.render_with_cursor(@cursor)
    puts "Your time is #{@time_played.to_i.to_s}"
  end


  def run_game
    render_board_with_cursor

    until @board.over?
      turn = play_turn
      return unless turn
    end

    if @board.won?
      puts "You won! Your time was #{@time_played.to_i.to_s}!"
      high_scores = YAML.load_file(BEST_TIMES)
      (0..9).each do |score_idx|
        if @time_played.to_i < high_scores[score_idx]
          puts "Your time is the new \##{score_idx + 1} score!"
          break
        end
      end
      
      high_scores = (high_scores << @time_played.to_i).sort[0..9]
      f = File.new(BEST_TIMES, "w")
      f.puts high_scores.to_yaml
      f.close
    else
      puts "You lost!"
    end
  end

  def play_turn
    move = get_move
    return false unless move

    pos, action = move
    action == "f" ? flag(pos) : reveal(pos)
    render_board_with_cursor
    true
  end

  def get_move
    move = nil

    until move
      clock_start = Time.now

      char = get_char

      case char
      when "i"
        @cursor[0] -= 1 unless @cursor[0] < 1
      when "j"
        @cursor[1] -= 1 unless @cursor[1] < 1
      when "k"
        @cursor[0] += 1 unless @cursor[0] > @board_size - 2
      when "l"
        @cursor[1] += 1 unless @cursor[1] > @board_size - 2
      when " "
        move = [@cursor, "r"]
      when "f"
        move = [@cursor, "f"]
      when "S"
        save_game
        return false
      end

      @time_played += Time.now - clock_start

      render_board_with_cursor
    end

    move
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
      print "Enter e, m, or h to indicate your preferred difficulty level: "
      MinesweeperGame.new.run_game
    end
  end

  def get_char
    state = `stty -g`
    `stty raw -echo -icanon isig`

    STDIN.getc.chr
  ensure
    `stty #{state}`
  end
end

if __FILE__ == $PROGRAM_NAME
  MinesweeperGame.determine_play
end
