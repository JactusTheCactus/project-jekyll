execute as @a[scores={DamageDealt=1..}] if score @s DamageDealt matches 1.. run function jekyll:vampirism/func
scoreboard players set @a[scores={DamageDealt=1..}] DamageDealt 0