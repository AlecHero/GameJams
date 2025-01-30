# Game "idea"
An arsenal of weapons have gone berserk and decided to leave their original wielder "behind", while flying around to defeat various foes they must still protect this person.
This reflects itself in the form of a bound person being led by rope by the weapons (the cursor), while mostly a deadweight it's still their job to protect the person.
## Game Loop
Similar to vampire survivors you protect yourself from waves of monsters while (collecting loot?) / (doing side objectives?)
these waves get stronger and stronger each time, therefore collected money goes to upgrading your weapons / adding weapons to your arsenal or ? upgrades?
the game ends after some decided wave ? boss enemy? idk.


# Main features
- [x] pinning cursor for swing effects
- [x] ball that tracks and follows cursor with "elastic string" which you must protect and represenets your life.
- [ ] proper enemy spawning system in clusters and or waves
- [ ] proper enemy AI (maybe movement like in starcraft 2 where a cluster of enemies move in a formation which avoids them trying to bunch together at once)
- [ ] proper enemy health system and damage system with numbers and visualiztaiton for healthbars indicators etc.
- [ ] weapons are upgradeable? Sword starts out being just a stick.
- [?] proper weapon switching system (maybe with a cooldown or something)
- [ ] purchasing system for upgrades and weapons (maybe with a shopkeeper that appears every few waves? or like in vampire survivors where you can buy stuff inbetween waves?) or like in "rogue legacy" where you can buy stuff after you die? or like in binding of isaac where you can receive items after certain enemies are defeated?
- [ ] UI IN GENERAL


# TBD Next:
- [x] adding life to the ball,
- [x] damage/knockback affected by velocity of weapon
- [x] directional knockback
- [x] and a heart beat effect when it gets hit? maybe a cracking heart depending on life? or it gets drained of color?
- [ ] setting all export values for enemies
- [/] ticket system for enemies to be spawned in waves with the handler controlling their life/dmg
- [/] wave system WITH counters in mind
- [ ] basic wave / weapon UI
- [ ] basic shop ?
- [ ] way to heal the ball could be an environemnetal hp-up which moves in a difficult to reach/catch path
- [ ] buff which makes the heart ball invulnerable and exploding on touch with enemies
- [ ] timer UI (VS style)


# Misc features
- [ ] lava / ice / spiked flooring as environments
- [ ] a limited area zone which you have to stay in for the time to progress?


# Visual features
- [x] basic weapon sprites
- [x] basic background
- [x] basic cursor/player sprites
- [x] shadows for line2D's (has to be done with instancing of another line2D unfortunately? cannot be done with shader)
- [x] basic enemy sprites
- [x] fix arrowPath zordering with shadows
- [x] fix sprites so they stand ON the ground/shadow
- [x] maybe get rid of all black in sprites for more similar style overall
- [ ] add more flat enemies
- [ ] yeti enemy cus cool

# Weapon types
- [x] basic sword with swing arc / and swing (in circle)
- [x] basic spear with stab (with some wiggle room)
- [ ] rapier sword which has very limited range when pinned but high attack per second and damage (is moved by move perpendicular quickly)
- [ ] bow and arrow which can be pinned to shoot in a direction or another more interesting ranged weapon
- [ ] "choosable evolution" so either a fast sword, or a slow mace for example. Mace has smaller hitbox but more damage and knockback and slower, while sword is quicker and has a bigger hitbox but less damage and knockback but also a directional element to it.


# Enemy types
- [ ] In general, an enemy type as "counter" for each weapon type which is countered by a specific other weapon type
- [ ] A caster type which can make another enemy "invulnerable" which in this case means your cursor cant enter the area 
- [ ] Enemy that "grabs" the cursor by setting Input.warp_mouse(pos) constantly until you get out of it somehow idk
- [ ] enemy or environmental debuff that slows or makes the lifeball stuck.
- [ ] debuff that makes the heartball very big or slippery etc.
- [ ] enemy that shoots and tries to stay slightly out of reach of the shortranged weapons
- [ ] static enemy which shoots projectiles (much like the circles spawning around you in VS)

- [ ] rushers which can resist one hit completely one time perhaps (magic shield or some shit)
- [ ] enemy with square collision that block you in
- [ ] enemy that makes nearby enemies faster
- [ ] 

- [/] make wall dynamically change according to viewport?



## CREDIT:
- immortalbean's shadow shader (Godot Shaders) partly used for many of the shadows

"Drums of the Deep" Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0 License
http://creativecommons.org/licenses/by/4.0/

"Desert City" Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0 License
http://creativecommons.org/licenses/by/4.0/

"Big Mojo" Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0 License
http://creativecommons.org/licenses/by/4.0/

"Thunderhead" Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0 License
http://creativecommons.org/licenses/by/4.0/

"Tabuk" Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0 License
http://creativecommons.org/licenses/by/4.0/

"Firebrand" Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0 License
http://creativecommons.org/licenses/by/4.0/

"Moorland" Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0 License
http://creativecommons.org/licenses/by/4.0/

"Dhaka" Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0 License
http://creativecommons.org/licenses/by/4.0/

"Mystery Bazaar" Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0 License
http://creativecommons.org/licenses/by/4.0/
"Well met, traveller! Come warm by my brazier... Is that a Djinn in your pocket, or are you just happy to see me? Hah! I have a joke with you! ...unless it is a djinn - then you must leave immediately! ...unless that would offend the djinn - then you must stay! ...unless the djinn is going to kill me - then you must leave immediately! ...unless it will save me from a fate worse than death - then you must stay! Oh good... it was an erection."

"Hidden Wonders" Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0 License
http://creativecommons.org/licenses/by/4.0/
"Would you like to sample my wares? I specialize in non-djinn-infested housewares! Djinn-free spoons, Djinn-free curtains, Djinn-free spices, mostly Djinn-free oil lamps, Djinn-free flying carpets (still magic, but not Djinn powered). Come on in to Gazeem's Discount mostly-Djinn-free Housewares Tent! You won't be disappointed... unless you want a Djinn, then go see Maghrib."

"Island Meet and Greet" Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0 License
http://creativecommons.org/licenses/by/4.0/

"Big Drumming" Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0 License
http://creativecommons.org/licenses/by/4.0/

"Goblin Tinker Soldier Spy" Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0 License
http://creativecommons.org/licenses/by/4.0/

"Gregorian Chant" Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0 License
http://creativecommons.org/licenses/by/4.0/

"Chillin Hard" Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0 License
http://creativecommons.org/licenses/by/4.0/

"Gypsy Shoegazer No Voices" Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0 License
http://creativecommons.org/licenses/by/4.0/

"The Machine Thinks" Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0 License
http://creativecommons.org/licenses/by/4.0/

"Netherworld Shanty" Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0 License
http://creativecommons.org/licenses/by/4.0/

"Ancient Rite" Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0 License
http://creativecommons.org/licenses/by/4.0/

"Crowd Hammer" Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0 License
http://creativecommons.org/licenses/by/4.0/

"Shamanistic" Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0 License
http://creativecommons.org/licenses/by/4.0/