class Game
  def initialize(word = '', strikes = 0, incorrect_guesses = [], curr_state = [])
    @word = word
    @strikes = strikes
    @incorrect_guesses = incorrect_guesses
    @curr_state = curr_state
  end

  attr_accessor :word, :strikes, :incorrect_guesses, :curr_state
end

def start_game
  words = File.open('words.txt')
  word_bank = words.readlines.map(&:chomp)
  word_bank = word_bank.select { |word| word.length >= 5 && word.length <= 12 }
  word_bank[rand(1...word_bank.length)]
end

def save(game)
  File.open('game', 'w+') do |f|
    Marshal.dump(game, f)
  end
end

def load
  File.open('game') do |f|
    @game = Marshal.load(f)
  end
  @game
end

def check_word(input, word, curr_state)
  count = 0
  word.each_index do |i|
    if word[i] == input
      curr_state[i] = input
      count += 1
    end
  end
  count
end

def display_feedback(count, guess, curr_state)
  puts "\nThere are #{count} #{guess}'s in the word"
  puts "\n#{curr_state.join}"
end

game = Game.new
game.word = start_game.split('')
print game.word
game.curr_state = Array.new(game.word.length, ' _ ')
print "\nWelcome to Hangman! You have 6 strikes to guess the word. Do you want to load a game? (Y or N) "
selection = gets.chomp.downcase
if selection == 'y'
  game = load
  print "\nWelcome back. The current state of your game is
  \n#{game.curr_state.join} \n\nYou have already incorrectly guessed #{game.incorrect_guesses}\nYou have #{game.strikes} strike(s).
  \nEnter your next guess "
  guess = gets.chomp.downcase
  guess = guess[0]
elsif selection == 'n'
  print "There are #{game.word.length} letters in the word. Enter your first guess. "
  guess = gets.chomp.downcase
  guess = guess[0]
end

while game.strikes < 5
  count = check_word(guess, game.word, game.curr_state)
  if count.zero?
    game.strikes += 1
    game.incorrect_guesses.append(guess)
  end
  display_feedback(count, guess, game.curr_state)
  if game.curr_state == game.word
    puts 'Congratulations. You win!'
    break
  end
  puts "\nYou have already incorrectly guessed #{game.incorrect_guesses}"
  print "\nYou have #{game.strikes} strike(s). Do you want to save (1) or guess again (2)? "
  option = gets.chomp
  if option == '1'
    save(game)
    puts 'Game saved!'
    break
  elsif option == '2'
    print "\nEnter your next guess "
    guess = gets.chomp.downcase
  end
end

puts 'Sorry, you lose!' if game.strikes == 5
