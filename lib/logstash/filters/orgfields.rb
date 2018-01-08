# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "date"

# This  filter will replace multiple boolean industry fields to a single industry field
# The first industry field with value "1" will be used as the value of the new field
# If no field found with value "1", this new field is not created
# All input fields will be removed
#
class LogStash::Filters::Orgfields < LogStash::Filters::Base

  # Setting the config_name here is required. This is how you
  # configure this filter from your Logstash config.
  #
  # filter {
  #    orgfields {
  #        merge_bin => {
  #            "new_field_name1" => ["field1", "field2", ...]
  #            ...
  #            }
  #        to_boolean => ["fname1", "fname2"]
  #        to_type => {
  #           'boolean' => ["f1", "f2", ...]
  #           'integer' => ["f1", "f2", ...]
  #           'float' => ["f1", "f2", ...]
  #           'datetime' => ["f1", "f2", ...]
  #           }
  #   }
  # }
  #
  config_name "orgfields"
  
  # Replace the message with this value.
  config :merge_bin, :validate => :hash, :list => false, :default => {}
  config :to_boolean, :validate => :array, :list => false, :default => {}
  config :to_type, :validate => :hash, :list => false, :default => {}

  public
  def register
    # Add instance variables 
  end # def register

  public
  def filter(event)

    if !@to_boolean.nil?

        @to_boolean.each do |f|
            value = event.get(f)
            if value.nil?
                next
            end
            if value.strip.downcase.start_with?('t') || value.strip == '1' 
               event.set(f, true)
            else
                event.set(f, false)
            end
        end # end to_boolean loop
    end # end to_boolean

    if @to_type.length > 0
        @to_type.each do |t, fields|
            fields.each do |f|
                value = event.get(f)
                if value.nil?
                    next
                end
                value = value.strip
                if t == 'boolean'
                    if value.downcase.start_with?('t') || value == '1' 
                       event.set(f, true)
                    else
                       event.set(f, false)
                    end
                elsif t == 'integer'
                    if /^[\d\.]+$/.match(value)
                        event.set(f, value.to_i)
                    else
                        event.set(f, nil)
                    end
                elsif t == 'float'
                    if /^[\d\.]$+/.match(value)
                        event.set(f, value.to_f)
                    else
                        event.set(f, nil)
                    end
                elsif t == 'datetime'
                    begin
                        a = DateTime.strptime(value, '%m/%d/%Y %H:%M:%S')
                        event.set(f, a)
                    rescue Exception => e
                        event.set(f, nil)
                    end
                end
            end # end fields loop
        end # end to_type loop
    end # end to_type

   @merge_bin.each do |fname, fields| 
       value_set = false
       fields.each do |f|
           value = event.get(f)
           if !value.nil? 
               if value == "1" || value.strip.downcase.start_with?('t') 
                   if !value_set
                       event.set(fname, f)
                       logger.debug("add #{fname} as: #{f}")
                       value_set = true
                   end
                   event.set(f, true)
               else
                   event.set(f,false)
               end
           end
       end
   end


    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter
end # class LogStash::Filters::Orgfields
