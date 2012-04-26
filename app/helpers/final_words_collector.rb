module FinalWordsCollector
  FINAL_WORDS_MAX_LENGTH = 100

  def final_words
    display_title[0...FINAL_WORDS_MAX_LENGTH]
  end

end