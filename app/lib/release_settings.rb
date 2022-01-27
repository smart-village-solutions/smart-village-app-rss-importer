class ReleaseSettings
  def self.config
    file_name = "config/release_settings.yml"
    return {} unless File.exist?(file_name)

    @config ||= HashWithIndifferentAccess.new(
      YAML.safe_load(
        File.read(
          Rails.root.join(file_name)
        )
      )
    )
  end

  def self.method_missing(method_name)
    # This environment variable is set using .gitlab-ci.yml,
    # which feeds it into docker-compose.yml and
    # then it lands here
    current_community = ENV["SVA_COMMUNITY"] || "local-localhost"
    settings = config[current_community.underscore]
    settings[method_name.to_sym]
  end
end
