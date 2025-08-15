// Workspace: Target Program

//
// #insert text. Generated from C:/Users/sigmawq/RealProjects/jai_playground/jai_playground.jai:11.
//
CONST :: 1;

//
// #insert text. Generated from C:/Users/sigmawq/RealProjects/jai_playground/jai_playground.jai:136.
//
RANDOM_NUMBERS :: s64 .[ 4466, 6026, 5038, 5455, 5942, 2615, 7371, 2629, 5493, 8540, 5092, ];

//
// #insert text. Generated from C:/Users/sigmawq/RealProjects/jai_playground/jai_playground.jai:51.
//
only_nones :: (entity_list: Entity_List, body: Code, flags: For_Flags) #expand {
	for * v, i: entity_list.data {
		if v.type != .NONE continue;
		#if flags & .POINTER {
			`it := v;
		} else {
			`it := v.*;
		}
		`it_index := i;
		#insert body;
	}
}

only_players :: (entity_list: Entity_List, body: Code, flags: For_Flags) #expand {
	for * v, i: entity_list.data {
		if v.type != .PLAYER continue;
		#if flags & .POINTER {
			`it := v;
		} else {
			`it := v.*;
		}
		`it_index := i;
		#insert body;
	}
}

only_buildings :: (entity_list: Entity_List, body: Code, flags: For_Flags) #expand {
	for * v, i: entity_list.data {
		if v.type != .BUILDING continue;
		#if flags & .POINTER {
			`it := v;
		} else {
			`it := v.*;
		}
		`it_index := i;
		#insert body;
	}
}

