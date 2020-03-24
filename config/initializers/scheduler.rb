require 'unirest'
require 'twitter'
require 'rufus-scheduler'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['API_KEY']
  config.consumer_secret     = ENV['API_SEC']
  config.access_token        = ENV['ACC_TOK']
  config.access_token_secret = ENV['ACC_TOK_SEC']
end

scheduler = Rufus::Scheduler.new
refresher = Rufus::Scheduler.new

last_post = {:id => ""}
scheduler.every '1h' do
  response = Unirest.get("https://www.reddit.com/r/CryptoCurrency/hot/.json")

  posts = response.body["data"]["children"]

  posts.delete_if {|post| post["title"].includes? 'Daily Discussion' }

  newest_post = posts.shuffle.first["data"]

  tweet = "#{newest_post["title"]} + #{newest_post["url"]} #bitcoin #cryptocurrency #crypto"

  if newest_post["id"] != last_post["id"]
    client.update(tweet)
  end

  last_post = newest_post
end

refresher.every '25m' do
  Unirest.get('https://redditcryptobot.herokuapp.com')
  puts "refreshed!!"
end