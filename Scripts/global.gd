extends Node

enum ABILITY_TYPES {Double_Jump, Dash, Wall_Cling}

func color_from_flag(flag: int) -> Color:
	return Color(
		flag & (1 << Global.ABILITY_TYPES.Double_Jump), 
		flag & (1 << Global.ABILITY_TYPES.Dash), 
		flag & (1 << Global.ABILITY_TYPES.Wall_Cling))
