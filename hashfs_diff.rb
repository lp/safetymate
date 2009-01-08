class Hashfs
  class Diff

    attr_reader :complete, :srcRoot, :pos

    def initialize(srcRoot)
      @srcRoot = srcRoot
      @pos = 0
      @done = 0
      @bits = 0
      @maps = Array.new
      @complete = false
    end

    def map(oriPath,bit)
      paths = { oriPath => HashfsUtils.rel_root(@srcRoot,oriPath) }
      map = { :paths => paths, :bit => bit}
      @maps << map
      @bits += bit
    end
    
    def map?
      @maps[@pos] ? true : false
    end
    
    def current_map
      @maps[@pos]
    end
    
    def pos_incr
      @pos += 1
    end
    
    def done_bits(bits)
      @done += bits
    end

    def progress
      if @bits == 0
        return 0
      else
        @done / @bits.to_f
      end
    end

    def current_file
      current = ''
      if @maps[@pos]
        map = @maps[@pos]
        map[:paths].each do |k,v|
          current = File.basename(k)
        end
      else
        current = 'Done!'
      end
      return current
    end
    
    def completed
      @complete = true
    end

  end
end