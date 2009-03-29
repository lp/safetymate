module ShoeHelpers 
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
			@display.replace "saving session history"
      Hashfs.historyToSafety
    end
  end
  
  def walk
    anim = animate do |i|
      @progress.fraction = Hashfs.progress
      @display.replace "backuping file: #{Hashfs.current_file}"
      Hashfs.step
      anim.stop if Hashfs.completed?
    end
  end
  
  def saveData
    @destfs.merge(@srcfs)
    Hashfs.dump(@destfs)
		# Hashfs.dumplog
  end
  
  def printDebug(text)
    Hashfs.printDebug(text)
  end
  
end