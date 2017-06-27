class EventSerializer::FirstOpinion::Message < EventSerializer::FirstOpinion::Base
  private
  attr_reader :bi_uid

  def data
    user_type = @data[:user][:type]
    {
      event_type: event_type,
      is_for_bot: user_type == 'user',
      is_from_bot: user_type == 'doctor',
      is_im: user_type == 'user',
      text: @data[:body],
      provider: 'first_opinion',
      created_at: timestamp,
      event_attributes: event_attributes
    }
  end

  def event_attributes
    event_attributes = {
      message_token: @data[:message_token],
      id: @data[:id]
    }
    event_attributes
  end

  def event_type
    case @data[:type]
      when 'text' then 'message'
      else 'message'
    end
  end
end
