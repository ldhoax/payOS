# PayOS

PayOS is a Ruby library that provides a simple and elegant way to integrate with the [PayOS payment gateway services](https://payos.vn/docs/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'payOS'
```

Then run `bundle install` to install the gem.

## Usage

Before using PayOS, you need to configure it with your credentials. You can do this in an initializer file (e.g., `config/initializers/payOS.rb` in Rails):

```ruby
PayOS.configure do |config|
  config.client_id = ENV['CLIENT_ID']
  config.api_key = ENV['API_KEY']
  config.checksum_secret = ENV['CHECKSUM_SECRET']
  # Optional: config.partner_code = ENV['PARTNER_CODE']
end
```

### Creating a Payment URL

To create a payment URL, use the `create_payment_url` method:

```ruby
payment_params = {
  amount: 123,
  cancelUrl: "https://your-domain.com/cancel-webhook-path",
  description: "description",
  orderCode: 4573928465,
  returnUrl: "https://your-domain.com/success-webhook-path",
  ... other params
}

payment_url = PayOS.create_payment_url(payment_params)
```

### Getting Payment Information

To retrieve information about a payment:

```ruby
payment_info = PayOS.get_payment_info('4573928465')
```

### Canceling a Payment

To cancel a payment:

```ruby
PayOS.cancel_payment('4573928465')
```

### Confirming a Webhook

To confirm a webhook:

```ruby
PayOS.confirm_webhook('https://example.com/webhook')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ldhoax/payOS. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ldhoax/payOS/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PayOS project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/payOS/blob/master/CODE_OF_CONDUCT.md).
