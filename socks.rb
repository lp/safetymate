# This class fits Shoes like a Socks!
# Attempting to provide glue helper code,
# to cement external classes to Shoes elements and behaviour 
# 
# Author:: l-p
# Copyright:: Spiralix 2008 under same License as Ruby
# 
# :title:Socks

class Socks
  require 'hashfs'
  require 'ftools'
  
  def initialize(shoes, controls)
    @shoes = shoes
    @controls = controls
  end

  def lace(srcRoot,destRoot)
    @srcfs = Hashfs.new(srcRoot)
    @srcfs.scan
    @controls[:display].replace "looking for files to backup"
    makedirs(destRoot) unless File.exist?(destRoot)
    @destfs = Hashfs.load(destRoot) 
    @trail = Hashfs.compare(@srcfs, @destfs)
  end
  
  def timeFreeze(ext)
    unless ext == 'none'
      h = SafeHistory.new(ext,@srcfs.root,@srcfs.fs)
      h.go
    end
    Hashfs.historyToSafety(h,@trail)
  end
  
  def walk
    anim = @shoes.animate do |i|
      @controls[:progress].fraction = @trail.progress
      @controls[:display].replace "backuping file: #{@trail.current_file} progress= #{@trail.progress}"
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