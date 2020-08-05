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
    next unless (event.channel.id == allow["channel_id"]) && (event.emoji.name == allow["emoji"])

    content = event.message.content
    event.user.pm(">>> #{content}")
  end
end

bot.command :delete do |event|
  next unless event.channel.type == 1

  messages = Discordrb::API::Channel.messages("Bot #{ENV["DISCORD_BOT_DISPATCH_TOKEN"]}", event.channel.id, 30)
  puts event.channel.message
  event.channel.delete_messages(messages)
end

bot.run
