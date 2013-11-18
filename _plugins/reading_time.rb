module ReadingTime
  
  # Uses a crappy 'words per minute' heuristic to estimate the reading time of a post.
  # 
  # Usage:
  #    <span>Estimated reading time: {{ content | reading_time }}</span>
  #
  def reading_time(input)
    word_count = input.gsub(/<\/?[^>]*>/, "").split.size
    reading_time_in_seconds = (word_count / 250).round(0)
    reading_time_in_seconds
  end
  
  Liquid::Template.register_filter self
  
end