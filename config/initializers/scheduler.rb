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
count = 0
scheduler.every '4h' do
  response = Unirest.get("https://www.reddit.com/r/CryptoCurrency/hot/.json")

  posts = response.body["data"]["children"]

  newest_post = posts.first["data"]

  tweet = "[NEW]: #{newest_post["title"]} + https://www.reddit.com#{newest_post["permalink"]} #cryptocurrency #crypto #blockchain"

  if newest_post["id"] != last_post["id"]
    client.update(tweet)
    puts "#{count}: I tweeted!!!!!!!!! + #{newest_post["title"]}"
  end

  last_post = newest_post
  count += 1
end

refresher.every '10m' do
  Unirest.get('https://redditcryptobot.herokuapp.com')
  puts "refreshed!!"
end