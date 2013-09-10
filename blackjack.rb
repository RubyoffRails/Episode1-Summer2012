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
		"#{@value}-#{suit}"
	end
end

class Deck 

	attr_reader :cards

	def initialize
		@cards = Deck.build_cards
	end

	def self.build_cards
		cards = [] #just a local variable
		[:clubs, :spades, :hearts, :diamonds].each do |suit|
		(2..10).each do |number|
			cards << Card.new(suit, number)
		end
		["J", "Q", "Q", "A"].each do |facecard|
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

	def value #calling value method-in card
		cards.inject(0) { |sum, card| sum += card.value }		
	end

	def play_as_dealer(deck)		
		if value < 16
			hit!(deck)
			play_as_dealer(deck)
		end
	end 


    def secret_cards #fix
        cards.each do |card|
        	card == "X"
        	puts "frog"
        end
    end

end

class Game

	attr_reader :player_hand , :dealer_hand

	def initialize
		 @deck = Deck.new
		 @player_hand = Hand.new
		 @dealer_hand = Hand.new
		 2.times { @player_hand.hit!(@deck) }
		 2.times { @dealer_hand.hit!(@deck) }	     
	end

	def hit	 #Tig1.2
			if player_hand.value > 21
				stand
		elsif player_hand.value < 21  
				@player_hand.hit!(@deck)
				standfor 
		elsif player_hand.value == 21
				stand
			end
	end

	def standfor #Tig1.2
		if player_hand.value > 21
			stand
		else
			@player_hand.cards
		end
	end

	def player_status
	  {	:player_card => @player_hand.cards,
		:player_value => @player_hand.value }
	end
	def status
	{
		:player_card => @player_hand.cards,
		:player_value => @player_hand.value,
		:dealer_card => @dealer_hand.cards,
		:dealer_value => @dealer_hand.value,
		:winner => determine_winner(@player_hand.value, @dealer_hand.value)
									}											
	end

	def dealer_status
		@dealer_hand.secret_cards
	end

	def stand
		@dealer_hand.play_as_dealer(@deck)
		determine_winner(@player_hand.value, @dealer_hand.value)
	end	

	def determine_winner(player_value, dealer_value) 
		if player_value > 21
			:dealer
	elsif dealer_value > 21
			:player
	elsif player_value > dealer_value
			:player
	elsif player_value == dealer_value
			:push
		else
			:dealer
	    end
	end		

	def inspect
	status
	end

end

describe Card do

	it "should accept a suit and value" do
	card = Card.new(:clubs, "J")
	card.suit.should eq(:clubs)
	card.value.should eq(10)
    end

    it "should have a value of 10 for facecards" do
    	facecards = ["J", "Q", "K"]
    	facecards.each do |facecard|
    		card = Card.new(:clubs, facecard)
    		card.value.should eq(10)
    	end
    end

    it "should have a value of 4 for 4-clubs" do
    	card = Card.new(:clubs, 4)
    	card.value.should eq(4)
	end

	it "should have a value of 11 for A-diamonds" do
		card = Card.new(:diamonds, "A")
		card.value.should eq(11)
	end

	it "should be formatted correctly" do
		card = Card.new(:diamonds, "A")
		card.to_s.should eq("A-diamonds")
	end
end

describe Deck do

	it "should have 52 cards" do
		Deck.build_cards.length.should eq(52) 
	end

	it "should have 52 cards when new deck" do
		Deck.new.cards.length.should eq(52)
	end
end

describe Hand do

	it "should calculate the value correctly" do
		deck = mock(:deck, :cards => [Card.new(:clubs, 5), Card.new(:diamonds, 10)])
		hand = Hand.new
		2.times { hand.hit!(deck) }   
		hand.value.should eq(15)
	end

	describe "#play_as_dealer" do
		it "should hit below 16" do
			deck = mock(:deck, :cards => [Card.new(:clubs, 4), Card.new(:diamonds, 10), Card.new(:clubs, 2)])
			hand = Hand.new
			hand.play_as_dealer(deck)
			hand.value.should eq(16)
		end
		it "should not hit above " do
			deck = mock(:deck, :cards => [Card.new(:clubs, 8), Card.new(:diamonds, 9)])
			hand = Hand.new
			hand.play_as_dealer(deck)
			hand.value.should eq(17)
		end

		it "should stop on 21" do
			deck = mock(:deck, :cards => [Card.new(:clubs, 4),
						      Card.new(:diamonds, 7),
						      Card.new(:clubs, "K")])
			hand = Hand.new
			hand.play_as_dealer(deck)
			hand.value.should eq(21)
		end 


	end  
end 


describe Game do

	it "should have a player hand" do
		Game.new.player_hand.cards.length.should eq(2)
	end
	it "should have a dealer hand"  do
		Game.new.dealer_hand.cards.length.should eq(2)
	end
	it "should have a status" do
		Game.new.status.should_not be_nil
	end 

	it "should only hit when player hand is not bust"

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
		    Game.new.determine_winner(22,17).should eq(:dealer)
		end
		it "should have player win if dealer busts" do
			Game.new.determine_winner(17,22).should eq(:player)
		end
		it "should have player win if player > dealer" do
			Game.new.determine_winner(17,16).should eq(:player)
	    end
		it "should have push if tie" do
			Game.new.determine_winner(10,10).should eq(:push)
		end
	end

end




