# frozen_string_literal: true

require "spec_helper"

RSpec.describe PayOS::Utils::Formater do
  describe ".format_params" do
    it "converts hash keys from snake_case to camelCase" do
      params = {
        user_name: "john",
        first_name: "John",
        last_name: "Doe"
      }

      expected = {
        "userName" => "john",
        "firstName" => "John",
        "lastName" => "Doe"
      }

      expect(described_class.format_params(params)).to eq(expected)
    end
  end

  describe ".params_to_string" do
    it "converts params to query string format excluding signature" do
      params = {
        "name" => "John",
        "signature" => "abc123",
        "age" => "30"
      }

      expect(described_class.params_to_string(params)).to eq("age=30&name=John")
    end
  end

  describe ".webhook_data_to_string" do
    it "converts webhook data to query string format" do
      data = {
        order_code: "3982",
        amount: 100_000,
        status: "success",
        method: "virtual_account",
        emptyThing: "",
        nilThing: nil
      }

      expect(described_class.webhook_data_to_string(data))
        .to eq("amount=100000&emptyThing=&method=virtual_account&nilThing=&orderCode=3982&status=success")
    end
  end

  describe ".snake_to_camel" do
    it "converts snake_case string to camelCase" do
      expect(described_class.snake_to_camel("hello_world")).to eq("helloWorld")
      expect(described_class.snake_to_camel("user_first_name")).to eq("userFirstName")
    end
  end

  describe ".sort_obj_data_by_key" do
    it "transforms keys to camelCase and sorts them" do
      data = {
        user_name: "john",
        first_name: "John",
        age: 30
      }

      expected = {
        "age" => 30,
        "firstName" => "John",
        "userName" => "john"
      }

      expect(described_class.sort_obj_data_by_key(data)).to eq(expected)
    end
  end

  describe ".convert_data_to_query_str" do
    context "with simple values" do
      it "converts object to query string" do
        data = {
          "name" => "John",
          "age" => 30,
          "longThing" => "longThing"
        }

        expect(described_class.convert_data_to_query_str(data))
          .to eq("name=John&age=30&longThing=longThing")
      end
    end

    context "with array values" do
      it "converts array values to JSON strings" do
        data = {
          "items" => [
            { item_name: "Product 1", price: 100 },
            { item_name: "Product 2", price: 200 }
          ]
        }

        expected_items = '[{"itemName":"Product 1","price":100},{"itemName":"Product 2","price":200}]'
        expect(described_class.convert_data_to_query_str(data))
          .to eq("items=#{expected_items}")
      end
    end

    context "with nil or special values" do
      it "converts nil, undefined, and null values to empty strings" do
        data = {
          "name" => "John",
          "age" => nil,
          "email" => "undefined",
          "phone" => "null"
        }

        expect(described_class.convert_data_to_query_str(data))
          .to eq("name=John&age=&email=&phone=")
      end
    end
  end
end
