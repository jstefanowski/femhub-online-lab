require File.dirname(__FILE__) + "/outputtrap.rb"


class RubyInterpreter

    def initialize(locals={}, debug = false)
        @debug = debug
        @trap = OutputTrap.new
        @index = 0
    end

    def complete(source)

    end

    def evaluate(source)
        begin
            traceback = false
            @trap.set

            start = Time.now.usec

        begin
            eval(source)
        rescue Exception => ex
            traceback = ex.message
        end

        stop  = Time.now.usec

        @index += 1

        return { "source" => source,
            "index" => @index,
            "time" => stop - start,
            "out" => @trap.out,
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
