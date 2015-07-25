require 'pry'

module Hand
  def adjust_ace_to_one
    if ace >= 1 #convert their ace value from 11 to 1 and lower their ace count
      self.total += -10
      self.ace += -1
    end
  end

  def calculate_total
    card_rank = cards.last[0]
    if card_rank == "A"
      total <= 10 ? self.total += 11 : self.total += 1
      self.ace += 1
    elsif card_rank == "J" or card_rank == "Q" or card_rank == "K"
      self.total += 10
    else
      self.total += card_rank.to_i
    end
  end
end

class Deck
  attr_accessor :card, :cards_dealt, :playable_deck
  SINGLE_DECK = %w(A 2 3 4 5 6 7 8 9 10 J Q K).product(%w(hearts diamonds clubs spades))

  def initialize
    @playable_deck = setup_deck(num_decks)
    @cards_dealt = []
  end

  def num_decks
    puts "How many decks do you want to play with?"
    num_decks = gets.chomp
    while num_decks.to_i.to_s != num_decks
     puts "Please enter a number. How many decks do you want to play with?"
     num_decks = gets.chomp
    end
    num_decks.to_i
  end

  def setup_deck(num_decks)
    (SINGLE_DECK * num_decks).shuffle!
  end

  def deal(player)
    self.card = playable_deck.pop
    self.cards_dealt << card
    player.cards << card
  end

  def add_cards_dealt_to_deck
    self.playable_deck.unshift(cards_dealt)
    self.cards_dealt = []
  end

end

class Player
  attr_accessor :cards, :total, :ace, :name

  include Hand

  def initialize
    @name = get_name
    @cards = []
    @total = 0
    @ace = 0
  end

  def get_name
    puts "Please enter your name"
    gets.chomp
  end


end

class Dealer
  attr_accessor :cards, :total, :ace, :name
  include Hand

  def initialize
    @name = "Dealer"
  end

end

#Main game flow

class Game
  attr_accessor :player, :dealer
  def initialize
    system 'clear'
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def reset_counts(player)
    player.total= 0
    player.ace = 0
    player.cards= []
  end

  def show_cards(player)
    puts "\n" + player.name + "  - Total: " + player.total.to_s
    player.cards.each {|value| puts "  #{value}"}
  end

  def blackjack
    if player.total == 21 || dealer.total == 21
      if dealer.total == 21
        show_cards(dealer)
        puts "\nYou both have blackjacks, its' a push" if player.total == 21
        puts "\nDealer blackjack, you lost..." if player.total != 21
      else
        puts "\nBlackjack!! You win!"
      end
      return true
    else
      return false
    end
  end

  def find_winner
    if @dealer.total <= 21
      puts "\n It's a push" if @player.total == @dealer.total
      puts "\n You win!" if @player.total > @dealer.total
      puts "\n You lost..." if @player.total < @dealer.total
    else
      puts "You win"
    end
  end

  def continue?
    puts "Press any key to continue playing or enter quit to quit"
    gets.chomp != "quit"
  end


  def run
    begin
      system 'clear'
      reset_counts(@player)
      reset_counts(@dealer)
      2.times do
        @deck.deal(@player)
        @player.calculate_total
        show_cards(@player)
        @deck.deal(@dealer)
        @dealer.calculate_total
        if @dealer.cards.length < 2
          puts "\nComputer: \n  X (covered)"
        else
          puts "\nComputer: \n  X (covered)\n #{@dealer.cards[1]}"
        end
      end
      unless blackjack
        loop do
          puts "\n Press any key to hit or 's' to stay"
          break if gets.chomp == "s"
          @deck.deal(@player)
          @player.calculate_total
          if @player.total > 21
            @player.adjust_ace_to_one
          end
          show_cards(@player)
          if @player.total > 21
            puts "\n #{@player.name} busted..." if @player.total >21
            break
          end
        end
        if @player.total <= 21
          show_cards(@dealer)
          while @dealer.total < 17
            @deck.deal(@dealer)
            @dealer.calculate_total
            if @dealer.total > 21
              @dealer.adjust_ace_to_one
            end
            show_cards(@dealer)
            if @dealer.total > 21
              puts "\n #{@dealer.name} busted..." if @dealer.total >21
              break
            end
          end
          puts "\n\n#{@player.name}: #{@player.total} -- #{@dealer.name}: #{@dealer.total}"
          find_winner
        end
        @deck.add_cards_dealt_to_deck
      end
    end while continue?
  end
end

Game.new.run
