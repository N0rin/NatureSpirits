extends Resource
class_name AA_Spell

#Multirundenangriffe werden aktuell nicht behandelt.
export(String) var name = ""

export(String, "Others", "Enemies", "All", "Allies", "Self", "Partner", "None") var targets = "Others"
export(bool) var multitarget = false

export(String, "Attack", "Status") var type

export(int) var base_damage = 0
export(Resource) var damage_factor
export(int) var attack_count = 1
export(Resource) var attack_count_factor

export(bool) var can_miss = true
export(int) var accuracy = 100
export(int) var priority = 0
export(bool) var does_crit = false

export(String, "None", "Stability", "Balance", "Leaf", "Aroma") var used_stat
export(String, "None", "Stability", "Balance", "Leaf", "Aroma") var target_stat
export(String, "None", "Fire", "Water", "Frost", "Wind", "Lightning", "Ground") var element

export(String, "No", "After", "On Condition", "Not on Condition") var uses_additional_spell = "No"
export(Resource) var condition
export(Resource) var extra_spell
export(Array, Resource) var user_modifiers
export(Array, Resource) var target_modifiers

export(String, MULTILINE) var description

export(Resource) var evolves_from
export(Array, Resource) var evolve_quests = []
export(int) var required_xp = 1
