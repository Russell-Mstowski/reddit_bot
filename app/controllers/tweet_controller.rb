class TweetController < ApplicationController
    def tweet
        client = Twitter::REST::Client.new do |config|
            config.consumer_key        = ENV['API_KEY']
            config.consumer_secret     = ENV['API_SEC']
            config.access_token        = ENV['ACC_TOK']
            config.access_token_secret = ENV['ACC_TOK_SEC']
        end
        
        response = Unirest.get("https://www.reddit.com/r/CryptoCurrency/hot/.json")
        
        posts = response.body["data"]["children"]
        
        newest_post = posts.shuffle.first["data"]
        
        tweet = "#{newest_post["title"]} + https://www.reddit.com#{newest_post["permalink"]} #cryptocurrency #crypto #blockchain"
        
        client.update(tweet)
    end
end
