class Hashfs
  module Local
    
    def Local.scan_fs(root)
      fs = Hash.new
      Find.find(root) do |path|
        unless File.directory?(path)
          unless File.zero?(path)
            digest = HashfsUtils.file_digest(path)
            relPath = HashfsUtils.rel_root(root, path)
            fs[ HashfsUtils.uKey( relPath, digest ) ] = { :oriPath => path, 
                                                            :relPath => relPath, 
                                                            :bit => File.size(path)
                                                          }
          end
        end
      end
      return Cleanfs.cleanSpecial(root,fs)
    end
    
    def Local.load(root)
      makedirs(root) unless File.exist?(root)
      path = root + DATANAME
      if File.exist?(path)
        return Marshal.load(File.open(path))
      else
        hashfs = Hashfs.new(root)
        hashfs.scan
        return hashfs
      end
    end
    
    def Local.backup(srcDir,destRoot,destRel)
      destDir = HashfsUtils.abs_root(destRoot, destRel)
      dir = File.dirname(destDir)
      File.makedirs( dir ) unless File.exist?( dir )
      File.copy(srcDir,destDir)
    end
    
  end
end