require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    vowels = ["A", "E", "U", "I", "O"]

    grid = ("A".."Z").to_a.shuffle[2...grid_size]

    (0..1).to_a.each { grid.push(vowels.sample) }

    return grid.shuffle
  end

  def not_cheating(attempt, grid)
    # check if the user is using letters from the grid only
    temp = grid.split(" ").join.downcase.chars.tally

    attempt.downcase.chars.tally.each do |letter, count|
      return false if !temp[letter] || count > temp[letter] || !temp.include?(letter)
    end
    return true
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result (with `:score`, `:message` and `:time` keys)
    result = { score: 0, message: "Sorry but #{attempt} does not seem to be a valid english word...", time: 0 }
    url = "https://wagon-dictionary.herokuapp.com/#{attempt.downcase}"

    dict_result = JSON.parse(URI.open(url).read)

    result[:time] = end_time - start_time

    if dict_result['found'] && dict_result && not_cheating(attempt, grid)
      result[:score] = (dict_result["length"] * 150.fdiv(end_time - start_time)).round(2)
      session[:score] = session[:score] || 0
      session[:score] += result[:score]
      result[:message] = "Congratulations! #{attempt.upcase} is a valid english word!"
    end
    result[:message] = "Sorry #{attempt} can't be built out of #{grid}" if dict_result['found'] && dict_result && !not_cheating(attempt, grid)
    return result
  end

  def new
    @letters = generate_grid(10)
    @start_time = Time.now
  end

  def score
    @end_time = Time.now
    @response = run_game(params[:user_word], params[:letters], Time.parse(params[:start_time]), @end_time)
  end
end
