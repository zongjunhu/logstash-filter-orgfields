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
  #        null_values => ['null'] 
  #        true_values => ['1', 'true', 'yes'] 
  #        ana_fields => [] 
  #        merge_bin => {
  #            "new_field_name1" => ["field1", "field2", ...]
  #            ...
  #            }
  ##       to_boolean => ["fname1", "fname2"]
  #        to_type => {
  #           'boolean' => ["f1", "f2", ...]
  #           'integer' => ["f1", "f2", ...]
  #           'float' => ["f1", "f2", ...]
  #           'datetime|date' => {
  #               'format1' => ["f1", "f2", ...]
  #               'format2' => ["f3", "f4", ...]
  #             }
  #           'array' => {
  #             'splitor' => ["f1", "f2", ...]
  #             }
  #           }
  #   }
  # }
  #
  config_name "orgfields"
  
  # Replace the message with this value.
  config :null_values, :validate => :array, :list => false, :default => ['null']
  config :ana_fields, :validate => :array, :list => false, :default => []
  config :true_values, :validate => :array, :list => false, :default => ["1", "true", "yes"]
  config :merge_bin, :validate => :hash, :list => false, :default => {}
  #config :to_boolean, :validate => :array, :list => false, :default => {}
  config :to_type, :validate => :hash, :list => false, :default => {}

  public
  def register
    # Add instance variables 
  end # def register

  public
  def filter(event)

#    if @to_boolean.length > 0
#
#        @to_boolean.each do |f|
#            value = event.get(f)
#            if value.nil?
#                next
#            end
#            if @true_values.include?(value.strip.downcase)
#               event.set(f, true)
#            else
#                event.set(f, false)
#            end
#        end # end to_boolean loop
#    end # end to_boolean
#
    # remove null fields
    if @null_values.length > 0
        fields_to_remove = []
        event.to_hash.each do |k, v|
            if v.is_a?(String) && @null_values.include?(v.downcase)
                fields_to_remove << k
            end
        end
        if fields_to_remove.length > 0
            fields_to_remove.each {|x| event.remove(x)}
        end
    end

    # rename fields for analyis.
    if @ana_fields.length > 0
        ana_fields.each do |x|
            value = event.get(x)
            if !value.nil?
                event.remove(x)
                event.set("#{x}_ana", value)
            end

        end
    end

    if @to_type.length > 0
        @to_type.each do |t, fields|
            if t == 'array'

                fields.each do |sp, flds|
                    flds.each do |f|
                        value = event.get(f)
                        if value.nil?
                            next
                        end

                        value = value.strip

                        arr = value.split(sp).map{|x| x.strip}
                        event.set(f, arr)

                    end # end of flds
                end  # end of fields

            elsif t == 'datetime' || t == 'date'

                fields.each do |fmt, flds|
                    flds.each do |f|

                        value = event.get(f)
                        if value.nil?
                            next
                        end

                        value = value.strip
                        
                        begin
                            if fmt == 'default'
                                fmt = fmt == 'datetime'? '%m/%d/%Y %H:%M:%S' : '%m/%d/%Y'
                            end
                            a = DateTime.strptime(value, fmt)
                            event.set(f, LogStash::Timestamp.new(a.to_time))
                        rescue Exception => e
                            event.set(f, nil)
                        end
                    end
                end
            else
                fields.each do |f|
                    value = event.get(f)
                    if value.nil?
                        next
                    end
                    value = value.strip
                    if t == 'boolean'
                        if @true_values.include?(value.downcase)
                           event.set(f, true)
                        elsif !value.strip.empty?
                           event.set(f, false)
                        else
                            event.remove(f)
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
                    else
                        event.set(f, value)
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
               if @true_values.include?(value.strip.downcase)
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
