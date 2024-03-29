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
create_tweet_url = "https://api.twitter.com/2/tweets"

def get_new_post()
  response = Unirest.get("https://old.reddit.com/r/CryptoCurrency/hot/.json")

  posts = response.body["data"]["children"]

  posts.delete_if { |post| post["data"]["title"].include? 'Daily Discussion' }

  posts.shuffle.first["data"]
end

def format_tweet(new_post)
  "[NEW] #{new_post["title"]} + #{new_post["url"]} #bitcoin #btc #cryptocurrency #crypto #blockchain #eth"
end

last_post = {:id => ""}
scheduler.every '1h' do
  new_post = get_new_post()

  if new_post["id"] != last_post["id"]
    @json_payload = {"text": format_tweet(new_post)}
    puts @json_payload

    options = {
      :method => :post,
      headers: {
        "User-Agent": "v2CreateTweetRuby",
        "content-type": "application/json"
      },
      body: JSON.dump(@json_payload)
    }
    
    request = Typhoeus::Request.new(create_tweet_url, options)

    access_token = OAuth::Token.new(acc_token, acc_token_secret)
    oauth_params = {:consumer => consumer, :token => access_token}

    oauth_helper = OAuth::Client::Helper.new(request, oauth_params.merge(:request_uri => create_tweet_url))

    request.options[:headers].merge!({"Authorization" => oauth_helper.header}) # Signs the request
    response = request.run
    puts "I should have tweeted!!"
  end

  last_post = new_post
end

refresher.every '25m' do
  Unirest.get('https://redditcryptobot.herokuapp.com')
  puts "refreshed!!"
end
