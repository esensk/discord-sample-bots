# frozen_string_literal: true

require "discordrb"
require "json"

begin
  allows = JSON.load(File.open("./pin_allow.json", "r"))["allows"]
rescue StandardError => e
  puts e
end

bot = Discordrb::Commands::CommandBot.new token: ENV["DISCORD_BOT_DISPATCH_TOKEN"], prefix: "-"
token = "Bot #{ENV["DISCORD_BOT_DISPATCH_TOKEN"]}"

bot.reaction_add do |event|
  # DM channel type
  if event.channel.type == 1
    if event.emoji.name == "🆗"
      content = event.message.content
      event.message.edit("~~#{content}~~")
    end

    if event.emoji.name == "⭕"
      event.message.delete
    end

    return
  end

  allows.each do |allow|
    next unless (allow["channel"] == "all" || event.channel.id == allow["channel"].to_i) && (event.emoji.name == allow["emoji"])

    result = Discordrb::API::User.create_pm(token, event.user.id)
    channel_id = JSON.load(result)["id"]

    embeds = event.message.embeds
    if embeds.length < 1
      Discordrb::API::Channel.create_message(token, channel_id,">>> #{event.message.content}")
      break
    end

    embedObj = embeds[0]
    embedJson = JSON.load(File.open("./embed.json"))["embed"]
    embedJson["title"] = embedObj.title
    embedJson["color"] = embedObj.color
    embedJson["description"] = embedObj.description
    embedJson["author"]["name"] = embedObj.author.name
    embedJson["author"]["url"] = embedObj.author.url
    embedJson["author"]["icon_url"] = embedObj.author.icon_url
    embedJson["footer"]["text"] = embedObj.footer.text
    embedJson["footer"]["icon_url"] = embedObj.footer.icon_url
    Discordrb::API::Channel.create_message(token, channel_id, embedObj.message, false, embedJson)
  end
end

bot.command :delete_all do |event|
  next unless event.channel.type == 1

  result = Discordrb::API::Channel.messages(token, event.channel.id, 30)
  messages = JSON.load(result)
  messages.each do |message|
    if message["author"]["username"] == "greeting"
        Discordrb::API::Channel.delete_message(token, event.channel.id, message["id"])
    end
  end
end

bot.run
