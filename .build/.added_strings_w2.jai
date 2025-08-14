// Workspace: Target Program

//
// #insert text. Generated from C:/Users/sigmawq/RealProjects/jai_playground/jai_playground.jai:9.
//
CONST :: 1;

//
// #insert text. Generated from C:/Users/sigmawq/RealProjects/jai_playground/jai_playground.jai:134.
//
RANDOM_NUMBERS :: s64 .[ 6802, 3674, 6350, 9487, 1126, 3911, 5867, 1653, 7845, 8252, 6148, ];

//
// #insert text. Generated from C:/Users/sigmawq/RealProjects/jai_playground/jai_playground.jai:49.
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

