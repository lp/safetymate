class Hashfs
  module Samba
    require 'rubygems'
    require 'sambala'
    
    def Samba.load(loader)
      @@loader = loader
      @@samba_basedir = File.basename(@@loader.source)
      @@samba_datafile = File.catname(DATANAME,@@samba_basedir)
      @@tmp_destfs = File.catname(DATANAME,'/tmp')
      @@server = Sambala.new(:host => @@loader.host,
                            :share => @@loader.share,
                            :domain => @@loader.domain,
                            :user => @@loader.user,
                            :password => @@loader.password,
                            :threads => 1)
      Samba.getDestFs
    end
    
    def Samba.getDestFs
      unless @@server.exist?(:mask => @@samba_basedir)
        @@server.mkdir(:path => @@samba_basedir)
        return Hashfs.new(@@loader)
      else
        @@server.get(:from => @@samba_datafile, :to => @@tmp_destfs)
        return Marshal.load(File.open(@@tmp_destfs))
      end
    end
    
    def Samba.backup(oriPath,relPath)
			destPath = @@samba_basedir + '/' + relPath
			destDir = File.dirname(destPath)
      @@server.mkdir(:path => destDir)
      result = @@server.put(:from => oriPath, :to => destPath)
			result[0] == true ? $log.info(result[1]) : $log.error(result[1])
    end
    
    def Samba.dump(destfs)
      File.new(@@tmp_destfs, 'w').puts( Marshal.dump(destfs) )
      @@server.put(:from => @@tmp_destfs, :to => @@samba_datafile)
    end

		def Samba.close
			@@server.close
		end
    
  end
end
