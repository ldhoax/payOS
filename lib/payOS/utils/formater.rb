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
    end
  end
end
