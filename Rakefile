require 'yaml'

file = YAML::load(File.open('_config.yml'))
if file['documentation'] then
  config = file['documentation']
else
  raise "No configuration defined."
end

task :default => :run

desc 'Build final site...'
task :buildfinal do
  if Dir.exist?('.repository')
    print "Unclean build. Remove .repository and other folders to proceed!\n"
    exit
  end
  sh 'git clone ' + config['repository'] + ' .repository'
  Dir.chdir('.repository'){
    branches = `git branch -r | grep -v HEAD`.split
    branches.each do |branch_full|
      remote, branch = branch_full.split("/")
      next if config['ignore'].include? branch

      if branch.include? "-"
        name, language = branch.split("-")
      else
        name = branch
        language = "en"
      end
      name = config['alias'][name] if config['alias'].has_key? name
      target = File.join("..", language, name)
      sh "mkdir -p " + target
      sh "git archive " + branch_full + " | tar -x -C " + target
    end
  }
  sh "jekyll build"
end

desc "Turn on production mode ..."
task :production do
  file = YAML::load(File.open('_config.yml'))
  file['mode'] = 'production'
  File.open("_config.yml", 'w') { |f| YAML.dump(file, f) }
end

desc 'Run server'
task :run do
  print "> Starting jekyll...\n"
  sh 'jekyll serve --watch'
end
