Episode1 Summer 2012- BlackJack
=====================

A Casino game. No gambling, just skill!

Panda Level
-----------

1. Play the game by running this code:

```
irb
require "./blackjack"
game = Game.new
game.hit
game.stand
```

2. Change the Card's to_s to show "D5" instead of "5-diamonds"


Tiger Level
-----------

1. Complete the Panda assignment
2. If a player busts (goes over 21), the game should #standfor the player


Eagle Level
------------

1. The dealer hand should not not show both cards until the player has stood (It should be like "XX", "Q5")

Copyright: Jesse Wolgamott, MIT License (See LICENSE)
