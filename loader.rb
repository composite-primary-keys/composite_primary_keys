# Load local config files in /local
begin
  local_file_supported = %w[paths tasks database_connections]
  local_file_supported.each do |file|
    require "local/#{file}"
  end
rescue LoadError
  puts <<-EOS
  This Gem supports local developer extensions in local/ folder. 
  Supported files:
    #{local_file_supported.map { |f| "local/#{f}"}.join(', ')}
  Samples available:
    #{local_file_supported.map { |f| "cp local/#{f}.rb.sample local/#{f}.rb"}.join("\n    ")}

  Current error: #{$!}
  
  EOS
end


# Now load Rake tasks from /tasks
rakefiles = Dir[File.join(File.dirname(__FILE__), "tasks/**/*.rake")]
rakefiles.each { |rakefile| load File.expand_path(rakefile) }
