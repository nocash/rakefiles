namespace :git do
  task :sort_ignored do
    ignore_file = Git::IGNORE_FILE
    entries = File.readlines(ignore_file)
    sorted_entries = entries.sort.uniq

    File.open(ignore_file, "w") do |f|
      sorted_entries.each { |e| f.puts e }
    end
  end
end

module Git
  IGNORE_FILE = ".gitignore"
end
