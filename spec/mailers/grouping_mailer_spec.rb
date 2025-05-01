require "rails_helper"

RSpec.describe GroupingMailer do
  before(:example) do
    GroupingMailer.deliveries.clear
  end

  it "creates encourage_match mailer" do
    email = GroupingMailer.with(
      recipient: Mailer::MatchMember.new(name: "Sherlock", email: "holmes@deduction.com"),
      mailer_params: Mailer::GroupingMailerParameters.new(
        other_members: [Mailer::MatchMember.new(name: "Watson", email: "watson@deduction.com")],
        grouping: "test",
        channel: "rotating-test"
      )
    ).encourage_match

    expect { email.deliver_now }.to change { GroupingMailer.deliveries.count }.by(1)

    expect(email.to).to eq(["holmes@deduction.com"])
    expect(email.from).to eq(["doubot@testdouble.com"])
    expect(email.reply_to).to eq(["watson@deduction.com"])
    expect(email.subject).to eq("Test with Watson")
    expect(email.body.to_s).to eq(
      <<~BODY
        Howdy Sherlock,

        You've been matched up with Watson for Test from the #rotating-test Slack channel!

        Find a time to meet, and have fun!

        - Double Up San

      BODY
    )
  end
end
