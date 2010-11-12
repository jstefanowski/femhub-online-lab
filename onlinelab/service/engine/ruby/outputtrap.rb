require 'stringio'


class OutputTrap
  
    def initialize
        @out = StringIO.new
        @err = StringIO.new
        @oldout = $stdout
        @olderr = $stderr
    end
  
    def set
        if $stdout != @out
          $stdout = @out
        end
    
        if $stderr != @err
          $stderr = @err
        end
    end
  
    def unset
        $stdout = @oldout
        $stderr = @olderr
    end
  
    def reset
        @out.close
        @out = StringIO.new
    
        @err.close
        @err = StringIO.new
    
        unset
    end
  
    def out
        return @out.string
    end
  
    def err
        return @err.string
    end
  
    def values
        return @out, @err
    end
end
