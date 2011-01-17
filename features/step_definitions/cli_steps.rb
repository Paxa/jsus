When /^I run "jsus (.*?)"$/ do |args|
  Dir.chdir DATA_DIR do
    `jsus #{args}`
  end  
end

Then /^the following files should exist:$/ do |table|
  Dir.chdir DATA_DIR do
    table.raw.each do |item|
      filename = item[0]
      File.exists?(filename).should be_true
    end
  end
end

Then /^file "(.*?)" should contain$/ do |filename, content|
  Dir.chdir DATA_DIR do
    File.read(filename).should include(content)
  end    
end
