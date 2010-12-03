require 'rubygems'
gem 'rdoc'

require 'rdoc/ri/driver'
require 'rdoc/markup'
require 'rdoc/markup/to_html'



class Inspector

    def initialize
        @driver = RDoc::RI::Driver.new(:use_stdout => false, :formatter => RDoc::Markup::ToBs)

        def @driver.set_string_output
            require 'stringio'
            @string_output = StringIO.new
        end

        def @driver.page
            set_string_output

            begin
                yield @string_output
            ensure
                @string_output.close
            end
        end

        def @driver.get_string_output
            if @string_output == nil
                return ""
            else
                @string_output.string
            end
        end

        def @driver.display_class_short name
            return if name =~ /#|\./

            klasses = []
            includes = []

            found = @stores.map do |store|
              begin
                klass = store.load_class name
                klasses  << klass
                [store, klass]
              rescue Errno::ENOENT
              end
            end.compact

            return if found.empty?

            also_in = []

            out = RDoc::Markup::Document.new

            add_class out, name, klasses

            found.each do |store, klass|
              comment = klass.comment
              class_methods    = store.class_methods[klass.full_name]
              instance_methods = store.instance_methods[klass.full_name]

              if comment.empty? and !(instance_methods or class_methods) then
                also_in << store
                next
              end


              unless comment.empty? then
                out << RDoc::Markup::Rule.new(1)
                out << comment
              end
                out << RDoc::Markup::BlankLine.new
            end

            display out
          end

        def @driver.display_name_short name
            return true if display_class_short name

            display_method name if name =~ /::|#|\./

            true
          rescue NotFoundError
            matches = list_methods_matching name if name =~ /::|#|\./
            matches = classes.keys.grep(/^#{name}/) if matches.empty?

            raise if matches.empty?

            page do |io|
              io.puts "#{name} not found, maybe you meant:"
              io.puts
              io.puts matches.join("\n")
            end

            false
          end



    end

    def get_docstring(obj, more = true)
        if more
            @driver.display_name(obj)
        else
            @driver.display_name_short(obj)
        end

        return @driver.get_string_output
    end

    def get_info(obj, more = true)
        docs = get_docstring(obj, more)
        return {
            'docstring' => docs,
            'comments' => "",
            'sourcefile' => "",
            'source' => ""
            }
    end

    def get_pretty(obj, more = true)
        return {
                'docstring' => get_docstring(obj, more)
                }
    end
end
