require 'base64'
require 'date'
require 'time'
require 'boffin/version'
require 'boffin/utils'
require 'boffin/config'
require 'boffin/keyspace'
require 'boffin/tracker'
require 'boffin/hit'
require 'boffin/trackable'

module Boffin
  WINDOW_UNIT_FORMATS = {
    hours:  '%F-%H',
    days:   '%F',
    months: '%Y-%m'
  }
  WINDOW_UNIT_TYPES = WINDOW_UNIT_FORMATS.keys

  class UndefinedHitTypeError < StandardError; end

  def self.config(&block)
    @config ||= Config.new(&block)
  end

  def self.track(mod_or_ns, hit_types = [])
    case mod_or_ns
    when String, Symbol
      Tracker.new(mod_or_ns, hit_types)
    else
      mod_or_ns.send(:include, Trackable)
      mod_or_ns.boffin_tracker.hit_types.concat(hit_types)
      mod_or_ns.boffin_tracker
    end
  end
end