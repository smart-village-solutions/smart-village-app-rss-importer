class Setting
  attr_accessor :config

  def initialize
    config_file_present_or_create
    @config = YAML.load_file(file_name)
  end

  def save
    File.open(file_name, "w") { |f| f.write @config.to_yaml }
  end

  def file_name
    Rails.root.join('config', 'settings', 'settings.yml')
  end

  def config_file_present_or_create
    return if File.exist?(file_name)
    defaults = { oauth: { access_token: "", refresh_token: "" } }
    File.open(file_name, "w") { |f| f.write(defaults.to_yaml) }
  end
end
