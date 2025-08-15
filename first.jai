#import "Basic";
#import "Compiler";
#import "File";
#import,file "jai_playground.jai";

#run build();

build :: () {
	file_delete("target.exe");

	w := compiler_create_workspace("My lovely program");
	if !w {
	    print("Workspace creation failed.\n");
	    return;
	}

	target_options := get_build_options(w);
	target_options.text_output_flags = 0;
	target_options.output_executable_name = "target";
	// target_options.backend = .X64;
	target_options.debug_for_expansions = false;
	set_build_options(target_options, w);

	compiler_begin_intercept(w);
	add_build_file(tprint("jai_playground.jai"), w);

	message_loop(w);

	compiler_end_intercept(w);

	// print("\nDone!\n\n");

	set_build_options_dc(.{do_output=false});
}

message_loop :: (workspace: Workspace) {
	foo_done := false;
    while true {
        message := compiler_wait_for_message();
        if message.kind == {
          case .FILE;
            message_file := cast(*Message_File) message;

			// print("  Loading file '%'.\n", message_file.fully_pathed_filename);

          case .IMPORT;
            import := cast(*Message_Import) message;
			// print("  Importing module '%'.\n", import.module_name);

          case .PHASE;

            phase := cast(*Message_Phase) message;
			// print("--- Entering phase %. ---\n", phase.phase);

            if phase.phase == .POST_WRITE_EXECUTABLE {
                print("\n");
                if phase.executable_write_failed {
					// print("FAILED writing '%'! Linker exit code was %.\n", phase.executable_name, phase.linker_exit_code);
                } else {
					// print("Success writing '%'! Linker exit code was %.\n", phase.executable_name, phase.linker_exit_code);
                }
            }

          case .TYPECHECKED;
            typechecked := cast(*Message_Typechecked) message;
            n := typechecked.all.count;
            if n == 1 {
				// print("  1 thing has been typechecked.\n");
            } else {
				// print("  % things have been typechecked.\n", n);
            }

			CODE :: #code print("hello from inserted code\n");
			i := 0;
			while i < typechecked.procedure_bodies.count {
				defer i += 1;

				proc := typechecked.procedure_bodies[i].expression;
				if proc.header.name == "main" {

				}

				v := proc.header.enclosing_load.enclosing_import;
				if v {
					if v.module_name == "" {
						print("proc: % | module name: %\n", proc.header.name, v.module_name);
					}
				}

				if proc.header.name != "foo" continue;
				if foo_done continue;

				print("statement count %\n", proc.block.statements.count);

				new_statements: [..]*Code_Node;
				array_add(*new_statements, compiler_get_nodes(CODE));
				array_add(*new_statements, compiler_get_nodes(#code x.* = 10));
				for proc.block.statements {
					print("type info is: %\n", it.kind);
					print("copy\n");
					array_add(*new_statements, it);
				}

				print("==== % ====\n", proc.block.members.count);
				for proc.block.members {
					print("member type info is: %\n", type_to_string(it.type));
				}
				proc.block.statements = new_statements;

				print("new foo: %\n", compiler_get_code(proc.block));

				foo_done = true;
				compiler_modify_procedure(workspace, proc);
			}
          case .COMPLETE;
            break;

          case;
            compiler_report(tprint("Unhandled message type %!\n", message.kind));
        }
    }
}