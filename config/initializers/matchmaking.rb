require "ostruct"

Rails.application.configure do
  group_defaults = {
    active: false,
    schedule: :weekly,
    size: 2
  }

  matchmaking_config = config_for(:matchmaking).then do |cfg|
    cfg_json = cfg.map { |group, group_config|
      [group, group_config.reverse_merge(group_defaults)]
    }.to_h.to_json

    JSON.parse(cfg_json, object_class: OpenStruct)
  end

  config.x.matchmaking = matchmaking_config
end
