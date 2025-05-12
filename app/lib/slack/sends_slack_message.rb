module Slack
  class SendsSlackMessage
    def call(kwargs)
      ClientWrapper.client.chat_postMessage(**kwargs)
    end
  end
end
