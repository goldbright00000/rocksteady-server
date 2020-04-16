class Currency < ActiveRecord::Base

  has_many :countries

  class << self
    def with_merchant_codes
      merchant_override currencies
    end

    def merchant_override(currencies, override_values: OVERRIDE_VALUES)
      override_values.each do |k, v|
        i = currencies.find_index { |c| c.iso_code == k }
        currencies[i].merchant_acc = v if i.present?
      end
      currencies
    end

    def currencies(select_values: [:id, :name, :iso_code, :iso_numeric,
        :symbol, :fx_rate, '`merchant_accounts`.`acc_code` AS `merchant_acc`'])
      select(select_values).
        joins('LEFT OUTER JOIN
        `merchant_accounts`
          ON `merchant_accounts`.`iso_currency_code` = `currencies`.`iso_code`')
    end
  end
end
