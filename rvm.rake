namespace :rvm do
  task :default => [".ruby-version", ".ruby-gemset"]

  task :gitignore do
    ignore_files = [".ruby-version", ".ruby-gemset"]
    File.open(Git::IGNORE_FILE, "a") { |f| f.puts ignore_files }
  end

  task :templates => [".ruby-version", ".ruby-gemset"] do
    source_files = FileList[".ruby-*"]
    source_files.each { |f| cp f, f.pathmap(Rvm::MAP_CONFIG_TO_TEMPLATE) }
  end

  namespace :templates do
    task :reverse do
      source_files = FileList["ruby-*.template"]
      source_files.each { |f| cp f, f.pathmap(Rvm::MAP_TEMPLATE_TO_CONFIG) }
    end
  end
end
task :rvm => "rvm:default"

task ".ruby-version", [:ruby] do |t, args|
  content = args[:ruby] || current_rvm.ruby
  rvm_file = rvm_file(".ruby-version")

  rvm_file.open("w") { |f| f.puts content }
end

task ".ruby-gemset", [:gemset] do |t, args|
  content = args[:gemset] || ""
  rvm_file = rvm_file(".ruby-gemset")

  if content.empty?
    next unless current_rvm.gemset?
    content = current_rvm.gemset
  end

  rvm_file.open("w") { |f| f.puts content }
end

def current_rvm
  Rvm.current
end

def rvm_file(name)
  Rvm.use_file(name)
end

module Rvm
  MAP_TEMPLATE_TO_CONFIG = ".%X"
  MAP_CONFIG_TO_TEMPLATE = "%{^.,}f.template"

  def self.current
    @current ||= RvmUseRuby.new(`rvm current`)
  end

  def self.use_file(name)
    RvmUseRubyFile.new(name)
  end
end

RvmUseRuby = Struct.new(:version) do
  def to_a
    version.chomp.split("@")
  end

  def ruby
    to_a[0]
  end

  def gemset
    to_a[1] || ""
  end

  def gemset?
    !gemset.empty?
  end
end

RvmUseRubyFile = Struct.new(:name) do
  def ruby?
    name.match(/-version/)
  end

  def gemset?
    name.match(/-gemset/)
  end

  def open(mode = "r", &block)
    File.open(name, mode, &block)
  end
end
