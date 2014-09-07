namespace :git do
  task :sort_ignored do
    entries = File.readlines(ignore_file)
    sorted_entries = entries.sort.uniq

    File.open(Git::IGNORE_FILE, "w") do |file|
      sorted_entries.each { |e| file.puts e }
    end
  end
end

module Git
  IGNORE_FILE = ".gitignore"
end
