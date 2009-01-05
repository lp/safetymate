class Hashfs
  module Cleanfs
    
    def Cleanfs.cleanSpecial(root,fs)
      toClean = ['/pref', '/Safety.rb']
      toClean.each do |relPath|
        absPath = HashfsUtils.abs_root(root,relPath)
        if File.exist?(absPath)
          digest = HashfsUtils.file_digest(absPath)
          fs.delete( HashfsUtils.uKey( relPath, digest ))
        end
      end
      return fs
    end

    def Cleanfs.dupl?(k,duplKeys,oldfs)
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

    def Cleanfs.killdupl(root,fs,oldfs)
      simple_fs = Hash.new
      fs.each { |k,v| simple_fs[k] = v[:relPath] }
      if Cleanfs.has_dupl(simple_fs)
        duplKeys = Cleanfs.get_dupl(simple_fs)
        fs.delete_if { |k,v| Cleanfs.dupl?(k,duplKeys,oldfs) }
      end
      return fs
    end

    def Cleanfs.has_dupl(hash)
      array = hash.values
      if array.hash == array.uniq.hash
        return false
      else
        return true
      end
    end

    def Cleanfs.get_dupl(hash)
      duplKeys = Array.new
      hashCopy = Marshal.load(Marshal.dump(hash))
      hashCopy.each do |k,v|
        hashCopy.delete(k)
        if hashCopy.has_value?(v)
          duplKeys << k
        end
      end
      return duplKeys
    end
    
  end
end