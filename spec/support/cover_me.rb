if defined?(CoverMe)
  CoverMe.config do |c|
    c.project.root = Dir.pwd
    c.at_exit      = proc {} # default hook opens coverage/ folder, ANNOYING!
    c.file_pattern = [%r"#{c.project.root}/lib/.+\.rb"]
  end
end
