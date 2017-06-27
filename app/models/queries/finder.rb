module Queries
  class Finder
    def self.for_type(provider)
      case provider
        when 'slack'
          Queries::Slack.new
        when 'facebook'
          Queries::Facebook.new
        when 'kik'
          Queries::Kik.new
        when 'first_opinion'
          Queries::FirstOpinion.new
        else
          Queries::Null.new
      end
    end
  end
end
