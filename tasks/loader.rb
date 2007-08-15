rakefiles = Dir[File.join(File.dirname(__FILE__), "/*.rake")]
rakefiles.each { |rakefile| load File.expand_path(rakefile) }