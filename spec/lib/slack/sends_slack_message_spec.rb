require "rails_helper"

RSpec.describe Slack::SendsSlackMessage do
  let(:subject) { Slack::SendsSlackMessage.new }

  before(:example) do
    @slack_client = double(Slack::Web::Client)
    allow(Slack::ClientWrapper).to receive(:client) { @slack_client }
  end

  it "sends message to a channel" do
    slack_user_im = Slack::Messages::Message.new(
      id: "USER_IM_ID",
      user: Slack::Messages::Message.new(id: "USER_ID")
    )

    expect(@slack_client).to receive(:chat_postMessage).with({
      channel: "USER_IM_ID",
      blocks: [
        {type: "section", text: {type: "plain_text", text: "Hello World"}}
      ]
    })

    subject.call(channel: slack_user_im.id, blocks: [
      {type: "section", text: {type: "plain_text", text: "Hello World"}}
    ])
  end
end
