execute as @a[scores={DamageDealt=1..}] if score @s DamageDealt matches 1.. run function jekyll:mob/dhampir/heal
scoreboard players set @a[scores={DamageDealt=1..}] DamageDealt 0