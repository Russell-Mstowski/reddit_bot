require 'unirest'
require 'json'
require 'typhoeus'
require 'oauth'
require 'oauth/request_proxy/typhoeus_request'

# The code below sets the consumer key and secret from your environment variables
# To set environment variables on Mac OS X, run the export command below from the terminal:
# export CONSUMER_KEY='YOUR-KEY', CONSUMER_SECRET='YOUR-SECRET'
consumer_key        = ENV['API_KEY']
consumer_secret     = ENV['API_SEC']
access_token        = ENV['ACC_TOK']
access_token_secret = ENV['ACC_TOK_SEC']

# Create tweet URL
create_tweet_url = "https://api.twitter.com/2/tweets"

# Pull Reddit posts
response = Unirest.get("https://www.reddit.com/r/CryptoCurrency/hot/.json")

posts = response.body["data"]["children"]

posts.delete_if { |post| post["data"]["title"].include? 'Daily Discussion' }

newest_post = posts.shuffle.first["data"]

tweet = "[NEW] #{newest_post["title"]} + #{newest_post["url"]} #bitcoin #btc #cryptocurrency #crypto #blockchain #eth"

# Be sure to add replace the text of the with the text you wish to Tweet.
# You can also add parameters to post polls, quote Tweets, Tweet with reply settings, and Tweet to Super Followers in addition to other features.
@json_payload = {"text": tweet}

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
request = Typhoeus::Request.new(create_tweet_url, options)

access_token = OAuth::Token.new(token, token_secret)
oauth_params = {:consumer => consumer, :token => access_token}

oauth_helper = OAuth::Client::Helper.new(request, oauth_params.merge(:request_uri => create_tweet_url))

request.options[:headers].merge!({"Authorization" => oauth_helper.header}) # Signs the request
response = request.run
puts response
