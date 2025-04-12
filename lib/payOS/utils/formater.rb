# frozen_string_literal: true

module PayOS
  module Utils
    class Formater
      def self.format_params(params)
        params.sort_by { |key, _| key.to_s }.map do |key, value|
          formatted_key = key.to_s.split("_").map.with_index do |word, i|
            i.zero? ? word : word.capitalize
          end.join
          [formatted_key, value]
        end.to_h
      end

      def self.params_to_string(params)
        amount = params["amount"]
        cancel_url = params["cancelUrl"] 
        description = params["description"]
        order_code = params["orderCode"]
        return_url = params["returnUrl"]

        "amount=#{amount}&cancelUrl=#{cancel_url}&description=#{description}&orderCode=#{order_code}&returnUrl=#{return_url}"
      end

      def self.webhook_data_to_string(data)
        sorted_data_by_key = sort_obj_data_by_key(data)
        puts "sorted_data_by_key: #{sorted_data_by_key.inspect}"
        result = convert_data_to_query_str(sorted_data_by_key)
        puts "result: #{result}"
        result
      end

      def self.snake_to_camel(str)
        str.to_s.split("_").map.with_index { |word, i| i.zero? ? word : word.capitalize }.join
      end

      def self.sort_obj_data_by_key(object)
        return object unless object.is_a?(Hash)
        
        object.transform_keys { |key| snake_to_camel(key) }
              .sort
              .to_h
              .transform_values do |value|
                if value.is_a?(Array)
                  value.map { |item| sort_obj_data_by_key(item) }
                elsif value.is_a?(Hash)
                  sort_obj_data_by_key(value)
                else
                  value
                end
              end
      end

      def self.convert_data_to_query_str(object)
        return "" if object.nil?
        
        object.map do |key, value|
          camel_key = snake_to_camel(key)
          formatted_value = case value
                          when Array
                            JSON.generate(value)
                          when nil, "undefined", "null"
                            ""
                          else
                            value.to_s
                          end

          "#{camel_key}=#{formatted_value}"
        end
        .sort
        .join("&")
      end
    end
  end
end
