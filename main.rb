# frozen_string_literal: true

require "discordrb"
require "json"

begin
  allows = JSON.load(File.open("./pin_allow.json", "r"))["allows"]
rescue StandardError => e
  puts e
end

bot = Discordrb::Commands::CommandBot.new token: ENV["DISCORD_BOT_DISPATCH_TOKEN"], prefix: "-"

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

    content = event.message.content
    event.user.pm(">>> #{content}")
  end
end

bot.command :delete_all do |event|
  next unless event.channel.type == 1

  token = "Bot #{ENV["DISCORD_BOT_DISPATCH_TOKEN"]}"
  result = Discordrb::API::Channel.messages(token, event.channel.id, 30)
  messages = JSON.load(result)
  messages.each do |message|
    if message["author"]["username"] == "greeting"
        Discordrb::API::Channel.delete_message(token, event.channel.id, message["id"])
    end
  end
end

bot.run
