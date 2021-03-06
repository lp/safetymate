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
  
	require File.join( File.dirname( File.expand_path(__FILE__)), 'hashfs', 'hashfs_cleanfs')
  require File.join( File.dirname( File.expand_path(__FILE__)), 'hashfs', 'hashfs_diff')
  require File.join( File.dirname( File.expand_path(__FILE__)), 'hashfs', 'hashfs_history')
  require File.join( File.dirname( File.expand_path(__FILE__)), 'hashfs', 'hashfs_local')
  require File.join( File.dirname( File.expand_path(__FILE__)), 'hashfs', 'hashfs_samba')
  require File.join( File.dirname( File.expand_path(__FILE__)), 'hashfs', 'hashfs_utils')
  
  attr_reader :progress, :bit, :fs, :root
  
  DATANAME = '.session_safety_data'
	HASHFS_LOG = 'backup_results.log'
  
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

	def historyToSafety
    history = History.new(@@loader.extension,@@loader.source,@fs)
    history.go
    history.exts.each do |k,v|
      newPath = File.catname(File.basename(k),history.historyPath)
      @@diff.map(newPath,v)
    end
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
        @@diff.map(k,v)
      end
    end
  end
  
  # def Hashfs.step
  #   if @@diff.map?
  #     map = @@diff.current_map
  #     if @@loader.type == 'local'
  #       Local.backup(map[1][:oriPath],@@loader.destination,map[1][:relPath])
  #     else
  #       Samba.backup(map[1][:oriPath],map[1][:relPath])
  #     end
  #     @@diff.done_bits(map[1][:bit]); @@diff.pos_incr
  #   else
  # 			if @@loader.type == 'local'
  #     	@@diff.completed
  # 			else
  # 				@@diff.completed if Samba.queue_done?
  # 			end
  #   end
  # end

	# def Hashfs.step
	# 		debug("step")
	# 		if @@loader.type == 'local'
	# 			if @@diff.map?
	# 				map = @@diff.current_map
	# 				Local.backup(map[1][:oriPath],@@loader.destination,map[1][:relPath])
	# 				@@diff.done_bits(map[1][:bit]); @@diff.pos_incr
	# 			else
	# 				@@diff.completed
	# 			end
	# 		else
	# 			case Samba.queued?
	# 			when true
	# 				debug("samba true")
	# 				Samba.get_done
	# 				# @@diff.done_bits(Samba.done_bits)
	# 			when false
	# 				debug("samba false")
	# 				@@diff.completed
	# 			when nil
	# 				debug("samba nil, diff: #{@@diff.inspect}")
	# 				Samba.queue(@@diff.maps)
	# 			end
	# 		end
	# 	end
	
	def Hashfs.step
		debug("step")
		if @@diff.map?
			map = @@diff.current_map
			if @@loader.type == 'local'
				Local.backup(map[1][:oriPath],@@loader.destination,map[1][:relPath])
			else
				Samba.backup(map[1][:oriPath],map[1][:relPath])
			end
			@@diff.done_bits(map[1][:bit]); @@diff.pos_incr
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

	def Hashfs.dumplog
		File.open(HASHFS_LOG,'w') do |file|
			file.puts Time.now
			if @@loader.type == 'local'
				
			else
				file.puts "The Success:\n\n"
				Samba.success.each { |s| file.puts s }
				file.puts "\n\nThe Failed:\n\n"
				Samba.failed.each { |f| file.puts f }
			end
		end
	end

	def Hashfs.close
		Samba.close
	end
  
end
