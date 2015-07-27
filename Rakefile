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

desc 'Push final site to gh-pages...'
task :deployghpages => :buildfinal do
  Dir.chdir('_site'){
    sh "git init"
    sh "git add ."
    sh "git commit -m 'Update documentation'"
    update_remote_ghpages
  }
end

desc "Travis CI task..."
task :travis do
  Dir.chdir('_site'){
    sh "git init"
    sh "git config user.name 'Mr. Barabashka'"
    sh "git config user.email 'barabashka@eltrino.com'"
    sh "git add ."
    sh "git commit -m 'Update documentation'"
    sh 'git config credential.helper "store --file=.git/credentials"'
    File.open('.git/credentials', 'w') do |f|
      f.write("https://#{ENV['GH_TOKEN']}:@github.com")
    end
    update_remote_ghpages
  }
end

desc 'Run server'
task :run do
  print "> Starting jekyll...\n"
  sh 'jekyll serve --watch'
end

def update_remote_ghpages
  sh "git remote add origin " + @config['repository']
  sh "git push origin master:gh-pages --force"
end
