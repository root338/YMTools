
require 'fileutils'

class FileE
  def self.mkdir(path, removeLast = false)
    path = File.expand_path(path)
    dir = path
    if removeLast
      dir = File.dirname(path)
    end
    unless File.exist?(dir) && File.directory?(dir)
      FileUtils.mkdir_p(dir)
    end
    return path
  end
end
