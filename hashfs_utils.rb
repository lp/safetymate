module HashfsUtils
  
  def HashfsUtils.file_digest(path)
    Digest::SHA1.hexdigest( File.open(path).gets )
  end
  
  def HashfsUtils.rel_root(root, path)
    path.gsub(/#{root}(.*)/, "\\1")
  end
  
  def HashfsUtils.abs_root(root, path)
    root + path
  end
  
  def HashfsUtils.uKey(path, hashes)
    "#{path}-#{hashes}".to_sym
  end
  
end