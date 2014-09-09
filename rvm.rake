namespace :rvm do
  task :versions => ["ruby-version.template", "ruby-gemset.template"] do
    templates = FileList.new("ruby-*.template")
    templates.each { |f| cp f, f.pathmap(".%X") }
  end

  task :gitignore do
    ignore_files = [".ruby-version", ".ruby-gemset"]
    File.open(Git::IGNORE_FILE, "a") { |f| f.puts ignore_files }
  end
end

rule /^ruby-(version|gemset)\.template/ do |t|
  template = RvmUseFile.new(t.name)
  content = template.ruby? ? current_rvm.ruby : current_rvm.gemset

  next if content.empty?
  puts "#{template.name}: #{content}"
  File.open(t.name, "w") { |f| f.puts content }
end

def current_rvm
  Rvm.current
end

module Rvm
  def self.current
    @current ||= RvmCurrent.new(`rvm current`)
  end
end

RvmCurrent = Struct.new(:current_rvm) do
  def to_a
    current_rvm.chomp.split("@")
  end

  def ruby
    to_a[0]
  end

  def gemset
    to_a[1] || ""
  end
end

RvmUseFile = Struct.new(:name) do
  def ruby?
    name.match(/-version/)
  end

  def gemset?
    name.match(/-gemset/)
  end
end
