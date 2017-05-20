module SlackJiraBot
  class TicketList
  	attr_accessor :tickets

    # Create the object
    def initialize(textin = "")
      @tickets = textin.split(",")
      @tickets.each_with_index {|val, index| @tickets[index] = val.strip.upcase}
    end
  end
end
