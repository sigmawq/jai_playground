#import "Basic";
#import "Hash_Table";
#import "Random";
#import "jaison";

BUILD_TIME :: #run to_calendar(current_time_consensus(), .UTC);

#insert "CONST :: 1;";

foo :: (x: *int) -> s64 {
	x.* += 1 + 2;
	print("hello from foo %", x.*);
	return x.*;
}

Entity_Type :: enum s32 {
	NONE :: 0;
	PLAYER;
	BUILDING;
}

Entity :: struct {
	type: Entity_Type;
	name: string;
	position: [2]float;
}

entity_list: [..]Entity;
Entity_List :: struct {
	data: []Entity;
};

for_expansion :: (entity_list: Entity_List, body: Code, flags: For_Flags) #expand {
	for * v, i: entity_list.data {
		if v.type == .NONE continue;
		#if flags & .POINTER {
			`it := v;
		} else {
			`it := v.*;
		}
		`it_index := i;
		#insert body;
	}	
}



#insert -> string {
	// Generate entity iteration procedures
	final_code: String_Builder;
	{
		CODE :: #string END_CODE
only_%1 :: (entity_list: Entity_List, body: Code, flags: For_Flags) #expand {
	for * v, i: entity_list.data {
		if v.type != .%2 continue;
		#if flags & .POINTER {
			`it := v;
		} else {
			`it := v.*;
		}
		`it_index := i;
		#insert body;
	}	
}

END_CODE;
	
		entity_names := enum_names(Entity_Type);
		ti := type_of(Entity_Type);
		for entity_name: entity_names {
			builder: String_Builder;
			for char: entity_name {
				append(*builder, to_lower(char));
			}
			append(*builder, #char "s");
			
			converted_name := builder_to_string(*builder);
			procedure := tprint(CODE, converted_name, entity_name);
			// print("Insert procedure with the following body: %\n", procedure);
			
			append(*final_code, procedure);
		}
	}
	
	return builder_to_string(*final_code);
};

entities :: () {
	// print("%", SOME_CONST);

	entities: []Entity;
	entities = .[
		.{ .PLAYER, "The player", .[ 10.0, 15.0 ] },
		.{ .PLAYER, "The player 2", .[ 15.0, 31.0 ] },
		.{ .NONE, "", .[ 0.0, 0.0 ] },
		.{ .NONE, "", .[ 0.0, 0.0 ] },
		.{ .NONE, "", .[ 0.0, 0.0 ] },
		.{ .BUILDING, "The building", .[ -1.0, 5.0 ] },
	];
	entity_list := Entity_List.{ entities };
	
	print("Entity list: %\n", pretty(entity_list));
	
	for :only_players entity_list {
		print("type=%", type_of(it));
		print("[i=%] type % name %\n", it_index, it.type, it.name);
	}
}

pretty_print :: (thing: $T) {
	push_allocator(temp);
	print("%\n", json_write_string(thing));	
}

pretty :: (thing: $T) -> string {
	push_allocator(temp);
	return json_write_string(thing);
}

compute_random_numbers :: (count: int) -> []s64 {
	seed := current_time_consensus();
	random_seed(seed.low);

	result: [..]s64;
	for i: 0..count {
		number := random_get() % 10_000;
		array_add(*result, cast(s64)number);
	}
	
	return result;
}

#insert -> string {
	numbers := compute_random_numbers(10);
	builder: String_Builder;
	append(*builder, tprint("RANDOM_NUMBERS :: s64 .[ "));
	for numbers {
		if it_index == numbers.count - 1 && false {
			append(*builder, tprint("% ", it));
		} else {
			append(*builder, tprint("%, ", it));
		}
		
	}
	append(*builder, tprint("];"));
	
	return builder_to_string(*builder);
}

macro :: () {
	// a different way to do iterators.. less good, but still interesting
	test_array := string.[
		"Hello",
		"Array",
		"World",
	];
	iter :: (array: []$T, code: Code) #expand {
		for i: 1..array.count {
			`aaa := array[i - 1];
			#insert code;
		}
	}
	
	CODE :: #code print("value: %\n", aaa);
	iter(test_array, CODE);
}

use_generated_random_numbers :: () {
	print("compile time generated random numbers: %\n", pretty(RANDOM_NUMBERS));
}

main :: () {
	macro();
	entities();
	use_generated_random_numbers();
	
	things: Table(s64, string);
	table_add(*things, 1, "Banana");
	table_add(*things, 2, "London");
	table_add(*things, 3, "Defeat");
	table_add(*things, 10, "Weight factor");
	
	for * things {
		print("	%: %\n", it_index, it.*);
	}

	print("hello world\n");
	
	things2 := string.[
		"First",
		"Second",
	];
	for things2 {
		print("%\n", it);
	}
	
	print("Program has been built on %\n", BUILD_TIME);
	print("this: %\n", #this);
	
	x := 0;
	foo(*x);
}