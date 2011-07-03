CoverMe.config do |c|
  c.project.root = Dir.pwd
  c.at_exit = proc {} # default hook opens coverage/ folder, ANNOYING!
end
