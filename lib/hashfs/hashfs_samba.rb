class Hashfs
  module Samba
    require 'rubygems'
    require 'sambala'

    @@server = nil
		@@queue = Array.new
		@@done_results = {true => Array.new, false => Array.new}

    def Samba.load(loader)
      @@loader = loader
      @@samba_basedir = File.basename(@@loader.source)
      @@samba_datafile = File.catname(DATANAME,@@samba_basedir)
      @@tmp_destfs = File.catname(DATANAME,'/tmp')
      @@server = Sambala.new(:host => @@loader.host,
                            :share => @@loader.share,
                            :domain => @@loader.domain,
                            :user => @@loader.user,
                            :password => @@loader.password)
      Samba.getDestFs
    end
    
    def Samba.getDestFs
      unless @@server.exist?(@@samba_basedir)
        @@server.mkdir(@@samba_basedir)
        return Hashfs.new(@@loader)
      else
        @@server.get(:from => @@samba_datafile, :to => @@tmp_destfs)
        return Marshal.load(File.open(@@tmp_destfs))
      end
    end
    
    def Samba.backup(oriPath,relPath)
			destPath = File.join(@@samba_basedir, relPath)
			destDir = File.dirname(destPath)
      @@server.mkdir(destDir)
      @@server.put(:from => oriPath, :to => destPath, :queue => false)
    end
    
    def Samba.dump(destfs)
      File.new(@@tmp_destfs, 'w').puts( Marshal.dump(destfs) )
      @@server.put(:from => @@tmp_destfs, :to => @@samba_datafile)
    end

		def Samba.close
			result = @@server.close unless @@server.nil?
		end
    
  end
end
