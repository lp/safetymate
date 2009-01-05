module ShoeHelpers
  require 'hashfs'
  require 'ftools'
  
  def execution
    layout do
      @progress = progress :width => 460
    end
    @title.replace 'Backuping:'
    @display.replace "scanning your backup forder"
    lace; timeFreeze; walk; saveData
  end
  
  private
  
  def lace
    @srcfs = Hashfs.new(@loader)
    @srcfs.scan
    @display.replace "looking for files to backup"
    @destfs = Hashfs.load
    Hashfs.diff(@srcfs, @destfs)
  end
  
  def timeFreeze
    unless @loader.extension == 'none'
      Hashfs.historyToSafety
    end
  end
  
  def walk
    anim = animate do |i|
      @progress.fraction = @diff.progress
      @display.replace "backuping file: #{@diff.current_file} progress= #{@diff.progress}"
      @diff.step
      anim.stop if @diff.complete
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