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
        params.reject { |k, _| k == "signature" }.sort_by { |key, _| key.to_s }.map { |k, v| "#{k}=#{v}" }.join("&")
      end

      def self.webhook_data_to_string(data)
        sorted_data_by_key = sort_obj_data_by_key(data)
        convert_data_to_query_str(sorted_data_by_key)
      end

      def self.snake_to_camel(str)
        str.to_s.split("_").map.with_index { |word, i| i.zero? ? word : word.capitalize }.join
      end

      def self.sort_obj_data_by_key(object)
        object.transform_keys { |key| snake_to_camel(key) }
              .sort
              .to_h
      end

      def self.convert_data_to_query_str(object)
        object.reject { |_, v| v.nil? }
              .map do |key, value|
                camel_key = snake_to_camel(key)
                formatted_value = case value
                                  when Array
                                    JSON.generate(value.map { |val| sort_obj_data_by_key(val) })
                                  when nil, "undefined", "null"
                                    ""
                                  else
                                    value.to_s
                                  end

                "#{camel_key}=#{formatted_value}"
              end
              .join("&")
      end
    end
  end
end
