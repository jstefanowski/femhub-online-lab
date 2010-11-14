require 'webrick'
require 'xmlrpc/server.rb'

require File.dirname(__FILE__) + "/interpreter.rb"


class RubyXMLRPCMethods
    def initialize(interpreter)
        @interpreter = interpreter
    end
  
    def complete(source)
        return @interpreter.complete(source)
    end
  
    def evaluate(source)
        return @interpreter.evaluate(source)
    end
end


class RubyXMLRPCServer
    @server
    def initialize(port, interpreter)
        methods = RubyXMLRPCMethods.new(RubyInterpreter.new)
        servlet = XMLRPC::WEBrickServlet.new
        servlet.add_handler("complete") { |source| methods.complete(source) }
        servlet.add_handler("evaluate") { |source| methods.evaluate(source) }

        @server=WEBrick::HTTPServer.new(:Port => port, :Logger =>
        WEBrick::Log.new(nil) )
        @server.mount("/", servlet)
    end
  
    def serve_forever
        $stdout.flush
        @server.start
    end
end
