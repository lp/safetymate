module ShoeHelpers
  require 'hashfs'
  require 'ftools'
  
  def execution
    layout do
      @progress = progress :width => 300
    end
    @title.replace 'Backuping:'
    @display.replace "scanning your backup forder"
    lace; timeFreeze; walk; saveData
  end
  
  private
  
  def lace
    @srcfs = Hashfs.new(@loader.source)
    @srcfs.scan
    @display.replace "looking for files to backup"
    if @loader.type == 'local'
      makedirs(@loader.destination) unless File.exist?(@loader.destination)
      @destfs = Hashfs.load(@loader.destination)
    else
      @smb = SmbHelper.new(:host => @loader.host, :share => @loader.share, :user => @loader.user, :password => @loader.password)
      @destfs = @smb.get_destfs(@loader.source)
    end
    @trail = Hashfs.compare(@srcfs, @destfs)
  end
  
  def timeFreeze
    unless @loader.extension == 'none'
      h = SafeHistory.new(@loader.extension,@srcfs.root,@srcfs.fs)
      h.go
    end
    Hashfs.historyToSafety(h,@trail)
  end
  
  def walk
    anim = animate do |i|
      @progress.fraction = @trail.progress
      @display.replace "backuping file: #{@trail.current_file} progress= #{@trail.progress}"
      @trail.step
      anim.stop if @trail.complete
    end
  end
  
  def saveData
    @destfs.merge(@srcfs)
    @destfs.dump
  end
  
  def printDebug(text)
    Hashfs.printDebug(text)
  end
  
end