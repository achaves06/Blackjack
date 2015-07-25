require 'pry'

def setup_initial_deck(num_decks)
  deck =%w(A 2 3 4 5 6 7 8 9 10 J Q K).product(%w(hearts diamonds clubs spades))
  playable_deck = deck * num_decks
  playable_deck.shuffle!
end

def user_select_total_decks
  puts "How many decks do you want to play with?"
  num_decks = gets.chomp
  while num_decks.to_i.to_s != num_decks
   puts "Please enter a number. How many decks do you want to play with?"
   num_decks = gets.chomp
  end
  num_decks.to_i
end

def deal!(player, playable_deck, cards_dealt)
  card = playable_deck.pop
  cards_dealt << card
  player[:cards] << card
  player = calculate_total(player, card)
end

def calculate_total(player, card)
  card_rank = card[0]
  if card_rank == "A"
    player[:total] <= 10 ? player[:total] += 11 : player[:total] += 1
    player[:ace] += 1
  elsif card_rank == "J" or card_rank == "Q" or card_rank == "K"
    player[:total] += 10
  else
    player[:total] += card_rank.to_i
  end
  return player
end

def show_cards(player)
  puts "\n" + player[:name] + "  - Total: " + player[:total].to_s
  player[:cards].each {|value| puts "  #{value}"}
end

def blackjack(user, dealer)
  if user[:total] == 21 || dealer[:total] == 21
    if dealer[:total] == 21
      show_cards(dealer)
      puts "You both have blackjacks, its' a push" if user[:total] == 21
      puts "Dealer blackjack, you lost..." if user[:total] != 21
    else
      puts "\nBlackjack!! You win!"
    end
    binding.pry
    return true
  else
    return false
  end
end

def find_winner(user,dealer)
  if dealer[:total] <= 21
    puts "\n It's a push" if user[:total] == dealer[:total]
    puts "\n You win!" if user[:total] > dealer[:total]
    puts "\n You lost..." if user[:total] < dealer[:total]
  else
    puts "You win"
  end
end

def if_ace_adjust_total_by_ten(player)
  if player[:ace]== 0
    puts "\n #{player[:name]} busted..."
  elsif player[:ace] >= 1 #convert their ace value from 11 to 1 and lower their ace count
    player[:total] += -10
    player[:ace] += -1
  end
  return player
end

def continue?
  puts "Press any key to continue playing or enter quit to quit"
  gets.chomp != "quit"
end

def reset_counts!(user, dealer)
  user.merge!(total: 0, ace: 0, cards: [])
  dealer.merge!(total: 0, ace: 0, cards: [])
end

def add_cards_dealt_to_deck(cards_dealt,playable_deck)
  playable_deck.unshift(cards_dealt)
  cards_dealt = []
  return cards_dealt, playable_deck
end


#Main game flow

system 'clear'
num_decks = user_select_total_decks
playable_deck = setup_initial_deck(num_decks)
user = {}
puts "Please enter your name"
user[:name] = gets.chomp
dealer = {name: "Computer"}
cards_dealt = []
begin
  system 'clear'
  reset_counts!(user, dealer)
  2.times do
    user = deal!(user,playable_deck,cards_dealt)
    show_cards(user)
    dealer = deal!(dealer,playable_deck,cards_dealt)
    puts dealer[:cards].length < 2 ? "\nComputer: \n  X (covered)" : "\nComputer: \n  X (covered)\n #{dealer[:cards][1]}"
  end
  unless blackjack(user, dealer)
    loop do
      puts "\n Press any key to hit or 's' to stay"
      break if gets.chomp == "s"
      user = deal!(user,playable_deck,cards_dealt)
      show_cards(user)
      user = if_ace_adjust_total_by_ten(user) if user[:total] > 21
      break if user[:total] > 21
    end
    if user[:total] <= 21
      show_cards(dealer)
      while dealer[:total] < 17
        dealer = deal!(dealer,playable_deck,cards_dealt)
        show_cards(dealer)
        dealer = if_ace_adjust_total_by_ten(dealer) if dealer[:total] > 21
      end
      find_winner(user,dealer)
    end
  end
  cards_dealt, playable_deck = add_cards_dealt_to_deck(cards_dealt, playable_deck)
end while continue?
