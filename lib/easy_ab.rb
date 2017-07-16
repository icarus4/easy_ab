module EasyAb
  def self.config
    @config = nil if Rails.env.development? # Reload in development
    @config ||= YAML.load(File.read("config/easy_ab.yml"))
  end
end