#import "Basic";
#import "Hash_Table";
#import "Random";
#import "Compiler";
#import "File";
#import "Program_Print";
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

print_two_point_zero :: ($format_string: string) #expand {
	real_format_string :: #run -> string {
		print("invoke print_two_point_zero with baked format string: %\n", format_string);
		print_string: String_Builder;
		append(*print_string, "print(\"");
		current_arg_begin: s64 = -1;
		builder: String_Builder;
		args: [..]string;
		reading_inner_body: bool;
		for format_string {
			print("%\n", it);
			if reading_inner_body {
				if it == #char "}" {
					arg: string;
					arg.data = format_string.data + current_arg_begin +1;
					arg.count = it_index - current_arg_begin - 1;
					reading_inner_body = false;
					current_arg_begin = -1;
					print("new arg %\n", arg);

					append(*print_string, "%");
					array_add(*args, arg);
				}
			} else {
				if current_arg_begin == -1 {
					current_arg_begin = it_index;
				}
				if it == #char "{" {
					arg: string;
					arg.data = format_string.data + current_arg_begin;
					arg.count = it_index - current_arg_begin;
					current_arg_begin = -1;
					print("new string %\n", arg);

					// append(*print_string, arg);

					reading_inner_body = true;
					current_arg_begin = it_index;
				} else {
					if it == 10 { // don't convert newline to real newline in generated code!
						append(*print_string, "\\n");
					} else {
						append(*print_string, it);
					}
				}
			}
		}

		if reading_inner_body {
			assert(false, "unmatched paran somewhere");
		}

		parse_arg :: (code: string) -> string {
			this_message_loop :: (workspace: Workspace) {
				while true {
					message := compiler_wait_for_message();

					if message.kind == {
						case .FILE;
							m := cast(*Message_File)message;
							print("                  file message: %\n", pretty(m));
						case .TYPECHECKED;
							m := cast(*Message_Typechecked)message;
							message_import := m.declarations[0].expression.enclosing_load.enclosing_import;
							// if s.
							if message_import {
								print("                  first decl: %\n", pretty(m.declarations[0].expression));
							}
						case .ERROR;
							print("ERRORRRRRRRRRRRROR\n");
						case .COMPLETE;
							break;
					}
				}
			}

			w := compiler_create_workspace("");
			target_options := get_build_options(w);
			target_options.output_type = .NO_OUTPUT;
			target_options.output_executable_name = "";
			set_build_options(target_options, w);
			compiler_begin_intercept(w);
			add_build_string("ui := 1;", w);
			this_message_loop(w);
			compiler_end_intercept(w);

			return "";
		}

		tmp :: ($v: string) -> string {
			return tprint("THE_CODE :: #code %", v);
		}

		append(*print_string, "\", ");
		for args {
			z := cast(Code)it;
			print("cast(Code)it = %\n", z);
			
			// #run
			// #insert,scope() #run tmp(it);
			append(*print_string, it);
		}
		append(*print_string, ");");
		str := builder_to_string(*print_string);
		print("converted string to print: %\n", str);

		return str;
	}

	#insert real_format_string;
}

print_ast :: (node: *Type_Info) {
	pretty_print(node);
}

compile_simple_expression_in_a_separate_workspace :: () {
	this_message_loop :: (workspace: Workspace) {
		sb: String_Builder;
		defer {
			print("write to file\n");
			if !write_entire_file("debug.txt", builder_to_string(*sb)) {
				print("failed!\n");
			}
		}
		count := 0;
		while true {
			message := compiler_wait_for_message();

			if message.kind == {
				case .FILE;
					m := cast(*Message_File)message;
					// append(*sb, tprint("file message: %\n", pretty(m)));
				case .TYPECHECKED;
					m := cast(*Message_Typechecked)message;
					// message_import := m.declarations[0].expression.enclosing_load.enclosing_import;
					// // if s.
					// for decl: m.declarations {
					// 	if decl.expression.enclosing_load.from_a_string {
					// 		append(*sb, tprint("decl: %\n", pretty(decl.expression)));
					// 		append(*sb, "print_expression() of this decl:\n");

					// 		print_expression(*sb, decl.expression);
					// 		append(*sb, "\n");
					// 		count += 1;
					// 	}
					// }
				case .ERROR;
					print("ERRORRRRRRRRRRRROR\n");
				case .COMPLETE;
					break;
			}
		}
		append(*sb, tprint("decl count from non-file sources:%\n", count));
	}

	w := compiler_create_workspace("");
	target_options := get_build_options(w);
	target_options.output_type = .NO_OUTPUT;
	target_options.output_executable_name = "";
	set_build_options(target_options, w);
	compiler_begin_intercept(w);
	add_build_string("my_variable := 69;", w);
	this_message_loop(w);
	compiler_end_intercept(w);
}

main :: () {
	print("================== RUNTIME ====================\n");

	// #run compile_simple_expression_in_a_separate_workspace();

	{
		x := 1;
		y := 15;

		CODE :: #run -> Code {
			code: string = "x - y";
			return code;
		}
		#run print("CODE is %\n", CODE);


		// passing backticks is ugly.. but otherwise you'll to parse everything yourself which is not a small task to do.
		// also error reporting sucks because it reports errors from generated code
		// print_two_point_zero("some string {`x + `y} suffix\n");
		print_two_point_zero("some string {`y}\n");
	}


	// macro();
	// entities();
	// use_generated_random_numbers();

	// things: Table(s64, string);
	// table_add(*things, 1, "Banana");
	// table_add(*things, 2, "London");
	// table_add(*things, 3, "Defeat");
	// table_add(*things, 10, "Weight factor");

	// for * things {
	// 	print("	%: %\n", it_index, it.*);
	// }

	// print("hello world\n");

	// things2 := string.[
	// 	"First",
	// 	"Second",
	// ];
	// for things2 {
	// 	print("%\n", it);
	// }

	// print("Program has been built on %\n", BUILD_TIME);
	// print("this: %\n", #this);

	// x := 0;
	// foo(*x);
}