# frozen_string_literal: true

# Game class - display instructions and launch the game
class Game
  attr_reader :colors
  attr_reader :code

  def initialize
    @colors = %w[red green blue yellow brown orange black white]
  end

  def play
    # Display the instructions
    instructions

    # Determine who is playing
    puts
    puts 'Do you want to do the guessing (y/n)'
    answer = gets.chomp.downcase
    player = if answer == 'y'
               'person'
             else
               'computer'
             end

    # Play the game
    if player == 'person'
      @code = makecode
      person_play
    else
      @code = getcode
      computer_play
    end
  end

  def instructions
    puts
    puts 'Mastermind'
    puts '----------'
    puts
    puts 'The secret code consists of four coloured pegs.'
    puts
    puts 'Possible colours are red, green, blue, yellow, brown, orange, black and white.'
    puts 'Each colour can occur only once.'
    puts
    puts 'To make a guess the player enters a list of four colours separated by spaces.'
    puts
    puts 'The computer will tell you how many are correct (position and colour) and how'
    puts 'many are close (correct colour in the wrong position).'
    puts
    puts 'The player gets 12 guesses! Good luck!'
    puts
  end

  def makecode
    # Make up a random code for the player to guess
    code1 = rand(8)
    code2 = 0
    code3 = 0
    code4 = 0
    loop do
      code2 = rand(8)
      break if code2 != code1
    end
    loop do
      code3 = rand(8)
      break if code3 != code1 && code3 != code2
    end
    loop do
      code4 = rand(8)
      break if code4 != code3 && code4 != code2 && code4 != code1
    end
    "#{code1}#{code2}#{code3}#{code4}"
  end

  def getcode
    # Get the player to enter a code for the computer to guess
    puts
    puts 'Ok! Enter a secret code for the computer to guess:'
    code_array = []
    unique_array = []
    loop do
      input = gets.chomp.downcase.split(' ')
      code_array = input.map { |color| colors.index(color) }
      unique_array = code_array.uniq
      break unless (code_array.include? nil) || (unique_array.length != code_array.length) || code_array.empty?

      puts 'Invalid input. Enter 4 of the above colours with spaces between. Use each colour only once.'
    end
    puts
    code_array.join('')
  end

  def person_play
    # Play the game with the player making the guesses
    go = 0
    guess = ''

    loop do
      go += 1
      puts "(#{go}) Enter your guess:"

      loop do
        input = gets.chomp.downcase.split(' ')
        guess_array = input.map { |color| colors.index(color) }
        guess = guess_array.join('')
        break unless guess_array.include? nil

        puts 'Invalid input. Enter 4 of the above colours with spaces between.'
      end

      if guess == code
        puts
        puts 'That is correct! Game over!'
        puts
        break
      end

      puts
      match = 0
      close = 0

      (0..3).each do |i|
        if guess[i] == code[i]
          match += 1
        elsif code.include?(guess[i].to_s)
          close += 1
        end
      end

      puts "Not quite. #{match} match exactly. #{close} close."
      puts

      if go == 12
        puts
        puts 'You are out of guesses! Game over!'
        puts "The code was: #{colors[code[0].to_i]} #{colors[code[1].to_i]} #{colors[code[2].to_i]} #{colors[code[3].to_i]}"
        puts
        break
      end
    end
  end

  def computer_play
    # Play the game with the computer making the guesses
    guess = ''
    go = 0
    def_in = []
    def_out = []
    mode = ''
    i0 = 0
    i1 = 0
    i2 = 0
    i3 = 0
    not0 = []
    not1 = []
    not2 = []
    not3 = []

    loop do
      go += 1

      # Determine colours in the code by testing all with same colour
      if def_in.length < 4
        mode = 'find_col'
        loop do
          rand_code = rand(8)
          unless def_in.include? rand_code
            unless def_out.include? rand_code
              guess = "#{rand_code}#{rand_code}#{rand_code}#{rand_code}"
              break
            end
          end
        end

      else

        # Now guess the positions, taking account of previous guesses that indicate where colour can't be
        mode = 'find_loc'

        loop do
          i0 = rand(4)
          break unless not0.include? def_in[i0]
        end

        loop do
          i1 = rand(4)
          break unless i1 == i0 || (not1.include? def_in[i1])
        end

        loop do
          i2 = rand(4)
          break unless i2 == i0 || i2 == i1 || (not2.include? def_in[i2])
        end

        loop do
          i3 = rand(4)
          break unless i3 == i0 || i3 == i1 || i3 == i2
        end

        guess = "#{def_in[i0]}#{def_in[i1]}#{def_in[i2]}#{def_in[i3]}"

      end

      puts "#{go} My guess is: #{colors[guess[0].to_i]} #{colors[guess[1].to_i]} #{colors[guess[2].to_i]} #{colors[guess[3].to_i]}"
      puts

      if guess == code
        puts
        puts 'That is correct! Game over!'
        puts
        break
      end

      match = 0
      close = 0

      (0..3).each do |i|
        if guess[i] == code[i]
          match += 1
        elsif code.include?(guess[i].to_s)
          close += 1
        end
      end

      # If in find_col mode and match found, add to definite in
      def_in.push guess[1].to_i if mode == 'find_col' && match != 0

      # If in find_col mode and no match, add to definite out
      def_out.push guess[1].to_i if mode == 'find_col' && match.zero?

      # If have 4 definite outs, missing ones must be in
      if def_out.length == 4 && def_in.length < 4
        (0..7).each do |i|
          def_in.push i unless (def_in.include? i) || (def_out.include? i)
        end
      end

      # If have 4 definite ins, missing ones must be out
      if def_in.length == 4 && def_out.length < 4
        (0..7).each do |i|
          def_out.push i unless (def_in.include? i) || (def_out.include? i)
        end
      end

      # If in find_loc mode and no matches, record positions that are definite wrong
      if mode == 'find_loc' && close == 4
        not0.push guess[0].to_i unless not0.include? guess[0].to_i
        not1.push guess[1].to_i unless not1.include? guess[1].to_i
        not2.push guess[2].to_i unless not2.include? guess[2].to_i
        not3.push guess[3].to_i unless not3.include? guess[3].to_i
      end

      puts "Not quite. #{match} match exactly. #{close} close."
      puts

      if go == 20
        puts
        puts 'Out of guesses! Game over!'
        puts "The code was: #{colors[code[0].to_i]} #{colors[code[1].to_i]} #{colors[code[2].to_i]} #{colors[code[3].to_i]}"
        puts
        break
      end

    end

  end

end
