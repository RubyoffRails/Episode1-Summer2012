class Card

  attr_reader :suit, :value
  def initialize(suit, value)
    @suit = suit
    @value = value
  end

  def value
    return 10 if ["J", "Q", "K"].include?(@value)
    return 11 if @value == "A"
    return @value
  end

  def suit
    @suit[0].capitalize
  end

  def to_s
    "#{@value}#{suit}"
  end

end


class Deck
  attr_reader :cards

  def initialize
    @cards = Deck.build_cards
  end

  def self.build_cards
    cards = []
    [:clubs, :diamonds, :spades, :hearts].each do |suit|
      (2..10).each do |number|
        cards << Card.new(suit, number)
      end
      ["J", "Q", "K", "A"].each do |facecard|
        cards << Card.new(suit, facecard)
      end
    end
    cards.shuffle
  end
end

class Hand
  attr_reader :cards

  def initialize
    @cards = []
  end
  def hit!(deck)
    @cards << deck.cards.shift
  end

  def value
    cards.inject(0) {|sum, card| sum += card.value }
  end

  def play_as_dealer(deck)
    if value < 16
      hit!(deck)
      play_as_dealer(deck)
    end
  end
end

class Game
  attr_reader :player_hand, :dealer_hand
  def initialize
    @deck = Deck.new
    @player_hand = Hand.new
    @dealer_hand = Hand.new
    2.times { @player_hand.hit!(@deck) } 
    2.times { @dealer_hand.hit!(@deck) }
  end

  def hit
    @player_hand.hit!(@deck)

    if @player_hand.value > 21
      stand
    end
  end

  def stand
    @dealer_hand.play_as_dealer(@deck)
    @winner = determine_winner(@player_hand.value, @dealer_hand.value)
  end

  def status
    {:player_cards=> @player_hand.cards, 
     :player_value => @player_hand.value,
     :dealer_cards => @dealer_hand.cards,
     :dealer_value => @dealer_hand.value,
     :winner => @winner}
  end

  def determine_winner(player_value, dealer_value)
    return :dealer if player_value > 21
    return :player if dealer_value > 21
    if player_value == dealer_value
      :push
    elsif player_value > dealer_value
      :player
    else
      :dealer
    end
  end

  def inspect
    status
  end
end


