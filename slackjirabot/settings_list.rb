require 'date'

module SlackJiraBot
  class SettingsList
  	attr_accessor :settings, :fields, :matched_items, :unmatched_items, :links, :substitutions, :version

    # Status requires a "transition," not a "field." "status" => "status",
    # https://docs.atlassian.com/jira/REST/cloud/#api/2/issue-doTransition

    # Create the object
    def initialize(textin = "")
      synonyms = {
        "assignee" => "assignee",
        "reporter" => "reporter",
        "description" => "description",
        "title" => "summary",
        "summary" => "summary",
        "duedate" => "duedate",
        "due" => "duedate",
        "due date" => "duedate",
        "due-date" => "duedate",
        "scrumteam" => "customfield_11850",
        "scrum team" => "customfield_11850",
        "team" => "customfield_11850",
        "stage date" => "customfield_12451",
        "stage test date" => "customfield_12451",
        "stage test" => "customfield_12451",
        "prod test" => "customfield_12654",
        "prod test date" => "customfield_12654",
        "production test date" => "customfield_12654",
        "prod date" => "customfield_12654",
        "production date" => "customfield_12654",
        "client" => "customfield_13050",
        "nucivic client" => "customfield_13050",
        "priority" => "priority",
        "version" => "fixVersions",
        "fixVersions" => "fixVersions",
        "points" => "customfield_10003",
        "story points" => "customfield_10003",
        "customfield_10003" => "customfield_10003",
      }
      # For creating links to other tickets.
      link_types = {
        "Blocks" => {"inward"=>"is blocked by", "outward"=>"blocks",},
        "Bonfire Testing" => {"inward"=>"discovered while testing", "outward"=>"testing discovered",},
        "Caused" => {"inward"=>"causes", "outward"=>"is caused by",},
        "Causes" => {"inward"=>"is caused by", "outward"=>"causes",},
        "Cloners" => {"inward"=>"is cloned by", "outward"=>"clones",},
        "Duplicate" => {"inward"=>"is duplicated by", "outward"=>"duplicates",},
        "Relates" => {"inward"=>"relates to", "outward"=>"relates to",},
        "Tested" => {"inward"=>"tests", "outward"=>"is tested by",},
      }
      matchable_link_types = {}
      link_types.each do |key, val|
        matchable_link_types[val['outward']] = {'type' => key, 'direction' => 'outward'}
        matchable_link_types[val['inward']] = {'type' => key, 'direction' => 'inward'}
      end

      # Initialize object's accessible values.
      @matched_items = {}
      @unmatched_items = {}
      @links = {}
      @substitions = {}
      @version = ''

      # Iterate over the input and assign values to the accessible values.
      @settings = textin.split(";")
      @settings.each do |setting|
        keypair = setting.split("=", 2)
        if (keypair.length == 1)
          keypair = setting.split(":", 2)
        end
        mykey = keypair[0].strip.downcase
        val = ''
        if (keypair.length == 2)
          val = keypair[1].strip
        end
        # Add items to list of settings.
        if synonyms.key?(mykey)
          @matched_items = @matched_items.merge({synonyms[mykey] => val})
        # Add items to list of links to be created.
        elsif matchable_link_types.key?(mykey)
          if val != ''
            @links = @links.merge({matchable_link_types[mykey]['type'] => {
              'ticket' => val,
              'direction' => matchable_link_types[mykey]['direction'],
            }})
          end
        # Add everything else to list of unmatched items.
        else
          @unmatched_items = @unmatched_items.merge({mykey => val})
        end
      end
      @fields = {}
      @matched_items.each do |key, val|
        field = {}
        case key
        when "assignee"
          if (val == "unassigned" || val == "")
            name = ["-1"]
          else
            name = val.split
            if (name.length > 1)
              # Only use the first initial of the first name
              name[0] = name[0][0]
            end
          end
          field = {key => {"name" => name.join.downcase}}
        when "reporter"
          name = val.split
          if (name.length > 1)
            # Only use the first initial of the first name
            name[0] = name[0][0]
          end
          field = {key => {"name" => name.join.downcase}}
        when "duedate"
          field = {key => american_date(val)}
        # Stage test date
        when "customfield_12451"
          field = {key => american_date(val)}
        # Production test date
        when "customfield_12654"
          field = {key => american_date(val) + "T15:00:00.000-0600"}
        # Scrum team
        when "customfield_11850"
          field = {key => {"value" => val}}
        when "customfield_10003"
          field = {key => val.to_i}
        when "status"
          field = {key => {"name" => val}}
        # Options are Low, Medium, High, Urgent, Critical
        when "priority"
          field = {key => {"name" => val}}
        when "fixVersions"
          # Standardize the version string and save it separately for easy access.
          @version = val.scan(/\s*(DKAN\s*)?(7.x-)?(.*)\s*/).to_a.flatten[2].strip
          field = {key => [{"name" => @version}]}
        else
          field = {key => val}
        end
        @fields = @fields.merge(field)
      end
    end

    def american_date(date_string)
      if (date_string != "")
        date_array = date_string.split("/")
        if (date_array.length == 3)
          date_string = "#{date_array[1]}/#{date_array[0]}/#{date_array[2]}"
        end
        Date.parse(date_string).to_s
      else
        ""
      end
    end
  end
end
