require File.dirname(__FILE__) + "/outputtrap.rb"


class RubyInterpreter

    def initialize(locals={}, debug = false)
        @debug = debug
        @trap = OutputTrap.new
        @index = 0
	@file_name = "<online-lab>"
    end

    def complete(source)

    end

    def evaluate(source)
        begin
            traceback = false
            @trap.set

            start = Time.now.usec

        begin
            last_logical = eval(source, nil, @file_name)
        rescue Exception => ex
            traceback = ex.message
        end

        stop  = Time.now.usec

        @index += 1

        return { "source" => source,
            "index" => @index,
            "time" => stop - start,
            "out" => @trap.out + "\n" + last_logical.to_s,
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
