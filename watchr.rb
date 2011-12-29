ENV["WATCHR"] = "1"
puts "\n### Watching ... ###\n"

def growl(message)
  growlnotify = `which growlnotify`.chomp
  title = "Watchr Test Results"
  image = message.include?('0 failures, 0 errors') ? "~/.watchr/passed.png" : "~/.watchr/failed.png"
  options = "-w -n Watchr --image '#{File.expand_path(image)}' -m '#{message}' '#{title}'"
  system %(#{growlnotify} #{options} &)
end

def run(cmd)
  puts(cmd)
  system(cmd)
end

def run_test_file(file)
  result = run("rake test TEST=#{file}")
  growl result.split("\n").last rescue nil
  puts result 
end

def run_all_tests
  result = run("rake test")
  growl result.split("\n").last rescue nil
  puts result
end


def related_test_files(path)
  Dir['test/**/*.rb'].select { |file| file =~ /#{File.basename(path).split(".").first}_test.rb/ }
end

def run_suite
  run_all_tests
  run_all_features
end

watch('test/test_helper\.rb') { run_all_tests }
watch('test/.*/.*_test\.rb') { |m| run_test_file(m[0]) }
watch('app/.*/.*\.rb') { |m| related_test_files(m[0]).map {|tf| run_test_file(tf) } }
watch('features/.*/.*\.feature') { run_all_features }

# Ctrl-\
Signal.trap 'QUIT' do
  puts " --- Running all tests ---\n\n"
  run_all_tests
end

@interrupted = false

# Ctrl-C
Signal.trap('INT') { abort("\n") }

