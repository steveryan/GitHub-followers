class FollowersController < ApplicationController

  def index
    username = params[:username]
    rest_url = "http://api.github.com/users/#{username}/followers?per_page=100"
    @random_choice = ['rest','graphql'].sample
    if @random_choice == 'rest'
      starting_time = Time.now
      get_followers_rest(rest_url)
      ending_time = Time.now
      @total_time = ending_time - starting_time
    else
      raise "Please implement the GraphQL query"
    end
  end
  def new
  end

  private

  def get_followers_rest(url)
    response = HTTParty.get(url, headers: { 'Accept' => 'application/vnd.github.v3+json', 'Authorization' => 'Bearer b63cc7693e38dc1ed376ff4561ae3adaac49e9cf'})
    @followers = @followers ? @followers + JSON.parse(response.body) : JSON.parse(response.body)
    if response.headers[:link]&.include?('rel="next"')
      next_page_url = response.headers[:link].match(/.*<(\S*)>; rel="next"/)[1]
      get_followers_rest(next_page_url)
    end
  end

end
