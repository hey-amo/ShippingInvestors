# ShippingMerchants

A card game where players invest, load ships at port whilst maintaining balance.

Players act as investors and load cargo onto 4 ships (3 at first) and try to get a payout before the ship sails.

Players have to balance loading ships, investing as well as making sure ships remain balanced.

--

6 Cargo types:
- Red, Yellow, Green, Blue, White, Purple
- Cargo has weight (tonnage) (2-6)
- Some cargo cards might clone the last played card's weight and cannot be played by itself.

Ships have:
- Card capacity
- Tonnage (weight capacity)
- Time cubes (time remaining at port)
- Left cargo hold (of cargo cards)
- Right cargo hold (of cargo cards)
- Destinations
- Balance Indicator
- Tolerance - The range in which the ship is balanced
- Destinations - A set of non-repeating destinations

When a player loads cargo cards onto a ship they must be:
- the same colour 
- min 1 card, max 3 cards.  Players pay to load cards onto ships
- the player chooses to load the `left cargo hold`, or `right cargo hold` of the ship, this will affect the balance

--

Language: Swift, SwiftUI
Backend: SwiftData
Uses Swift package