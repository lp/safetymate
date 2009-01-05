class Hashfs
  module Samba
    require 'rubygems'
    require 'sambala'
    
    def Samba.load(loader)
      @@loader = loader
      @@server = Sambala.new(:host => @@loader.host,
                            :share => @@loader.share,
                            :domain => '',
                            :user => @@loader.user,
                            :password => @@loader.password)
      Samba.getDestFs
    end
    
    def Samba.getDestFs
      basename = File.basename(@@loader.source)
      @@tmp_destfs = '/tmp/destfs'
      dirs = @@server.ls(:mask => basename)
      unless dirs =~ /.*#{basename}.*/
        @@server.mkdir(:path => basename)
        return Hashfs.new(@@loader)
      else
        @@server.get(:from => "#{basename}#{DATANAME}", :to => @@tmp_destfs)
        return Marshal.load(File.open(@@tmp_destfs))
      end
    end
    
    def Samba.backup(srcDir,destRel)
      @server.mkdir( destRel ) unless @server.exist?( destRel )
      @server.put(srcDir,destRel)
    end
    
  end
end
