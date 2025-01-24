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
- [ ] adding life to the ball, and a heart beat effect when it gets hit? maybe a cracking heart depending on life? or it gets drained of color?
- [ ] setting all export values for enemies
- [ ] ticket system for enemies to be spawned in waves with the handler controlling their life/dmg
- [ ] basic wave / weapon UI
- [ ] basic shop ?
- [ ] damage/knockback affected by velocity of weapon
- [ ] directional knockback


# Visual features
- [x] basic weapon sprites
- [x] basic background
- [x] basic cursor/player sprites
- [x] shadows for line2D's (has to be done with instancing of another line2D unfortunately? cannot be done with shader)
- [x] basic enemy sprites
- [ ] fix arrowPath zordering with shadows
- [ ] fix sprites so they stand ON the ground/shadow
- [ ] maybe get rid of all black in sprites for more similar style overall
- [ ] add more flat enemies
- [ ] yeti enemy cus cool

# Weapon types
- [x] basic sword with swing arc / and swing (in circle)
- [x] basic spear with stab (with some wiggle room)
- [ ] rapier sword which has very limited range when pinned but high attack per second and damage (is moved by move perpendicular quickly)
- [ ] bow and arrow which can be pinned to shoot in a direction or another more interesting ranged weapon


# Enemy types
- [ ] In general, an enemy type as "counter" for each weapon type which is countered by a specific other weapon type
- [ ] A caster type which can make another enemy "invulnerable" which in this case means your cursor cant enter the area 
- [ ] Enemy that "grabs" the cursor by setting Input.warp_mouse(pos) constantly until you get out of it somehow idk
- [ ] enemy or environmental debuff that slows or makes the lifeball stuck.
- [ ] debuff that makes the heartball very big or slippery etc.


## CREDIT:
- immortalbean's shadow shader (Godot Shaders) partly used for many of the shadows