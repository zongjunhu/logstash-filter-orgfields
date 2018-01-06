# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"

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
  #   }
  # }
  #
  config_name "orgfields"
  
  # Replace the message with this value.
  config :merge_bin, :validate => :hash, :list => false, :default => {}
  config :to_boolean, :validate => :array, :list => false, :default => {}

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
        end
    end

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
