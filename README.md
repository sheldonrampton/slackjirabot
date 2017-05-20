# Welcome to the SlackJiraBot

## Getting Started

### Install Dependencies

- Ruby 2.3.3
- Redis

#### Mac

- If you don't have homebrew, [install it now](http://brew.sh/).
- If you haven't installed ruby before, we recommend rbenv `brew install rbenv && rbenv install 2.3.3`
- If you don't have redis installed locally: `brew install redis && brew services start redis`

### App Setup

- Clone: `git clone https://github.com/sheldonrampton/slackjirabot.git`
- CD: `cd slackjirabot`
- Bundler: `gem install bundler && bundle install`
- Create a .env file, copy the example and get the correct tokens: `cp example.env .env`

#### Getting a Slack Token

- [Visit the Slack integrations page for your team, e.g., https://myteam.slack.com/apps/build/custom-integration
- Click on Bots
- Give your bot a name like `yourname_test_bot`
- Copy the api Token and put it in your .env file

### Running the App

- `foreman start`

### Running Tests

All merge requests run both specs and a linter, make sure they both pass before you push code up unless you want failures.

- Specs: `bundle exec rspec`
- Lint: `bundle exec rubocop`

### Contributing

We encourage you to contribute to SlackJiraBot! Send us your pull requests!
