class EventsController < ApplicationController
  before_filter :disable_devise_tracking
  before_filter :authenticate_user!
  before_action :find_bot

  class BadEventError < StandardError; end

  rescue_from BadEventError, with: :bad_event

  def create
    validate_event!
    case @bot.provider
    when 'facebook'
      FacebookEventsCollectorJob.perform_async(@bot.uid, params[:event])
    when 'kik'
      KikEventsCollectorJob.perform_async(@bot.uid, params[:event])
    when 'first_opinion'
      FirstOpinionEventsCollectorJob.perform_async(@bot.uid, params[:event])
    end

    render nothing: true, status: :accepted
  end

  protected
  def validate_event!
    begin
      event = JSON.parse(params[:event].to_s)
    rescue JSON::ParserError
      @error = "Event parameter is not valid JSON"
      raise BadEventError
    end

    case @bot.provider
    when 'facebook'
      if event['entry'].blank?
        @error = "Invalid Facebook Event Data"
        raise BadEventError
      end
    when 'kik'
      if !event.is_a?(Array)
        @error = "Invalid Kik Event Data"
        raise BadEventError
      end
    when 'first_opinion'
      if !event.is_a?(Array)
        @error = "Invalid First Opinion Event Data"
        raise BadEventError
      end
    end
  end

  def disable_devise_tracking
    request.env["devise.skip_trackable"] = true
  end

  def bad_event
    render json: { error: @error }, status: :bad_request
  end
end
