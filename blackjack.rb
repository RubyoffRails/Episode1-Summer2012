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
    "#{@value}#{suit.to_s.chr.capitalize}"
  end

  # def inspect
  #   "#{@value}#{suit.to_s.chr.capitalize}"
  # end

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

  def play_as_dealer(deck,player_value)
    if value < 16 || value < player_value
      hit!(deck)
      play_as_dealer(deck,player_value)
    end
  end
end

class Game
  attr_reader :player_hand, :dealer_hand, :deck
  def initialize
    @deck = Deck.new
    @player_hand = Hand.new
    @dealer_hand = Hand.new
    2.times { @player_hand.hit!(@deck) } 
    2.times { @dealer_hand.hit!(@deck) }
  end

  def show(hand,all)
    str_cards = ""
    if all == true
      hand.cards.each { |card| str_cards += "#{card.to_s} " }
    else
      str_cards += "XX #{hand.cards[1].to_s}"
    end
    str_cards 
  end

  def hit
    @player_hand.hit!(@deck)
    @player_hand.value > 21 ? stand  : "Player: #{show(@player_hand,true)} value: #{@player_hand.value}"
  end

  def stand
    if @player_hand.value > 21
      @winner = determine_winner(@player_hand.value, @dealer_hand.value)
    else
      @dealer_hand.play_as_dealer(@deck,@player_hand.value)
      @winner = determine_winner(@player_hand.value, @dealer_hand.value)
    end
  end

  def status
    {:player_cards=> @player_hand.cards, 
     :player_value => @player_hand.value,
     :dealer_cards => @dealer_hand.cards,
     :dealer_value => @dealer_hand.value,
     :winner => @winner}
  end

  def determine_winner(player_value, dealer_value)
    return "Dealer Won! Player: #{show(@player_hand,true)} value: #{@player_hand.value}, Dealer: #{show(@dealer_hand,true)} value: #{@dealer_hand.value}" if player_value > 21
    return "Player Won! Player: #{show(@player_hand,true)} value: #{@player_hand.value}, Dealer: #{show(@dealer_hand,true)} value: #{@dealer_hand.value}" if dealer_value > 21
    if player_value == dealer_value
      "Push Player: #{show(@player_hand,true)} value: #{@player_hand.value}, Dealer: #{show(@dealer_hand,true)} value: #{@dealer_hand.value}"
    elsif player_value > dealer_value
      "Player Won! Player: #{show(@player_hand,true)} value: #{@player_hand.value}, Dealer: #{show(@dealer_hand,true)} value: #{@dealer_hand.value}"
    else
      "Dealer Won! Player: #{show(@player_hand,true)} value: #{@player_hand.value}, Dealer: #{show(@dealer_hand,true)} value: #{@dealer_hand.value}"
    end
  end

  def inspect
    "Player: #{show(@player_hand,true)} value: #{@player_hand.value}, Dealer: #{show(@dealer_hand,false)} value: #{@dealer_hand.cards[1].value}"
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

  it "should be formatted nicely" do
    card = Card.new(:diamonds, "A")
    card.to_s.should eq("AD")
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
    deck = double(:deck, :cards => [Card.new(:clubs, 4), Card.new(:diamonds, 10)])
    hand = Hand.new
    2.times { hand.hit!(deck) }
    hand.value.should eq(14)
  end

  it "should take from the top of the deck" do
    club4 = Card.new(:clubs, 4)
    diamond7 = Card.new(:diamonds, 7) 
    clubK = Card.new(:clubs, "K")

    deck = double(:deck, :cards => [club4, diamond7, clubK])
    hand = Hand.new
    2.times { hand.hit!(deck) }
    hand.cards.should eq([club4, diamond7])

  end

  describe "#play_as_dealer" do
    it "should hit below 16" do
      deck = double(:deck, :cards => [Card.new(:clubs, 4), Card.new(:diamonds, 4), Card.new(:clubs, 2), Card.new(:hearts, 6)])
      hand = Hand.new
      player_value = 16
      2.times { hand.hit!(deck) }
      hand.play_as_dealer(deck,player_value)
      hand.value.should eq(16)
    end
    it "should not hit above player value" do
      deck = double(:deck, :cards => [Card.new(:clubs, 8), 
                                      Card.new(:diamonds, 9),
                                      Card.new(:hearts, 2)])
      hand = Hand.new
      player_value = 17
      2.times { hand.hit!(deck) }
      hand.play_as_dealer(deck,player_value)
      hand.value.should eq(17)
    end
    it "should stop on 21" do
      deck = double(:deck, :cards => [Card.new(:clubs, 4), 
                                    Card.new(:diamonds, 7), 
                                    Card.new(:clubs, "K")])
      hand = Hand.new
      2.times { hand.hit!(deck) }
      player_value = 20
      hand.play_as_dealer(deck,player_value)
      hand.value.should eq(21)
    end
    it "should hit below player value" do
      deck = double(:deck, :cards => [Card.new(:clubs, 8), 
                                      Card.new(:diamonds, 8),
                                      Card.new(:spades, 2),
                                      Card.new(:hearts, 4)])
      hand = Hand.new
      player_value = 17
      2.times { hand.hit!(deck) }
      hand.play_as_dealer(deck,player_value)
      hand.value.should eq(18)
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

  it "should stand if player value is greater than 21" do
    game = Game.new
    next_player_value = game.player_hand.value + game.deck.cards[0].value
    while next_player_value <=21
      game.hit
      next_player_value = game.player_hand.value + game.deck.cards[0].value
    end
    expect(game.hit[0...6]).to eq("Dealer")
  end

  describe "#show" do

    it "should show the players hand" do
      game = Game.new
      player_cards = game.player_hand.cards
      str_cards = ""
      player_cards.each {|card| str_cards += "#{card.to_s} " }
      expect(game.show(game.player_hand,true)).to eq(str_cards)
    end

    it "should show the dealers first card until stand" do
      game = Game.new
      dealer_cards = game.dealer_hand.cards
      expect(game.show(game.dealer_hand,false)).to eq("XX #{dealer_cards[1].to_s}")
    end

    it "should show the players cards and dealers cards on stand" do
      game = Game.new
      result = game.stand
      if game.dealer_hand.value > 21
        expect(result).to eq("Player Won! Player: #{game.show(game.player_hand,true)} value: #{game.player_hand.value}, Dealer: #{game.show(game.dealer_hand,true)} value: #{game.dealer_hand.value}")   
      elsif game.player_hand.value > game.dealer_hand.value
        expect(result).to eq("Player Won! Player: #{game.show(game.player_hand,true)} value: #{game.player_hand.value}, Dealer: #{game.show(game.dealer_hand,true)} value: #{game.dealer_hand.value}")   
      elsif game.player_hand.value == game.dealer_hand.value
        expect(result).to eq("Push Player: #{game.show(game.player_hand,true)} value: #{game.player_hand.value}, Dealer: #{game.show(game.dealer_hand,true)} value: #{game.dealer_hand.value}")   
      else
        expect(result).to eq("Dealer Won! Player: #{game.show(game.player_hand,true)} value: #{game.player_hand.value}, Dealer: #{game.show(game.dealer_hand,true)} value: #{game.dealer_hand.value}")   
      end
    end

    it "should show the players cards on hit" do
      game = Game.new
      result = game.hit
      if game.player_hand.value > 21
        expect(result).to eq("Dealer Won! Player: #{game.show(game.player_hand,true)} value: #{game.player_hand.value}, Dealer: #{game.show(game.dealer_hand,true)} value: #{game.dealer_hand.value}")   
      else
        expect(result).to eq("Player: #{game.show(game.player_hand,true)} value: #{game.player_hand.value}")
      end
    end
  end

  describe "#determine_winner" do
    it "should have dealer win when player busts" do
      Game.new.determine_winner(22, 15)[0...6].should eq("Dealer") 
    end
    it "should player win if dealer busts" do
      Game.new.determine_winner(18, 22)[0...6].should eq("Player") 
    end
    it "should have player win if player > dealer" do
      Game.new.determine_winner(18, 16)[0...6].should eq("Player") 
    end
    it "should have push if tie" do
      Game.new.determine_winner(16, 16)[0...4].should eq("Push") 
    end
  end
end
