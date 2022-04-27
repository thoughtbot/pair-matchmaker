module Slack
  class LoadsSlackChannels
    include RateLimitRetryable

    SLACK_CHANNEL_TYPES = [
      "public_channel",
      "private_channel",
      "mpim",
      "im"
    ].freeze

    def call(types:)
      response = retry_when_rate_limited do
        ClientWrapper.client.conversations_list(types: approved_types(types), limit: 1000, exclude_archived: true)
      end

      get_paged_channels(cursor: response&.response_metadata&.next_cursor, channels: response&.channels || [], types: types)
    end

    private

    def approved_types(types)
      types.split(",").select { |t| SLACK_CHANNEL_TYPES.include?(t) }.join(",")
    end

    def get_paged_channels(cursor:, channels:, types:)
      while cursor.present?
        response = ClientWrapper.client.conversations_list(cursor: cursor, types: approved_types(types), limit: 1000, exclude_archived: true)
        channels.append(response.channels)
        cursor = response.response_metadata&.next_cursor
      end

      channels.flatten
    end
  end
end
