require_relative 'tile'
require_relative 'board'
require 'yaml'
require 'io/console'

class MinesweeperGame
  SAVE_FILE = "minesweeper_save.yml"
  BEST_TIMES = "minesweeper_high_scores"
  LEVELS = [[9, 9], [12, 20], [16, 40]]

  def initialize board_size = 9, num_bombs = board_size
    @board = Board.new(board_size, num_bombs)
    @board_size = board_size
    @time_played = 0
    @cursor = [board_size / 2, board_size / 2]
  end

  def run_game
    render_board

    until @board.over?
      turn = play_turn
      return unless turn # user pressed shift-S => quit the game
    end

    render_board(false)

    if @board.won?
      actions_on_win
    else
      puts "You lost!"
    end
  end

  def self.play_from_file file_name = SAVE_FILE
    YAML.load_file(file_name).run_game
  end

  def self.determine_play
    MinesweeperGame.new.run_game unless File.exist?(SAVE_FILE)

    print "Enter 'l' to load a saved game, 'v' to view high scores, or"
    print " just press enter to play: "
    case gets.chomp.downcase
    when "l"
      MinesweeperGame.play_from_file(SAVE_FILE)
    when "v"
      MinesweeperGame.display_leaderboards
      MinesweeperGame.determine_play
    else
      print "Enter e, m, or h to indicate your preferred difficulty level: "

      case gets.chomp.downcase
      when "m"
        size, bombs = LEVELS[1]
      when "h"
        size, bombs = LEVELS[2]
      else
        size, bombs = LEVELS[0]
      end
      MinesweeperGame.new(size, bombs).run_game
    end
  end


  def render_board show_cursor = true
    @board.render(@cursor, show_cursor)
    puts "Your time is #{@time_played.to_i.to_s} seconds."
  end

  def reveal pos
    @board[pos].flagged ? @board[pos].flag : @board[pos].reveal
  end

  def flag pos
    @board[pos].flag
  end

  def save_game
    puts "Game saved."
    f = File.new(SAVE_FILE, "w")
    f.puts self.to_yaml
    f.close
  end

  private

  def play_turn
    move = get_move
    return false unless move # if get_move returns false, tell run_game to quit

    pos, action = move
    action == "f" ? flag(pos) : reveal(pos)
    render_board
    true
  end

  def get_move
    move = nil

    until move
      clock_start = Time.now

      char = self.class.get_char

      case char
      when "i" || "t"
        @cursor[0] -= 1 unless @cursor[0] < 1
      when "j" || "f"
        @cursor[1] -= 1 unless @cursor[1] < 1
      when "k" || "g"
        @cursor[0] += 1 unless @cursor[0] > @board_size - 2
      when "l" || "h"
        @cursor[1] += 1 unless @cursor[1] > @board_size - 2
      when " "
        move = [@cursor, "r"]
      when "f"
        move = [@cursor, "f"]
      when "S"
        save_game
        return false # indicates that the game should end
      end

      @time_played += Time.now - clock_start

      render_board
    end

    move
  end

  def actions_on_win
    puts "You won! It only took you #{@time_played.to_i.to_s} seconds!"

    high_scores_file = "#{BEST_TIMES + @board_size.to_s}.yml"

    unless File.exist?(high_scores_file)
      self.class.create_scores_file(high_scores_file)
    end

    high_scores = YAML.load_file(high_scores_file)

    10.times do |score_idx|
      if @time_played.to_i < high_scores[score_idx]
        puts "Your time is the new \##{score_idx + 1} score!"
        break
      end
    end

    high_scores = (high_scores << @time_played.to_i).sort[0..9]

    f = File.new(high_scores_file, "w")
    f.puts high_scores.to_yaml
    f.close
  end

  def self.get_char
    state = `stty -g`
    `stty raw -echo -icanon isig`

    STDIN.getc.chr
  ensure
    `stty #{state}`
  end

  def self.create_scores_file(file_name)
    f = File.new(file_name, "w")
    f.puts Array.new(10, 9999).to_yaml
    f.close
  end

  def self.display_leaderboards
    system "clear"

    LEVELS.each_with_index do |level, idx|
      high_scores_file = "#{BEST_TIMES + level[0].to_s}.yml"

      unless File.exist?(high_scores_file)
        MinesweeperGame.create_scores_file(high_scores_file)
      end

      puts "Best Times (#{MinesweeperGame.level_to_word(idx)})"
      puts YAML.load_file(high_scores_file)
      puts
    end
  end

  def self.level_to_word level_number
    case level_number
    when 0
      "Easy"
    when 1
      "Medium"
    when 2
      "Hard"
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  MinesweeperGame.determine_play
end
