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
  attr_accessor :destination, :host, :share, :domain, :user, :password, :type, :extension
  
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
      pref.has_key?(:destination) ? @destination = pref[:destination] : @destination = '!!! /choose/a/path/ !!!'
			pref.has_key?(:domain) ? @domain = pref[:domain] : @domain = ''
      pref.has_key?(:extension) ? @extension = pref[:extension] : @extension = 'none'
      pref.has_key?(:user) ? @user = pref[:user] : @user = `whoami`.chomp
      pref.has_key?(:password) ? @password = pref[:password] : @password = ''
      pref.has_key?(:host) ? @host = pref[:host] : @host = 'hostname'
      pref.has_key?(:share) ? @share = pref[:share] : @share = 'sharename'
      pref[:type].nil? ? @type = 'local' : @type = pref[:type]
    end
  end
  
  def write
    pref = {
      :type => @type,
      :extension => @extension,
      :destination => @destination,
			:domain => @domain,
      :host => @host,
      :share => @share,
      :user => @user,
      :password => @password
    }
    writePref(pref)
  end
  
  private
  
  def prefPath
    File.join(@source,@@prefName)
  end
  
  def loadPref
    set = YAML::load(File.open(prefPath, 'r').read)
    return set[1]
  end
  
  def writePref(pref)
    set = [@@prefText, cleanType(pref)]
    f = File.open(prefPath, 'w'); f.puts YAML::dump(set); f.close
  end
    
  def cleanType(pref)
    if @type == 'local'
      list = [:host,:share,:domain,:user,:password]
    else
      list = [:destination]
    end
    list.each do |key|
      pref.delete(key)
    end
    return pref
  end
  
end