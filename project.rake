namespace :project do
  task :default => :new

  task :new, [:name] do |t, args|
    project = Project.new(args[:name])

    mkdir project.dir_name
    chdir project.dir_name
    sh "git init"

    Rake::Task["rvm:templates"].invoke
    Rake::Task["rvm:gitignore"].invoke
  end
end
task :project, [:name] => "project:default"

task "Gemfile", [:gem] do |t, args|
  gem = args[:gem] || ''
  gemfile = gemfile("Gemfile")

  gemfile.create unless gemfile.exists?
  gemfile.add_gem gem unless gem.empty?
end

def gemfile(name)
  Gemfile.new(name)
end

Project = Struct.new(:name) do
  def dir_name
    name
      .downcase
      .tr("^-_ 0-9a-z", "")
      .tr(" ", "-")
  end
end

Gemfile = Struct.new(:name) do
  def exists?
    File.exists?(name)
  end

  def create
    write %Q(source "https://rubygems.org"\n\n)
  end

  def add_gem(name)
    append %Q(gem "#{name}")
  end

  def append(content)
    File.open(name, "a") { |f| f.puts content }
  end

  def write(content)
    File.open(name, "w") { |f| f.puts content }
  end
end
