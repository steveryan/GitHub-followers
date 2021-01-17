class FollowersController < ApplicationController

  def index
    username = params[:username]
    rest_url = "https://api.github.com/users/#{username}/followers?per_page=100"
    graphql_url = "https://api.github.com/graphql"
    @random_choice = ['rest','graphql'].sample
    if @random_choice == 'rest'
      starting_time = Time.now
      get_followers_rest(rest_url)
      ending_time = Time.now
      @total_time = ending_time - starting_time
    else
      starting_time = Time.now
      get_followers_graphql(graphql_url, username)
      ending_time = Time.now
      @total_time = ending_time - starting_time
    end
  end
  def new
  end

  private

  def get_followers_graphql(url, username, cursor = nil)
    body = {"query": "{ user(login: \"#{username}\") { followers(first: 100#{", after: \"#{cursor}\"" if cursor}){ nodes{login, url, avatarUrl}, pageInfo{endCursor, hasNextPage} } } } "}
    headers = { 'Accept': 'application/vnd.github.v3+json', 'Authorization': "Bearer #{ENV['GITHUB_API_TOKEN']}"}
    options = { followlocation: true, "body": body.to_json, "headers": headers }
    response = HTTParty.post(url, options)
    @followers = @followers ? @followers + response.parsed_response.dig('data', 'user', 'followers', 'nodes') : response.parsed_response.dig('data', 'user', 'followers', 'nodes')
    page_info = response.parsed_response.dig('data', 'user', 'followers', 'pageInfo')
    if page_info['hasNextPage'] == true
      cursor = page_info['endCursor']
      get_followers_graphql(url, username, cursor)
    end
  end

  def get_followers_rest(url)
    response = HTTParty.get(url, headers: { 'Accept' => 'application/vnd.github.v3+json', 'Authorization' => "Bearer #{ENV['GITHUB_API_TOKEN']}"})
    @followers = @followers ? @followers + JSON.parse(response.body).map{ |f| f.slice('login', 'html_url', 'avatar_url')} : JSON.parse(response.body).map{ |f| f.slice('login', 'html_url', 'avatar_url')}
    if response.headers[:link]&.include?('rel="next"')
      next_page_url = response.headers[:link].match(/.*<(\S*)>; rel="next"/)[1]
      get_followers_rest(next_page_url)
    end
  end

end
