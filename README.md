# Wizards and Woofers Handguide
This document contains details about the stats, skills, and mechanics of wizards and woofers. It is not necessary to complete the game, but may help players who want to strategize further. 

## Stats
- LV: Level. Slightly boosts attack and defense during combat.
- XP: Experience.
- H: Health. Always healed fully before battle.
- S: Spirit. Necessary to use skills. Always healed to 50% of max S before battle.
- ATK: Attack. Increases damage dealt.
- DEF: Defense. Decreases damage dealt.
- WIT: Wit. Slightly increases XP gain and H/S growth per level up. A higher WIT allows a party member to move earlier in battle.

## Status effects
Status effects are special conditions that can change the behavior of a fighter in combat. All status effects are healed after battle.
- BURNING: Lose 5% of max H per turn. Will stop doing damage at 1 H. Lasts 3 turns.
- DIZZY: Dizzy enemies skip their turn 35% of the time. Dizzy party members have the speed of the combo circle scaled up or down randomly. Lasts 3 turns.
- BLESSED: Gain 10% of max H and S per turn. Will stop at max H/S. Lasts 3 turns.
- DEAD: Cannot act until revived using COPAL. Death resets stat buffs and removes other status effects.

## Stat buffs
Skills such as ATK down, ATK up, DEF down, and DEF up can increase or decrease stats during battle. Buffs are measured on stages from -2 to 2. ATK and DEF both have separate stage counters, defaulting to 0. Buff skills either decrease or increase the stage of a buff by 1. These stages persist until the end of the battle, or until another buff skill is used. If ATK up is used twice by the player, then the enemy uses ATK down once, the stage of the ATK buff will ultimately be 1. ATK and DEF are scaled by 1.3^(stage) in damage calculations.

## Items
Below are the items you can use in combat. Collect them in treasure chests found in the overworld! There are also other secret and powerful items scattered across the world.
- FLAN: Creamy caramel custard that heals 45% of max H.
- LECHE: Sweet milk that heals 100% of max S.
- COPAL: Incense that heals all status effects and 80% of max H.
