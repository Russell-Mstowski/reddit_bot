require 'unirest'
require 'rufus-scheduler'
require 'json'
require 'typhoeus'
require 'oauth'
require 'oauth/request_proxy/typhoeus_request'

consumer_key        = ENV['API_KEY']
consumer_secret     = ENV['API_SEC']
acc_token           = ENV['ACC_TOK']
acc_token_secret    = ENV['ACC_TOK_SEC']

scheduler = Rufus::Scheduler.new
refresher = Rufus::Scheduler.new

consumer = OAuth::Consumer.new(consumer_key, consumer_secret, :site => 'https://api.twitter.com')

options = {
  :method => :post,
  headers: {
    "User-Agent": "v2CreateTweetRuby",
    "content-type": "application/json"
  },
  body: JSON.dump(@json_payload)
}
create_tweet_url = "https://api.twitter.com/2/tweets"

last_post = {:id => ""}
scheduler.every '1h' do
  response = Unirest.get("https://www.reddit.com/r/CryptoCurrency/hot/.json")

  posts = response.body["data"]["children"]

  posts.delete_if { |post| post["data"]["title"].include? 'Daily Discussion' }

  newest_post = posts.shuffle.first["data"]

  tweet = "[NEW] #{newest_post["title"]} + #{newest_post["url"]} #bitcoin #btc #cryptocurrency #crypto #blockchain #eth"

  if newest_post["id"] != last_post["id"]
    @json_payload = {"text": tweet}
    
    request = Typhoeus::Request.new(create_tweet_url, options)

    access_token = OAuth::Token.new(acc_token, acc_token_secret)
    oauth_params = {:consumer => consumer, :token => access_token}

    oauth_helper = OAuth::Client::Helper.new(request, oauth_params.merge(:request_uri => create_tweet_url))

    request.options[:headers].merge!({"Authorization" => oauth_helper.header}) # Signs the request
    response = request.run
  end

  last_post = newest_post
end

refresher.every '25m' do
  Unirest.get('https://redditcryptobot.herokuapp.com')
  puts "refreshed!!"
end
