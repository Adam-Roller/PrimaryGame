extends Node

enum ABILITY_TYPES {Double_Jump = 1, Dash = 2, Wall_Cling = 4}

func color_from_flag(flag: int) -> Color:
	return Color(
		flag & ABILITY_TYPES.Double_Jump, 
		flag & ABILITY_TYPES.Dash, 
		flag & ABILITY_TYPES.Wall_Cling)
