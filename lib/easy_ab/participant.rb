module EasyAb
  class Participant
    def self.normalize(participants)
      participants.map { |p| p.respond_to?(:model_name) ? "#{v.model_name.name}:#{v.id}" : v.to_s }
    end
  end
end