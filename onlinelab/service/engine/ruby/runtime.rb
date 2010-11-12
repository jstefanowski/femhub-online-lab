require "/home/Kuba/femhub-online-lab/onlinelab/service/engine/ruby/server.rb"
require "socket"


class RubyEngine
    @interpreter
  
    def initialize(interpreter=nil)
        @interpreter = interpreter
    end
  
    def find_port()
        server = TCPServer.new('127.0.0.1', 0)
        port = server.addr[1]
        server.close
        return port
    end
  
    def notify_ready(port)
        $stdout.write("port=%s, pid=%s\n" % [port, Process.pid])
    end
  
    def run_server(port)
        server = RubyXMLRPCServer.new(port, @interpreter)
        notify_ready(port)
        server.serve_forever
    end

    def run(port=nil)
        if port == nil
            run_server(find_port)
        else
            run_server(port)
        end
    end  
end
