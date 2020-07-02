# frozen_string_literal: true

require 'json'

# Generate event responses
# Only used for the Handler return value
class EventResponder
  def initialize(res)
    @res = res
  end

  def success
    @res.status = 200
    self
  end

  def error(code)
    @res.status = code
    self
  end

  def ephemeral(text)
    hsh = {
      response: 'ephemeral',
      text: text
    }

    send_json(hsh)
  end

  private

  def send_json(response_body)
    @res['Content-type'] = 'application/json'
    @res.body = response_body.to_json
  end
end
