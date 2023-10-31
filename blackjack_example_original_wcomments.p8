-- blackjack
-- by tlm

-- sprite indices of suits
-- (helper variables)
hearts = 2
diamonds = 3
spades = 4
clubs = 5

-- shuffle the deck and init
-- global vars:
function initdeck()
  deck = {}  -- initialize an empty deck as a table.
  idx = 1  -- initialize an index variable for tracking cards.

  for i = hearts, clubs do  -- loop through the suits (hearts, diamonds, spades, clubs).
    for j = 1, 13 do  -- loop through the card values (1 to 13).
      deck[idx] = {v = j, t = i}  -- assign a card with value (v) and suit (t) to the deck.
      idx = idx + 1  -- increment the index.
    end
  end

  for i = 52, 2, -1 do  -- shuffle the deck by swapping card positions.
    j = flr(rnd(i) + 1)  -- randomly select an index (j).
    t = deck[i]  -- temporary storage for card at index i.
    deck[i] = deck[j]  -- swap cards at indices i and j.
    deck[j] = t  -- place the stored card back in its new position.
  end

  playerhand = {}  -- initialize the player's hand as an empty table.
  dealerhand = {}  -- initialize the dealer's hand as an empty table.
  playerturn = true  -- set the player's turn to true.
end

-- display starting message
function _init()
  helpdisplay = false  -- initialize the help display as false.
  gameover = false  -- initialize the game over state as false.
  cls()  -- clear the screen.
  print("press 🅾️ (z) to start", 20, 54)  -- display the start message.
  print("instructions available in\npause menu (p by default)", 10, 64)  -- display instructions.
  while not btn(4) do end  -- wait for the player to press button 4 (🅾️/z).
  pal(1, 0)  -- set color palette.
  initdeck()  -- initialize the deck.
  menuitem(1, "instructions", function() helpdisplay = true end)  -- create a menu item for instructions.
end

-- draw a card (on screen):
function draw_card(x, y, v, t, d)
  v = v + 5  -- adjust card value to match pico-8 sprite indices.

  if (not d) y += 88/8  -- if the card is not face down, adjust the y-coordinate.

  if (t < 4) v = v + 17  -- adjust the value further for different suits.

  if not d or gameover then
    rectfill(x*8, y*8, (x+2)*8, (y+2)*8, 7)  -- draw a card outline.
    spr(v, (x+1)*8, (y+1)*8)  -- draw the card's value.
    spr(t, x*8, y*8)  -- draw the card's suit symbol.
  elseif d and not gameover then
    sspr(32, 16, 8, 8, x*8, y*8, 2*8, 2*8)  -- draw the card face down.
  end
end

-- draw a hand of cards:
function draw_hand(h, d)
  x = 0
  y = 0

  for card in all(h) do
    draw_card(x*2, y, card.v, card.t, d)  -- draw each card in the hand.
    x += 1
    if x > 7 then
      x = 0
      y += 3
    end
  end
end

-- draw a card (from deck):
function deal()
  sfx(0)  -- play a sound effect.
  card = deck[#deck]  -- get the last card from the deck.
  deck[#deck] = nil  -- remove the dealt card from the deck.
  return card  -- return the dealt card.
end

-- count points in hand:
function points(hand)
  p = 0  -- initialize the total points.
  aces = 0  -- initialize the count of aces.

  for card in all(hand) do
    v = card.v  -- get the card's value.

    if (v > 10) v = 10  -- if the value is greater than 10, set it to 10.

    if v == 1 then
      v = 0  -- aces initially count as 0.
      aces += 1  -- increment the count of aces.
    end

    p += v  -- add the adjusted value to the total points.
  end

  while aces > 0 do
    if p + 11 > 21 then
      p += 1  -- if adding 11 would cause a bust, count the ace as 1.
    else
      p += 11  -- otherwise, count the ace as 11.
    end
    aces -= 1  -- reduce the count of aces.
  end

  return p  -- return the total points.
end

-- game logic here.
-- check win/loss,
-- ask the player to
-- hit or stand,
-- make the dealer do the same.
function _update()
  if helpdisplay then
    if (btnp(4)) helpdisplay = false  -- exit help display with button 4.
    return
  end

  if gameover then
    if (btnp(4)) _init()  -- restart the game with button 4.
    return
  end

  if points(playerhand) > 21 then
    gameover = "lose"  -- player loses if their points exceed 21.
  elseif points(dealerhand) > 21 then
    gameover = "win"  -- player wins if the dealer's points exceed 21.
  elseif points(dealerhand) >= 17 and btnp(5) then
    if points(playerhand) > points(dealerhand) then
      gameover = "win"  -- player wins if they have more points than the dealer.
    else
      gameover = "lose"  -- player loses if their points are equal or less than the dealer's.
    end
  end

  if btnp(4) or btnp(5) then
    if (btnp(4)) add(playerhand, deal())  -- player hits (button 4) to add a card to their hand.
    if points(dealerhand) < 17 then
      add(dealerhand, deal())  -- dealer hits if their points are less than 17.
    end
  end
end

function _draw()
  cls()

  if helpdisplay then
    print("", 0, 0, 3)
    print
