say Welcome to Project: Jekyll!
scoreboard objectives add DamageDealt minecraft.custom:minecraft.damage_dealt
clear @p
effect clear @p
advancement revoke @p everything
execute as @p run function jekyll:mob/demon/give
execute as @p run function jekyll:mob/dhampir/give
execute as @p run function jekyll:mob/mermaid/give
execute as @p run function jekyll:mob/wirwulf/give
item replace entity @p weapon.offhand with minecraft:recovery_compass