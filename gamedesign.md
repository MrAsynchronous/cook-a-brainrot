## High Concept

A competitive cooking tycoon game where players manage restaurants, compete for ingredients in a shared arena, and automate brainrot production through worker brainrots. Features active PvP elements including sabotage and theft alongside passive income and automation mechanics.

## Inspirations

[X] Steal a Brainrot
[X] My Restaurant
[X] Lumber Tycoon 2

---

# Core Gameplay Loop

## Setup Phase

[X] Players spawn into the game and are assigned one of 7 plots arranged in a circle
[X] Each plot contains a restaurant/kitchen area
[-] Players start with 10 stove slots and basic starting capital
[X] Plots are equidistant from the central ingredient spawn point for fair competition

## Ingredient Acquisition

**Central Spawn System**

[X] Every 3 minutes, ingredients spawn at the central point
[X] Multiple random ingredients drop simultaneously
[X] Players rush to the center to collect desired ingredients
[X] Creates natural competition and risk/reward decisions (leave stoves to get ingredients vs. stay and manage)

**Backpack System**

[X] Players collect ingredients into a personal backpack (not directly into pantry)
[X] Backpack has limited capacity (starting capacity TBD, upgradeable)
[ ] Players must return to their restaurant to unload backpack into pantry
[ ] Unloading is instant interaction at pantry/storage area
[ ] Creates strategic decisions:
[ ] Backpack full? Return to unload or keep collecting and risk losing opportunity?
[ ] How many trips to make before spawn window closes?
[ ] Leave valuable ingredients in backpack while collecting more?
[ ] Backpack contents visible to other players (creates theft risk)
[ ] Backpack can be stolen from (easier than pantry theft, but limited to what's currently carried)

**Unloading to Pantry**

[ ] Players interact with pantry/storage area at their restaurant to unload
[ ] All backpack contents transfer instantly to pantry
[ ] Pantry is where stoves pull ingredients from for cooking
[ ] Runner brainrots can assist with unloading (see Runner Brainrot section)

**PvP Theft**

[ ] Players can steal ingredients from other players' backpacks (easier, but limited quantity)
[ ] Players can steal ingredients from other players' pantries (harder, but more reward)
[ ] Risk: leaves your own base vulnerable while raiding
[ ] Reward: get ingredients without waiting for spawn
[ ] May require specific brainrot worker or tool

## Production Management

**Stove System (Simplified)**

[ ] Stoves are platforms/slots where cooking happens (not upgradeable items)
[ ] Players start with 10 stove slots, can unlock 6 more (16 total maximum)
[ ] Stoves themselves don't have stats - they're just bottlenecks
[ ] **Fire Mechanic**: Stoves randomly catch fire during cooking
[ ] Fire stops production on that stove
[ ] Player must manually extinguish fire to resume
[ ] Creates active gameplay requirement
[ ] May spread to adjacent stoves if not handled quickly

**Brainrot Workers**

[ ] Players cook brainrots and assign them as workers instead of selling all of them
[ ] **Chef Brainrots**: Assigned to stoves to auto-cook specific recipes
[ ] Cooking efficiency tied to brainrot tier/type, NOT the stove
[ ] Higher tier chefs = faster cooking, better quality
[ ] Different chef types might specialize in different brainrot categories
[ ] Brainrots automatically cook assigned recipes as long as ingredients are in pantry
[ ] Production continues passively while players gather more ingredients

## Money Generation (Multi-Source)

**1. Direct Sales**

[ ] Sell excess cooked brainrots for immediate cash
[ ] Sell surplus ingredients you don't need
[ ] Simple shop interface - click to sell
[ ] Strategic decision: use brainrot as worker vs. sell for money

**2. Passive Income (Manager Brainrot)**

[ ] Assign a Manager brainrot to generate periodic payouts
[ ] Payout amount based on total restaurant net worth
[ ] Net worth = value of stoves, stored ingredients, cooked brainrots, workers
[ ] Encourages building up valuable inventory
[ ] Creates tension: sell now vs. hold for passive income

**3. Objectives/Bounties (Optional)**

[ ] "Deliver 20 Sigma Brainrots" → bonus reward
[ ] Time-limited challenges for extra income

---

# Key Systems

## Brainrot Worker Types

### Chef Brainrot

[ ] Assigned to a stove to auto-cook specific recipe
[ ] Cooking efficiency tied to brainrot tier/type
[ ] Higher tier chefs = faster cooking, better quality
[ ] Different chef types might specialize in different brainrot categories
[ ] Eliminates manual cooking management

### Manager Brainrot

[ ] Generates passive income based on restaurant net worth
[ ] May auto-collect ingredients from center spawn
[ ] Potentially only one active at a time, or multiple with diminishing returns

### Runner Brainrot (Potential)

[ ] Specifically for ingredient collection and transport
[ ] Can be assigned to automatically collect ingredients from center spawn
[ ] Collects ingredients into their own "backpack" (separate from player backpack)
[ ] Automatically returns to restaurant to unload into pantry
[ ] Different speeds/capacities based on tier
[ ] Higher tier runners = faster movement, larger capacity, more efficient routes
[ ] Can be sent to steal from other players' pantries (risky, may require higher tier)
[ ] Multiple runners can work simultaneously for increased collection efficiency
[ ] Players can still manually collect while runners work (hybrid approach)

### Guard Brainrot (Potential)

[ ] Defends against theft and arson
[ ] Protects your base while you're away

### Additional Job Ideas

[ ] **Organizer Brainrots**: Increase pantry capacity or sort ingredients
[ ] **Scout Brainrots**: Alert you when rare ingredients spawn

## Fire Mechanic Details

### Natural Fires

[ ] Random chance while cooking (5-15% per cook cycle)
[ ] Higher tier brainrots might reduce fire chance
[ ] Creates attention requirement - can't be fully AFK
[ ] Fire stops production on affected stove

### Fire Spread

[ ] May spread to adjacent stoves if not extinguished quickly
[ ] Could damage ingredients in pantry if spreads too far

### Extinguishing

[ ] Player must click/interact to put out
[ ] Could require fire extinguisher item
[ ] Possible quick-time event mini-game

### Arson (PvP)

[ ] Players can light fires in rival restaurants
[ ] Costs something to prevent spam (cooldown, item cost)
[ ] Risk: being caught on enemy territory
[ ] Creates dynamic moments and revenge cycles

## Slot Unlock System

[ ] **Default**: 10 slots
[ ] **Unlockable**: 6 additional slots
[ ] **Total Maximum**: 16 stove slots
[ ] **Unlock Method**: TBD (purchase with money, achievements, level milestones)

## Pantry System

[ ] Central storage for all collected ingredients (unloaded from backpack)
[ ] Ingredients flow: Center Spawn → Backpack → Pantry → Stoves
[ ] Stoves automatically consume from pantry when cooking
[ ] Players must manage inventory and plan ingredient runs
[ ] Vulnerable to theft from other players (more secure than backpack, but larger target)
[ ] Pantry capacity may be upgradeable (TBD)

## PvP Elements

### Ingredient Competition

[ ] Central spawns are free-for-all
[ ] Players can grab ingredients faster with speed upgrades
[ ] Limited quantities create natural competition

### Sabotage (Arson)

[ ] Set fire to rival stoves (disrupts their production)
[ ] Cooldown timer to prevent spam
[ ] May cost resources to sabotage

### Theft

[ ] Steal ingredients from other players' pantries
[ ] Can players steal cooked brainrots or just ingredients? (TBD)
[ ] Risk: leaves your own base vulnerable
[ ] Reward: get ingredients without waiting for spawn
[ ] How much can be stolen in one raid? (TBD)
[ ] Instant theft or takes time? (TBD)

### Protection Options

[ ] Guard brainrot to defend against theft/arson
[ ] Door locks (upgradeable)
[ ] Alarm systems that alert you when under attack
[ ] Safe storage for most valuable ingredients

---

# Map Layout

[ ] 7 player plots arranged in circle
[ ] Central ingredient spawn point equidistant from all plots
[ ] Fair competitive distance for all players
[ ] "Stoves R Us" store location (TBD)

---

# Progression Path

## Early Game

1. Manually collect ingredients from center into backpack
2. Return to restaurant to unload backpack into pantry
3. Manually cook first basic brainrots
4. Watch for fires and extinguish them
5. Assign first chef brainrot to automate one stove
6. Sell excess brainrots for money
7. Begin unlocking additional stove slots

## Mid Game

1. Multiple chef brainrots automating production
2. Assign manager brainrot for passive income
3. Unlock more stove slots (12-14 slots)
4. Balance selling vs. keeping brainrots as workers
5. Begin sabotaging competitors
6. Invest in defenses against raids

## Late Game

1. Highly automated operation with 16 chef brainrots
2. High-value manager generating substantial passive income
3. Strategic PvP - raiding when competitors leave base
4. Rare/expensive brainrot production
5. Maxed defenses and optimized layouts
6. Focus on efficiency and net worth optimization

---

# Strategic Decisions Players Make

1. **Brainrot Allocation**: Use as worker vs. sell for immediate cash
2. **Worker Distribution**: More chefs vs. more runners vs. manager vs. guards
3. **Risk/Reward**: Leave base to collect/sabotage vs. stay and defend
4. **Investment**: Buy more slots vs. upgrade defenses vs. save for rare brainrots
5. **Inventory Management**: Sell ingredients now vs. stockpile for net worth
6. **Firefighting Priority**: Which fires to put out first when multiple occur
7. **PvP Timing**: When to raid rivals (during ingredient spawns when they're away)
8. **Backpack Management**: Return to unload when full vs. keep collecting and risk losing ingredients
9. **Collection Strategy**: Manual collection vs. Runner brainrots vs. hybrid approach
10. **Backpack vs Pantry Security**: Keep valuable ingredients in backpack (mobile but risky) vs. pantry (secure but stationary)

---

# Open Questions & Systems to Develop

## Brainrot System

- [ ] What are the actual brainrots? Complete list needed
- [ ] Ingredient lists for each brainrot recipe
- [ ] Naming theme for brainrots
- [ ] How many tiers of each worker type? (3? 5? 10?)
- [ ] Different chef types and their specializations

## Ingredient System

- [ ] How many ingredient types total?
- [ ] Rarity tiers for ingredients
- [ ] Special/rare ingredients
- [ ] Ingredient spawn quantities and distribution

## Backpack System

- [ ] Starting backpack capacity? (10 slots? 15? Weight-based?)
- [ ] Can backpack capacity be upgraded? How? (purchase, achievements, brainrot workers)
- [ ] Maximum backpack capacity?
- [ ] Should backpack have weight limits or just slot limits?
- [ ] Can players drop backpack contents if needed? (emergency situations)
- [ ] Visual indicator for backpack capacity (UI element, model on player)
- [ ] Should backpack contents be visible to other players? (theft risk indicator)

## Manager Brainrot Balance

- [ ] Should there be limits on managers? (one active, multiple at reduced efficiency)
- [ ] How often do payouts occur? (every minute, every 5 minutes)
- [ ] What's the payout formula based on net worth?
- [ ] Does manager also auto-collect ingredients or is that a separate runner?

## Fire Mechanic Balance

- [ ] What's the right fire frequency? (too many = annoying, too few = ignorable)
- [ ] Fire spread mechanics - how fast, how far?
- [ ] Extinguishing method - click, item, mini-game?
- [ ] Do higher tier chefs reduce fire chance significantly?

## Theft Mechanics

- [ ] Can players steal cooked brainrots or just ingredients?
- [ ] Can players steal from backpacks? (easier target, but limited quantity)
- [ ] How much can be stolen from backpack vs. pantry in one raid?
- [ ] Instant theft or takes time?
- [ ] Cooldown on theft attempts?
- [ ] Alert system for base owner when pantry is raided?
- [ ] Alert system when backpack is stolen from? (proximity-based?)

## Additional Features

- [ ] Respawn protection - safe period after ingredient spawn where PvP is disabled?
- [ ] Leaderboard system - based on what metric?
- [ ] Restaurant customization - appearance, layout?
- [ ] Speed upgrades for ingredient collection
- [ ] Stove placement strategy - does layout matter for fire spread?

## Monetization (if applicable)

- [ ] Game passes?
- [ ] Premium stoves or brainrots?
- [ ] Cosmetics?
- [ ] VIP benefits?

## Session Design

- [ ] How long should one gameplay session feel satisfying?
- [ ] What keeps players coming back daily?
- [ ] Daily rewards or objectives?

---

## To Be Determined

[ ] Should user backpacks fall off when they die and need to be re-collected or should they remount on respawn
[ ] This determines the usefulness of dropped backpacks \* Dropped backpacks is more complex mechanics but makes sense if brainrots can die
[ ] Can brainrots die?

- i.e if they're robbed a lot

Two paths

1.  Brainrots don't die but backpacks can be stolen from (backpacks themselves don't get taken just the contents)
    - no need for backpack dropping, that mechanic just get's disabled
2.  Brainrots can die or backpacks can be lost
    - requires mechanic for user to drop current bag to pick another one up?
      2.5 Dropped backpacks, when picked up, just add items from backpack to current backpack
    - then there's no need to define functionality where players have a backpack but need to equip

Another idea

- Backpacks are ephermeral. They only exist during an ingredient raid
  - could be appied automatically by the server or require users to pick up backpack before leaving
