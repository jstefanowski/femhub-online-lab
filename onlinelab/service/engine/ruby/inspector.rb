require 'rubygems'
gem 'rdoc'

require 'rdoc/ri/driver'
require 'rdoc/markup'
require 'rdoc/markup/to_html'



class Inspector

    def initialize
        @driver = RDoc::RI::Driver.new(:use_stdout => false, :formatter => RDoc::Markup::ToHtml)

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


  def @driver.display_class name
    return if name =~ /#|\./

    klasses = []
    includes = []

    found = @stores.map do |store|
      begin
        klass = store.load_class name
        klasses  << klass
        includes << [klass.includes, store] if klass.includes
        [store, klass]
      rescue Errno::ENOENT
      end
    end.compact

    return if found.empty?

    also_in = []

    includes.reject! do |modules,| modules.empty? end

    out = RDoc::Markup::Document.new

    add_class out, name, klasses

    add_includes out, includes

    found.each do |store, klass|
      comment = klass.comment
      class_methods    = store.class_methods[klass.full_name]
      instance_methods = store.instance_methods[klass.full_name]
      attributes       = store.attributes[klass.full_name]

      if comment.empty? and !(instance_methods or class_methods) then
        also_in << store
        next
      end

      add_from out, store

      unless comment.empty? then
        out << RDoc::Markup::Rule.new(1)
        out << comment
      end

      if class_methods or instance_methods or not klass.constants.empty? then
        out << RDoc::Markup::Rule.new(1)
      end

      unless klass.constants.empty? then
        out << RDoc::Markup::Heading.new(1, "Constants:")
        out << RDoc::Markup::BlankLine.new
        list = RDoc::Markup::List.new :NOTE

        constants = klass.constants.sort_by { |constant| constant.name }

        list.push(*constants.map do |constant|
          parts = constant.comment.parts if constant.comment
          parts << RDoc::Markup::Paragraph.new('[not documented]') if
            parts.empty?

          RDoc::Markup::ListItem.new(constant.name, *parts)
        end)

        out << list
      end

      add_method_list out, class_methods,    'Class methods'
      add_method_list out, instance_methods, 'Instance methods'
      add_method_list out, attributes,       'Attributes'

      out << RDoc::Markup::BlankLine.new
    end

    add_also_in out, also_in

    display out
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
                'docstring' => get_docstring(obj, more),
                'docstring_html' => get_docstring(obj, more)
                }
    end
end
