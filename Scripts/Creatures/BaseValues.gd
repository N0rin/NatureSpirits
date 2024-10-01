extends Resource
class_name BaseValues

export(String) var name = ""
export(Texture) var appearance

export(String, "None", "Stars", "Sun", "Moon", "Earth") var type
export(String, "None", "Fire", "Water", "Frost", "Wind", "Lightning", "Ground") var element

export(String, "None", "Stability", "Balance", "Leaf", "Aroma") var speedstat
export(int) var max_life = 1
export(int) var stability = 1
export(int) var balance = 1
export(int) var leaf = 1
export(int) var aroma = 1

export(Array, Resource) var potential_moves
export(Array, Resource) var evolutions
