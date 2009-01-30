# This Class has the purpose of hashing a filesystem in a hash.
# It then offers extra methods to marshall the hashes, compare filesystem and more
# 
# Author:: l-p
# Copyright:: Spiralix 2008 under same License as Ruby
# 
# :title:Hashfs

class Hashfs
  
  require 'find'
  require "digest"
  require 'ftools'
  
  require 'hashfs_cleanfs'
  require 'hashfs_diff'
  require 'hashfs_history'
  require 'hashfs_local'
  require 'hashfs_samba'
  require 'hashfs_utils'
  
  attr_reader :progress, :bit, :fs, :root
  
  DATANAME = '.session_safety_data'
  
  @@debug = File.new('debug_out.txt', 'w')
  
  def initialize(loader)
    @@loader = loader
    @fs = Hash.new
  end
  
  def scan
    @fs = Local.scan_fs(@@loader.source)
  end
  
  # merging two fs, called from destination to keep info from destination
  def merge(srcfs)
    @fs.merge!( srcfs.fs )
    @fs = Cleanfs.killdupl(@@loader.source,@fs,srcfs.fs)
  end
  
  # Class Methods
  
  # dumping destfs object implemented as Class Method, takes object as parameter + dataPath
  def Hashfs.dump(destfs)
    if @@loader.type == 'local'
      Local.dump(destfs,@@loader.destination)
    else
      Samba.dump(destfs)
    end
  end
  
  # method for loading previously scanned hashfs from a given +dataPath+ parameter
  
  def Hashfs.load
    if @@loader.type == 'local'
      Local.load(@@loader.destination)
    else
      Samba.load(@@loader)
    end
  end
  
  # hashfs interface to the volume diff
  
  def Hashfs.diff(srcfs, destfs)
    @@diff = Diff.new(srcfs.root)
    srcfs.fs.each do |k,v|
      unless destfs.fs.include?(k)
        @@diff.map(v[:oriPath],v[:bit])
      end
    end
  end
  
  def Hashfs.historyToSafety
    history = History.new(@@loader.extension,@srcfs.root,@srcfs.fs)
    history.go
    history.exts.each do |k,v|
      newPath = File.catname(File.basename(k),history.historyPath)
      @@diff.map(newPath,v)
    end
  end
  
  def Hashfs.step
    if @@diff.map?
      map = @@diff.current_map
      map[:paths].each do |srcPath,destRel|
        if @@loader.type == 'local'
          Local.backup(srcPath,@@loader.destination,destRel)
        else
          Samba.backup(srcPath,destRel)
        end
      end
      @@diff.done_bits(map[:bit]); @@diff.pos_incr
    else
      @@diff.completed
    end
  end
  
  def Hashfs.progress
    @@diff.progress
  end
  
  def Hashfs.current_file
    @@diff.current_file
  end
  
  def Hashfs.completed?
    @@diff.complete
  end
  
  def Hashfs.printDebug(text)
    @@debug.puts text
  end
  
end
