// Workspace: My lovely program

//
// #insert text. Generated from C:/Users/sigmawq/RealProjects/jai_playground/jai_playground.jai:8.
//
CONST :: 1;

//
// #insert text. Generated from C:/Users/sigmawq/RealProjects/jai_playground/jai_playground.jai:48.
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


//
// #insert text. Generated from C:/Users/sigmawq/RealProjects/jai_playground/jai_playground.jai:133.
//
RANDOM_NUMBERS :: s64 .[ 818, 922, 238, 6463, 70, 8743, 4667, 2613, 1701, 5468, 5092, ];

//
// #insert text. Generated from C:/Users/sigmawq/RealProjects/jai_playground/jai_playground.jai:235.
//
print("some string % suffix\n", `x + `y);

//
// #insert text. Generated from C:/Users/sigmawq/RealProjects/jai_playground/jai_playground.jai:235.
//
print("some string %\n", `y);
