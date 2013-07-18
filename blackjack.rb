require 'rspec'
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

  def to_s
    "#{@value}#{suit[0].upcase}"
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
    puts "Have other card"
    @dealer_hand.hit!(@deck)
    hit = @player_hand.hit!(@deck)
    return next_move(@player_hand.value) if @player_hand.value >= 21
    return hit
  end

  def format_cards( cards )
    return hide_cards( cards ) if @winner.nil?
    return cards
  end

  def hide_cards( cards )
    hidden_cards = []
    cards.each do | card |
      hidden_cards << "XX"
    end
    hidden_cards
  end

  def next_move( value )
    case value
    when (21)     then stand 
    when (22..52) then stop
    end  
  end

  def stop
    puts "You went over 21, you lost"
    stand
  end

  def stand
    @dealer_hand.play_as_dealer(@deck)
    @winner = determine_winner(@player_hand.value, @dealer_hand.value)
    puts "The winner is #{@winner}"
    @winner
  end

  def status
    {:player_cards => @player_hand.cards, 
     :player_value => @player_hand.value,
     :dealer_cards => format_cards( @dealer_hand.cards ),
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


describe Card do

  it "should accept suit and value when building" do
    card = Card.new(:clubs, 10)
    card.suit.should eq(:clubs)
    card.value.should eq(10)
  end

  it "should have a value of 10 for facecards" do
    facecards = ["J", "Q", "K"]
    facecards.each do |facecard|
      card = Card.new(:hearts, facecard)
      card.value.should eq(10)
    end
  end
  it "should have a value of 4 for the 4-clubs" do
    card = Card.new(:clubs, 4)
    card.value.should eq(4)
  end

  it "should return 11 for Ace" do
    card = Card.new(:diamonds, "A")
    card.value.should eq(11)
  end

  it "should be formatted number first and suit later: 5H" do
    card = Card.new(:hearts, 5)
    card.to_s.should eq("5H")
  end

  it "should be formatted facecard first and suit later QH" do
    card = Card.new(:hearts, 'Q')
    card.to_s.should eq("QH")
  end
end


describe Deck do

  it "should build 52 cards" do
    Deck.build_cards.length.should eq(52)
  end

  it "should have 52 cards when new deck" do
    Deck.new.cards.length.should eq(52)
  end

end


describe Hand do

  it "should calculate the value correctly" do
    deck = mock(:deck, :cards => [Card.new(:clubs, 4), Card.new(:diamonds, 10)])
    hand = Hand.new
    2.times { hand.hit!(deck) }
    hand.value.should eq(14)
  end

  it "should take from the top of the deck" do
    club4 = Card.new(:clubs, 4)
    diamond7 = Card.new(:diamonds, 7) 
    clubK = Card.new(:clubs, "K")

    deck = mock(:deck, :cards => [club4, diamond7, clubK])
    hand = Hand.new
    2.times { hand.hit!(deck) }
    hand.cards.should eq([club4, diamond7])

  end

  describe "#play_as_dealer" do
    it "should hit blow 16" do
      deck = mock(:deck, :cards => [Card.new(:clubs, 4), Card.new(:diamonds, 4), Card.new(:clubs, 2), Card.new(:hearts, 6)])
      hand = Hand.new
      2.times { hand.hit!(deck) }
      hand.play_as_dealer(deck)
      hand.value.should eq(16)
    end
    it "should not hit above" do
      deck = mock(:deck, :cards => [Card.new(:clubs, 8), Card.new(:diamonds, 9)])
      hand = Hand.new
      2.times { hand.hit!(deck) }
      hand.play_as_dealer(deck)
      hand.value.should eq(17)
    end
    it "should stop on 21" do
      deck = mock(:deck, :cards => [Card.new(:clubs, 4), 
                                    Card.new(:diamonds, 7), 
                                    Card.new(:clubs, "K")])
      hand = Hand.new
      2.times { hand.hit!(deck) }
      hand.play_as_dealer(deck)
      hand.value.should eq(21)
    end
  end
end


describe Game do

  it "should have a players hand" do
    Game.new.player_hand.cards.length.should eq(2)
  end
  it "should have a dealers hand" do
    Game.new.dealer_hand.cards.length.should eq(2)
  end
  it "should have a status" do
    Game.new.status.should_not be_nil
  end
  it "should hit when I tell it to" do
    game = Game.new
    game.hit
    game.player_hand.cards.length.should eq(3)
  end

  it "should play the dealer hand when I stand" do
    game = Game.new
    game.stand
    game.status[:winner].should_not be_nil
  end

  describe "#determine_winner" do
    it "should have dealer win when player busts" do
      Game.new.determine_winner(22, 15).should eq(:dealer) 
    end
    it "should player win if dealer busts" do
      Game.new.determine_winner(18, 22).should eq(:player) 
    end
    it "should have player win if player > dealer" do
      Game.new.determine_winner(18, 16).should eq(:player) 
    end
    it "should have push if tie" do
      Game.new.determine_winner(16, 16).should eq(:push) 
    end
  end

  it "should stop if the player goes over 21" do
    game = Game.new
    game.player_hand.stub(:value).and_return(22)
    game.hit
    game.stand.should eq(:dealer)
  end

  it "should hit if the player have less than 21" do
    game = Game.new
    game.player_hand.stub(:value).and_return(15)
    game.hit.length.should eq(3)
  end

  it "should stand if the player or the dealer have 21" do
    game = Game.new
    game.player_hand.stub(:value).and_return(21)
    [:player, :dealer, :push].each do | winner |
      game.hit.should eq(winner) if game.hit == winner 
    end
  end

  it "should hide the dealer cards" do
    game = Game.new
    game.hide_cards( game.dealer_hand.cards )
    game.status[:dealer_cards].each do | card |
      card.should eq("XX")
    end
  end

  it "should hide the dealer cards until the player has stood" do
    game = Game.new
    game.stand
    game.status[:dealer_cards].each do | card |
      card.should_not eq("XX")
    end    
  end
end