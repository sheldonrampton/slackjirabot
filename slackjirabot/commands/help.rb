class << SlackRubyBot::Commands::HelpCommand
  alias_method :old_general_text, :general_text
  def general_text
    bot_desc = SlackRubyBot::CommandsHelper.instance.bot_desc_and_commands
    other_commands_descs = SlackRubyBot::CommandsHelper.instance.other_commands_descs
    <<TEXT
#{bot_desc.join("\n")}

*Commands:*
#{other_commands_descs.join("\n")}

For a detailed description of each command use: *help <command>*

Many commands use a "settings-list." For an explanation, use: *help settings-list*
TEXT
  end
end
