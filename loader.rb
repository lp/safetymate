# This Class provide methods for tampering with temporary and permanent setting files.
# Temporary Settings are used here as a means of passing information between chained processes.
# Permanent Settings are used to store informations between invocations
# 
# Author:: Louis-Philippe Perron (mailto:lp@spiralix.org)
# Copyright:: L-P 2008 under same license as Ruby
# 
# :title:SetN

class Loader
  require 'ftools'
  require 'yaml'
  attr_reader :source
  attr_writer :destination, :server, :share, :user, :password, :type, :extension
  
  @@tmpfile = '/tmp/safety.now'
  @@prefName = 'safetyCopy_prefs.yml'
  @@prefText = 'Configuration File for SafetyCopy.  Please respect space and line breaks while editing.'
  
  def initialize(type=:read)
    if type == :write
      @source = Dir.pwd
      if File.exist?(prefPath)
        pref = loadPref
      else
        pref = Hash.new
      end
      pref[:source] = @source
      f = File.open(@@tmpfile, 'w')
      f.puts Marshal.dump(pref)
      f.close
    else
      pref = Marshal.load(File.open(@@tmpfile).read)
      @source = pref[:source] if pref.has_key?(:source)
      @destination = pref[:destination] if pref.has_key?(:destination)
      @extension = pref[:extension] if pref.has_key?(:extension)
      @user = pref[:user] if pref.has_key?(:user)
      @password = pref[:password] if pref.has_key?(:password)
      @server = pref[:server] if pref.has_key?(:server)
      @share = pref[:share] if pref.has_key?(:share)
      @type = pref[:type] if pref.has_key?(:type)
    end
  end
  
  def destination
    @destination || '/choose/a/path/'
  end
  
  def server
    @server || 'servername'
  end
  
  def share
    @share || 'sharename'
  end
  
  def type
    @type || 'local'
  end
  
  def user
    @user || `whoami`.chomp
  end
  
  def password
    @password || ''
  end
    
  def extension
    @extension || 'none'
  end
  
  def write
    pref = {
      :type => @type,
      :extension => @extension,
      :destination => @destination,
      :server => @server,
      :share => @share,
      :user => @user,
      :password => @password
    }
    writePref(pref)
  end
  
  private
  
  def prefPath
    File.catname(@@prefName, @source)
  end
  
  def loadPref
    set = YAML::load(File.open(prefPath, 'r').read)
    return set[1]
  end
  
  def writePref(pref)
    set = [@@prefText, cleanType(pref)]
    f = File.open(prefPath, 'w'); f.puts YAML::dump(set); f.close
  end
  
  # def writePref(key, value)
  #   if File.exist?(prefPath)
  #     set = YAML::load(File.open(prefPath, 'r').read)
  #   else
  #     set = [@@prefText, Hash.new]
  #   end
  #   set[1][key] = value
  #   f = File.open(prefPath, 'w'); f.puts YAML::dump(set); f.close
  # end
  
  def cleanType(pref)
    if @type == 'local'
      list = [:server,:share,:user,:password]
    else
      list = [:destination]
    end
    list.each do |key|
      pref.delete(key)
    end
    return pref
  end
  
end