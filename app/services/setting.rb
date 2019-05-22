class Setting
  attr_accessor :config

  def initialize
    @config = YAML.load_file(file_name)
  end

  def save
    File.open(file_name, "w") { |f| f.write @config.to_yaml }
  end

  def file_name
    Rails.root.join('config', 'settings.yml')
  end
end
