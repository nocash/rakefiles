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

Project = Struct.new(:name) do
  def dir_name
    name
      .downcase
      .tr("^-_ 0-9a-z", "")
      .tr(" ", "-")
  end
end
