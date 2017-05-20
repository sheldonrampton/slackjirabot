module SlackJiraBot
  class Customer
    attr_accessor :properties

     # Create the object
    def initialize(textin = "")
      @synonyms = {
        'hhs' => 'hhs',
        'healthdata.gov' => 'hhs',
        'www.healthdata.gov' => 'hhs',
        'health & human services' => 'hhs',
        'health and human services' => 'hhs',
        'us dept of health & human services' => 'hhs',
        'us dept of health and human services' => 'hhs',
        'u.s. dept of health & human services' => 'hhs',
        'u.s. dept of health and human services' => 'hhs',
        'united states dept of health & human services' => 'hhs',
        'united states dept of health and human services' => 'hhs',
        'us department of health & human services' => 'hhs',
        'us department of health and human services' => 'hhs',
        'u.s. department of health & human services' => 'hhs',
        'u.s. department of health and human services' => 'hhs',
        'united states department of health & human services' => 'hhs',
        'united states department of health and human services' => 'hhs',
        'lky' => 'lky',
        'louisville' => 'lky',
        'louisvilleky' => 'lky',
        'data.louisvilleky.gov' => 'lky',
        'marine scotland' => 'gbsctmarinedata',
        'gbsctmarinedata' => 'gbsctmarinedata',
        'data.marine.gov.scot' => 'gbsctmarinedata',
        'sandiego' => 'sandiego',
        'san diego' => 'sandiego',
        'data.sandiego.gov' => 'sandiego',
        'cadepttech' => 'cadepttech',
        'ca dept of tech' => 'cadepttech',
        'c-dot' => 'cadepttech',
        'california' => 'cadepttech',
        'data.ca.gov' => 'cadepttech',
        'jamaica' => 'jamaica',
        'world bank jamaica' => 'jamaica',
        'world bank - jamaica' => 'jamaica',
        'wb jamaica' => 'jamaica',
        'data.gov.jm' => 'jamaica',
        'stlucia' => 'stlucia',
        'st lucia' => 'stlucia',
        'st. lucia' => 'stlucia',
        'world bank st lucia' => 'stlucia',
        'world bank - st lucia' => 'stlucia',
        'wb - st lucia' => 'stlucia',
        'world bank st. lucia' => 'stlucia',
        'world bank - st. lucia' => 'stlucia',
        'wb - st. lucia' => 'stlucia',
        'data.govt.lc' => 'stlucia',
        'gosa' => 'gosa',
        'georgia gosa' => 'gosa',
        'schoolgrades.georgia.gov' => 'gosa',
        'schoolgrades' => 'gosa',
        'ga schoolgrades' => 'gosa',
        'georgia schoolgrades' => 'gosa',
        'georgia school grades' => 'gosa',
        'georgia reports' => 'gosa',
        'georgia school reports' => 'gosa',
        'gbpw' => 'gbpw',
        'data.georgia.gov' => 'gbpw',
        'ga physicians board' => 'gbpw',
        'georgia physicians board' => 'gbpw',
        'open georgia' => 'gbpw',
        'opengeorgia' => 'gbpw',
        'opengeorgia.prod.acquia-sites.com' => 'gbpw',
        'ri' => 'ri',
        'rhode island' => 'ri',
        'prod.ri.nucivicdata.com' => 'ri',
        'data.ri.gov' => 'ri',
        'usva' => 'usva',
        'us veterans affairs' => 'usva',
        'us veteran\'s affairs' => 'usva',
        'department of veterans affairs' => 'usva',
        'department of veteran\'s affairs' => 'usva',
        'dept of veterans affairs' => 'usva',
        'dept of veteran\'s affairs' => 'usva',
        'dept. of veterans affairs' => 'usva',
        'dept. of veteran\'s affairs' => 'usva',
        'va' => 'usva',
        'deptvetaffairs' => 'usva',
        'prod.usva.nucivicdata.com' => 'usva',
        'charterschools' => 'gacharterschools',
        'charter schools' => 'gacharterschools',
        'georgia charter schools' => 'gacharterschools',
        'ga charter schools' => 'gacharterschools',
        'gacharterschools' => 'gacharterschools',
        'ga charter' => 'gacharterschools',
        'gacharter' => 'gacharterschools',
        'prod.gacharterschools.nucivicdata.com' => 'gacharterschools',
        'nd' => 'nd',
        'north dakota' => 'nd',
        'northdakota' => 'nd',
        'gis.nd.gov' => 'nd',
        'north dakota gis' => 'nd',
        'usda' => 'usda',
        'us dept of agriculture' => 'usda',
        'us department of agriculture' => 'usda',
        'united states dept of agriculture' => 'usda',
        'united states department of agriculture' => 'usda',
        'dept of agriculture' => 'usda',
        'department of agriculture' => 'usda',
        'usda nal' => 'usda',
        'data.nal.usda.gov' => 'usda'
      }

      @properties_list = {
        'cadepttech' => {
          :abbrev => 'CaDeptTech',
          :domain => 'data.ca.gov',
          :fullname => 'California Open Data Portal',
          :https => true,
          :dev_site => 'dev.cadepttech.nucivicdata.com',
          :stage_site => 'test.cadepttech.nucivicdata.com',
          :repo => 'https://github.com/NuCivic/cadepttech',
        },
        'gacharterschools' => {
          :abbrev => 'GaCharterSchools',
          :domain => 'prod.gacharterschools.nucivicdata.com',
          :fullname => 'Georgia Charter Schools',
          :https => false,
          :dev_site => '',
          :stage_site => '',
          :repo => '',
        },
        'gbpw' => {
          :abbrev => 'GBPW',
          :domain => 'data.georgia.gov',
          :fullname => 'Georgia Physicians Board',
          :https => false,
          :dev_site => 'dev.opengeorgia.nucivicdata.com',
          :stage_site => 'test.opengeorgia.nucivicdata.com',
          :repo => 'https://github.com/NuCivic/ga_gbpw',
        },
        'gbsctmarinedata' => {
          :abbrev => 'GbSctMarineData',
          :domain => 'data.marine.gov.scot',
          :fullname => 'Marine Scotland',
          :https => false,
          :dev_site => '',
          :stage_site => '',
          :repo => '',
        },
        'gosa' => {
          :abbrev => 'GOSA',
          :domain => 'schoolgrades.georgia.gov',
          :fullname => 'Georgia School Reports',
          :https => true,
          :dev_site => 'gosareportcarddev.prod.acquia-sites.com',
          :stage_site => 'gosareportcardstg.prod.acquia-sites.com',
          :repo => 'https://github.com/NuCivic/ga_reports',
        },
        'hhs' => {
          :abbrev => 'HHS',
          :domain => 'www.healthdata.gov',
          :fullname => 'U.S. Department of Health and Human Services',
          :https => true,
          :dev_site => 'healthdatagovdev.prod.acquia-sites.com',
          :stage_site => 'healthdatagovstg.prod.acquia-sites.com',
          :repo => 'https://github.com/NuCivic/healthdata',
        },
        'jamaica' => {
          :abbrev => 'Jamaica',
          :domain => 'data.gov.jm',
          :fullname => 'Jamaica Open Data Portal',
          :https => false,
          :dev_site => 'dev.ngworldbankjam.nucivicdata.com',
          :stage_site => 'test.ngworldbankjam.nucivicdata.com',
          :repo => 'https://github.com/NuCivic/ng-worldbank-caribb-jam-data',
        },
        'lky' => {
          :abbrev => 'LKY',
          :domain => 'data.louisvilleky.gov',
          :fullname => 'Louisville Metro Open Data Portal',
          :https => true,
          :dev_site => 'dev.data.louisvilleky.gov',
          :stage_site => 'stg.data.louisvilleky.gov',
          :repo => 'https://github.com/NuCivic/lky',
        },
        'nd' => {
          :abbrev => 'ND',
          :domain => 'gishubdata.nd.gov',
          :fullname => 'North Dakota GIS Hub Portal',
          :https => true,
          :dev_site => 'dev.ndgis.nucivicdata.com',
          :stage_site => 'test.ndgis.nucivicdata.com',
          :repo => 'https://github.com/NuCivic/data-northdakota',
        },
        'ri' => {
          :abbrev => 'RI',
          :domain => 'data.ri.gov',
          :fullname => 'Rhode Island Open Data Portal',
          :https => true,
          :dev_site => 'dev.ri.nucivicdata.com',
          :stage_site => 'test.ri.nucivicdata.com',
          :repo => 'https://github.com/NuCivic/client-ri-data',
        },
        'sandiego' => {
          :abbrev => 'SanDiego',
          :domain => 'data.sandiego.gov',
          :fullname => 'San Diego Open Data Portal',
          :https => false,
          :dev_site => 'dev.casandiego.nucivicdata.com',
          :stage_site => 'test.casandiego.nucivicdata.com',
          :repo => 'https://github.com/NuCivic/client-sandiego-opendata',
        },
        'stlucia' => {
          :abbrev => 'StLucia',
          :domain => 'data.govt.lc',
          :fullname => 'St. Lucia Open Data Portal',
          :https => false,
          :dev_site => 'dev.ngworldbankstl.nucivicdata.com',
          :stage_site => 'test.ngworldbankstl.nucivicdata.com',
          :repo => 'https://github.com/NuCivic/ng-worldbank-caribb-stlucia-data',
        },
        'usda' => {
          :abbrev => 'USDA',
          :domain => 'data.nal.usda.gov',
          :fullname => 'USDA Ag Data Commons',
          :https => true,
          :dev_site => '',
          :stage_site => '',
          :repo => '',
        },
        'usva' => {
          :abbrev => 'USVA',
          :domain => 'data.va.gov',
          :fullname => 'USVA Open Data Portal',
          :https => false,
          :dev_site => 'dev.usva.nucivicdata.com',
          :stage_site => 'test.usva.nucivicdata.com',
          :repo => 'https://github.com/NuCivic/client-usva-data',
        },
        nil => {
          :abbrev => 'NOT FOUND',
          :domain => '',
          :fullname => '',
          :https => false,
          :dev_site => '',
          :stage_site => '',
          :repo => '',
        }
      }
      if textin != nil
        key = @synonyms[textin.downcase]
      end
      @properties = @properties_list[key].merge({:key => key})
    end



    # Retrieves information using the Github API
    def get_github_api(project, endpoint)
      token = "9874304d5d35c105f590df83c48112ff43518fba"
      uri = URI.parse("https://api.github.com/repos/NuCivic/" + project + "/" + endpoint + '?access_token=' + token)
      request = Net::HTTP::Get.new(uri)
      req_options = {
        use_ssl: uri.scheme == "https",
      }
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      JSON.parse(response.body)
    end



    # Retrieves a github file
    def get_github_file(project, branch, file)
      uri = URI.parse("https://api.github.com/repos/NuCivic/" + project + "/contents/" + file + '?ref=' + branch)
      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "application/vnd.github.v3.raw"
      request["Authorization"] = "token 9874304d5d35c105f590df83c48112ff43518fba"
      req_options = {
        use_ssl: uri.scheme == "https",
      }
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      response.body
    end

    # Gets a Github project's config.yml info
    def get_config(project)
      branch = get_release(project)
      YAML.load(get_github_file(project, branch, 'config/config.yml'))
    end


    # Gets the current release (tag or branch) of a project
    def get_release(project)
      info = get_github_api(project, "releases")
      release = 'master'
      if info.length > 0
        unpublishedDraftLimit = 5
        x = 0
        release = info[x]['tag_name']
        # Unpublished drafts need to be skipped.
        while (unpublishedDraftLimit > x) && info[x]['draft']
          release = info[x]['tag_name']
          x += 1
        end
      end
      release
    end

    # Gets the Github repo of an Open Data site
    def get_repo(project)
      return 'https://github.com/NuCivic/' + project
    end

    # Gets the DKAN version of an Open Data site
    def get_version(project)
      branch = get_release(project)
      build_file = get_github_file(project, branch, "build-dkan.make")
      version = build_file.scan(/\[tag\] = (.+)/)
      if version.to_a.length == 0
        version = build_file.scan(/\[branch\] = (.+)/)
      end
      version
    end

    # Generates a display of customer properties
    def generate_list(table)

      table_rows = table.split('<tr>')
      table_rows.shift
      header_row = table_rows.shift.split('</td>')
      header_row.pop
      header_row.each do |header_col|
        puts ">>> " + Sanitize.clean(header_col).strip
      end

      table_rows.each do |row|
        cols = row.split('</td>')
        cols.pop
        i = 0
        cols.each do |col|
          puts Sanitize.clean(header_row[i]).strip + ": " + Sanitize.clean(col).strip
          i += 1
        end
        puts "\n"
      end
    end

    def generate_list2(table)

      table_rows = table.split('<tr>')
      puts ">>> " + table_rows.shift
      header_row = table_rows.shift.split('</th>')
      header_row.pop
      header_row.each do |header_col|
        puts ">>> " + Sanitize.clean(header_col).strip
      end

      table_rows.each do |row|
        cols = row.split('</td>')
        cols.pop
        i = 0
        cols.each do |col|
          puts Sanitize.clean(header_row[i]).strip + ": " + Sanitize.clean(col).strip
          i += 1
        end
        puts "\n"
      end
    end




  end
end
