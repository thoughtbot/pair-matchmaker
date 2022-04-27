require "rails_helper"

RSpec.describe Slack::LoadsSlackChannelMembers do
  let(:subject) { Slack::LoadsSlackChannelMembers.new }

  before(:example) do
    @slack_client = double(Slack::Web::Client)
    allow(Slack::ClientWrapper).to receive(:client) { @slack_client }
  end

  it "loads members found in a channel" do
    all_slack_users = [
      Slack::Messages::Message.new(id: "USER_ID_1"),
      Slack::Messages::Message.new(id: "USER_ID_2"),
      Slack::Messages::Message.new(id: "USER_ID_3"),
      Slack::Messages::Message.new(id: "USER_ID_4"),
      Slack::Messages::Message.new(id: "USER_ID_5")
    ]

    slack_members = [
      "USER_ID_1",
      "USER_ID_3",
      "USER_ID_5"
    ]

    expect(@slack_client).to receive(:users_list) {
      Slack::Messages::Message.new(ok: true, members: all_slack_users)
    }
    expect(@slack_client).to receive(:conversations_members).with(channel: "CHANNEL_ID", limit: 1000) {
      Slack::Messages::Message.new(ok: true, members: slack_members)
    }

    members = subject.call(channel: "CHANNEL_ID")

    expect(members).to eq(slack_members)
  end

  it "loads members found in a channel when pagination is required" do
    all_slack_users = (0..205).map do |id|
      Slack::Messages::Message.new(id: "USER_ID_#{id}")
    end

    slack_members = [
      "USER_ID_1",
      "USER_ID_3",
      "USER_ID_205"
    ]

    response_metadata = Slack::Messages::Message.new(next_cursor: "cursor")
    expect(@slack_client).to receive(:users_list).with(limit: 200) {
      Slack::Messages::Message.new(ok: true, members: all_slack_users[0..199], response_metadata: response_metadata)
    }
    expect(@slack_client).to receive(:users_list).with(cursor: response_metadata.next_cursor, limit: 200) {
      Slack::Messages::Message.new(ok: true, members: all_slack_users[200..])
    }
    expect(@slack_client).to receive(:conversations_members).with(channel: "CHANNEL_ID", limit: 1000) {
      Slack::Messages::Message.new(ok: true, members: slack_members)
    }

    members = subject.call(channel: "CHANNEL_ID")

    expect(members).to eq(slack_members)
  end

  it "excludes bots from the returned users" do
    slack_user = Slack::Messages::Message.new(id: "USER_ID", is_bot: false)
    slack_app = Slack::Messages::Message.new(id: "APP_ID", is_bot: true)

    slack_members = ["USER_ID", "APP_ID"]

    expect(@slack_client).to receive(:users_list) {
      Slack::Messages::Message.new(ok: true, members: [slack_user, slack_app])
    }
    expect(@slack_client).to receive(:conversations_members).with(channel: "CHANNEL_ID", limit: 1000) {
      Slack::Messages::Message.new(ok: true, members: slack_members)
    }

    members = subject.call(channel: "CHANNEL_ID")

    expect(members).to eq(["USER_ID"])
  end
end
