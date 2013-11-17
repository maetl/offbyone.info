class String
  def parameterize
    string = self.clone
    string.gsub! /[^[:alnum:]\-\s\_]/, '' # Remove all characters except alphanumeric, spaces, dashes and underscores
    string.gsub! /(\s|_)+/, '-'           # Replace spaces and underscores by dashes

    # Replace camelcase string to dash separated
    string.gsub! /([A-Z]+)([A-Z][a-z])/, '\1-\2'
    string.gsub! /([a-z\d])([A-Z])/, '\1-\2'

    string.downcase!
    string    
  end
end

task :post do
  if ENV.has_key? "title"
    title = ENV["title"]
  else
    title = "New Post"
  end
  
  if ENV.has_key? "link"
    layout = "link"
  else
    layout = "post"
  end

  if ENV.has_key? "category"
    category = ENV["category"]
  else
    category = "culture"
  end
  
  date = Time.now.strftime("%Y-%m-%d")
  File.open("_posts/#{(date + '-' + title).parameterize}.md", "w") do |file|
    file.puts <<-eos
---
layout: #{layout}
title: #{title}
description: A description
category: #{category}
link: 
image:
  credit:
  creditlink:
  feature:
---

Someone must have slandered Josef K., for one morning, without having done anything truly wrong, he was arrested.

      eos
  end
end