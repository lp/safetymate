class Hashfs  
  class History

    attr_reader :exts, :historyPath

    HISTORYNAME = '/session_history'

    def initialize(ext,root,fs)
      @ext = ext
      @root = root
      @fs = fs
      @historyRoot = root + HISTORYNAME
      @historyPath = @historyRoot + dateFolder
    end

    def go
      File.makedirs( @historyPath ) unless File.exist?( @historyPath )
      @exts = findFileExt(@ext,@fs)
      @exts.each_key do |file|
        File.copy(file,@historyPath)
      end
    end

    private

    def findFileExt(ext,fs)
      exts = Hash.new
      fs.each do |k,v|
        exts[v[:oriPath]] = File.size?(v[:oriPath]) if ext == File.extname(v[:oriPath]) and ! v[:oriPath].include? HISTORYNAME
      end
      return exts
    end

    def dateFolder
      t = Time.now
      return '/' + t.strftime("%y%m%d_%Hh%Mm%S")
    end

  end
end