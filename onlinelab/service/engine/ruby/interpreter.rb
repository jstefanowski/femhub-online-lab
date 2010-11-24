require File.dirname(__FILE__) + "/outputtrap.rb"


class RubyInterpreter

    def initialize(locals={}, debug = false)
        @debug = debug
        @trap = OutputTrap.new
        @index = 0
        @file_name = "<online-lab>"
        @binding = eval("def empty_binding; binding; end; empty_binding",
                      TOPLEVEL_BINDING)
    end

    def complete(source)

    end

    def format(str)
        lines = str.split("\n")
        lines.each{|line| line[0,0] = "=> "}
        gattered = ""

        for line in lines
            gattered << line + "\n"
        end

        gattered
    end
            
	

    def evaluate(source)
        begin
            traceback = false
            @trap.set

            start = Time.now.usec

        begin
            last_logical = eval(source, @binding, @file_name)
        rescue Exception => ex
            traceback = ex.message
        end

        stop  = Time.now.usec

        out = @trap.out
        out << format(last_logical.to_s)

        @index += 1

        return { "source" => source,
            "index" => @index,
            "time" => stop - start,
            "out" => out,
            "err" => @trap.err,
            "plots" => [],
            "traceback" => traceback,
            "interrupted" => 0
            }
        ensure
            @trap.reset
        end
    end
end
