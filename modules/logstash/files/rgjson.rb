require "logstash/filters/base"
require "logstash/namespace"

# JSON filter. Takes a field that contains JSON and expands it into
# an actual datastructure in the root message.
class LogStash::Filters::RgJson < LogStash::Filters::Base

  config_name "rgjson"
  plugin_status "beta"

  # Config for json is:
  #   source: prefix
  # JSON in the value of the source field will be expanded into a
  # datastructure. dest will be prefix + jsonkey  Note: if the "dest" field
  # already exists, it will be overridden.
  config /[A-Za-z0-9_-]+/, :validate => :string

  public
  def register
    @json = {}

    @config.each do |field, prefix|
      next if RESERVED.member?(field)

      @json[field] = prefix
    end
  end # def register

  public
  def filter(event)
    return unless filter?(event)

    @logger.debug("Running json filter", :event => event)

    matches = 0
    @json.each do |key, prefix|
      if event.fields[key]
        if event.fields[key].is_a?(String)
          event.fields[key] = [event.fields[key]]
        end

        if event.fields[key].length > 1
          @logger.warn("JSON filter only works on fields of length 1",
                       :key => key, :value => event.fields[key])
          next
        end

        raw = event.fields[key].first
        begin
          parsed_data = JSON.parse(raw)
          parsed_data.each do |parsed_key, parsed_value|
            event[parsed_key] = parsed_value
          end
          filter_matched(event)
        rescue => e
          event.tags << "_jsonparsefailure"
          @logger.warn("Trouble parsing json", :key => key, :raw => raw,
                        :exception => e, :backtrace => e.backtrace)
          next
        end
      end
    end

    @logger.debug("Event after json filter", :event => event)
  end # def filter
end # class LogStash::Filters::RgJson