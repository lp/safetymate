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
  
  attr_reader :dataPath, :progress, :bit, :fs, :root
  
  DATANAME = '/.session_safety_data'
  
  @@debug = File.new('debug_out.txt', 'w')
  # create new hashfs with +new+ class method
  # The method build the hashed filesystem for given +root+ parameter,
  # It also stores the +dataPath+ parameter for future dump
  
  def initialize(root)
    @root = root
    @dataPath = root + DATANAME
    @fs = Hash.new
  end
  
  def scan
    @fs = scan_fs(@root)
  end
  
  # merging two fs, called from destination to keep info from destination
  def merge(srcfs)
    @fs.merge!( srcfs.fs )
    @fs = killdupl(@root,@fs,srcfs.fs)
  end
  
  # dumping the hashfs 
  def dump
    File.new(@dataPath, 'w').puts( Marshal.dump(self) )
  end
  
  # Class Methods
  
  # dumping hashfs object implemented as Class Method, takes object as parameter + dataPath
  def Hashfs.dump(hashfs, root)
    File.new(root + DATANAME, 'w').puts( Marshal.dump(hashfs) )
  end
  
  # method for loading previously scanned hashfs from a given +dataPath+ parameter
  
  def Hashfs.load(root)
    path = root + DATANAME
    @@debug.puts "loading is #{path}"
    if File.exist?(path)
      return Marshal.load(File.open(path))
    else
      hashfs = Hashfs.new(root)
      hashfs.scan
      return hashfs
    end
  end
  
  # hashfs interface to the volume Spinfs
  
  def Hashfs.compare(srcfs, destfs)
    spinfs = Spinfs.new(srcfs.root, destfs.root)
    srcfs.fs.each do |k,v|
      unless destfs.fs.include?(k)
        spinfs.map(v[:oriPath],v[:bit])
      end
    end
    return spinfs
  end
  
  def Hashfs.historyToSafety(history,spinfs)
    history.exts.each do |k,v|
      @@debug.puts "adding k = #{k}, v = #{v}"
      newPath = File.catname(File.basename(k),history.historyPath)
      spinfs.map(newPath,v)
    end
  end
  
  def Hashfs.printDebug(text)
    @@debug.puts text
  end
  
  private
  
  # method used internally to scan a given filesystem given as +root+ parameter.
  # returns a hash where keys are the hashes converted to symbols and values are their paths
  
  def file_digest(path)
    Digest::SHA1.hexdigest( File.open(path).gets )
  end
  
  def scan_fs(root)
    fs = Hash.new
    Find.find(root) do |path|
      unless File.directory?(path)
        unless File.zero?(path)
          digest = file_digest(path)
          relPath = rel_root(root, path)
          fs[ uKey( relPath, digest ) ] = { :oriPath => path, 
                                            :relPath => relPath, 
                                            :bit => File.size(path)
                                          }
        end
      end
    end
    return cleanfs(root,fs)
  end
  
  # cleans fs from the files which should not be copied
  def cleanfs(root,fs)
    toClean = ['/pref', '/Safety.rb']
    toClean.each do |relPath|
      absPath = abs_root(root,relPath)
      if File.exist?(absPath)
        digest = file_digest(absPath)
        fs.delete( uKey( relPath, digest ))
      end
    end
    return fs
  end
  
  def killdupl(root,fs,oldfs)
    simple_fs = Hash.new
    fs.each { |k,v| simple_fs[k] = v[:relPath] }
    if has_dupl(simple_fs)
      duplKeys = get_dupl(simple_fs)
      fs.delete_if { |k,v| dupl?(k,duplKeys,oldfs) }
    end
    return fs
  end
  
  def has_dupl(hash)
    array = hash.values
    if array.hash == array.uniq.hash
      return false
    else
      return true
    end
  end

  def get_dupl(hash)
    duplKeys = Array.new
    hashCopy = Marshal::load(Marshal::dump(hash))
    hashCopy.each do |k,v|
      hashCopy.delete(k)
      if hashCopy.has_value?(v)
        duplKeys << k
      end
    end
    return duplKeys
  end
  
  def dupl?(k,duplKeys,oldfs)
    if duplKeys.include?(k)
      if oldfs.has_key?(k)
        bool = false
      else
        bool = true
      end
    else
      bool = false
    end
    return bool
  end
  
  def rel_root(root, path)
    path.gsub(/#{root}(.*)/, "\\1")
  end
  
  def abs_root(root, path)
    root + path
  end
  
  def uKey(path, hashes)
    "#{path}-#{hashes}".to_sym
  end
  
end

# and external helper class:

class Spinfs
  require 'ftools'
  
  attr_reader :complete, :srcRoot
  
  def initialize(srcRoot, destRoot)
    @srcRoot = srcRoot
    @destRoot = destRoot
    @pos = 0
    @done = 0
    @bits = 0
    @maps = Array.new
    @complete = false
  end
  
  def map(oriPath,bit)
    paths = { oriPath => rel_root(@srcRoot,oriPath) }
    map = { :paths => paths, :bit => bit}
    @maps << map
    @bits += bit
  end
  
  def step
    if @maps[@pos]
      map = @maps[@pos]
      map[:paths].each do |srcDir,destRel|
        destDir = abs_root(@destRoot, destRel)
        dir = File.dirname(destDir)
        File.makedirs( dir ) unless File.exist?( dir )
        File.copy(srcDir,destDir)
      end
      @done += map[:bit]
      @pos += 1
    else
      @complete = true
    end
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
  
  private
  
  def abs_root(root, path)
    root + path
  end
  
  def rel_root(root, path)
    path.gsub(/#{root}(.*)/, "\\1")
  end
  
end

class SafeHistory
  
  require 'ftools'
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

# class SmbHelper
#   require 'rubygems'
#   require 'sambala'
#   
#   def initialize(options={:host => '', :share => '', :domain => '', :user => '', :password => ''})
#     @sam = Sambala.new(options)
#   end
#   
#   def get_destfs(source)
#     basename = File.basename(source)
#     tmp_destfs = '/tmp/destfs'
#     dirs = @sam.ls(:mask => basename)
#     unless dirs =~ /.*#{basename}.*/
#        @sam.mkdir(:path => basename)
#        return Hashfs.new(root)
#     else
#       @sam.get(:from => DATANAME, :to => tmp_destfs)
#       return Marshal.load(File.open(tmp_destfs))
#     end
#   end
#   
# end


