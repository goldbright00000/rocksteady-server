require_relative '../test_helper'

class CurrencyTest < ActiveSupport::TestCase

  test 'without merchant override' do
    currencies = Currency::currencies
    index      = currencies.find_index { |c| c['iso_code'] == 'EUR' }

    assert_equal '003', currencies[index]['merchant_acc']
  end

  test 'with merchant override' do
    currencies = Currency::with_merchant_codes
    index      = currencies.find_index { |c| c['iso_code'] == 'EUR' }

    assert_equal '9900846', currencies[index]['merchant_acc']
  end
end
