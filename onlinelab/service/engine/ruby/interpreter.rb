require 'rubygems'
gem 'rdoc'
require 'rdoc/ri/driver'

require File.dirname(__FILE__) + "/inspector.rb"
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
        completions = []
        matches = {}
        
        toComplete = source.split(".", -1)
        back = toComplete[-1]

        if toComplete.length == 1
            matches = eval("Class.constants", @binding, @file_name)
            matches = matches.grep(/^#{back}/) if back.length != 0
            toComplete = ""
        else
            toComplete = toComplete[0..-2]
            toComplete = toComplete.join(".") + "."

            begin
                matches = eval(toComplete + "methods", @binding, @file_name)
                matches = matches.grep(/^#{back}/) if back.length != 0
            rescue Exception => ex
                matches = []
            end
        end

        for match in matches.sort
            completions << { 'match' => toComplete + match,
                        'info' => {} 
                        } 
        end

        return {
            'completions' => completions,
            'interrupted' => false,
            }
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
            if is_inspect(source)
                return inspect(source)
            else
                traceback = ex.message
            end
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

    def is_inspect(source)
        return source[0,1] == "?"
    end

    def inspect(source)
        if source[0,2] == "??"
            text = source[2..-1]
            more = true
        else
            text = source[1..-1]
            more = false
        end

        toInspect = text.split(".", -1)
        
	    begin
            if toInspect.length > 1
                front = toInspect[0]
                back = toInspect[1..-1]

                back = "." + back.join(".")
            
                if is_class(front)
                    klass = front
                else
                    klass = eval(front+".class.to_s", @binding, @file_name)
                end
            else
                if is_class(text)
                    klass = text
                else
                    klass = eval(text+".class.to_s", @binding, @file_name)
                end

                back = ""
            end

            @index += 1
            ins = Inspector.new
            info = ins.get_pretty(klass.to_s + back, more)
        rescue Exception => ex
            info = "<no docstring>"
        end

        return {
            'source' => source,
            'text' => text,
            'info' => info,
            'more' => false,
            'index' => @index,
            'interrupted' => false
            }
    end

    def is_class(text)
        classList = eval("Class.constants", @binding, @file_name)
        classList.include?(text)
    end
end
