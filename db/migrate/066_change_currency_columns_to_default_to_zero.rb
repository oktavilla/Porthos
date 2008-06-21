class ChangeCurrencyColumnsToDefaultToZero < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE conversions MODIFY amount INT NOT NULL DEFAULT 0"
    execute "ALTER TABLE measure_points MODIFY cost INT NOT NULL DEFAULT 0"
    execute "ALTER TABLE order_items MODIFY price INT NOT NULL DEFAULT 0"
    execute "ALTER TABLE payments MODIFY amount INT NOT NULL DEFAULT 0"
    execute "ALTER TABLE products MODIFY price INT NOT NULL DEFAULT 0"
    execute "ALTER TABLE registrations MODIFY total_sum INT NOT NULL DEFAULT 0"
    execute "ALTER TABLE registrations MODIFY total_vat INT NOT NULL DEFAULT 0"
    execute "ALTER TABLE registrations MODIFY donation INT NOT NULL DEFAULT 0"
    execute "ALTER TABLE registrations MODIFY shipment_price INT NOT NULL DEFAULT 0"
    execute "ALTER TABLE shipments MODIFY price INT NOT NULL DEFAULT 0"
  end

  def self.down
    execute "ALTER TABLE conversions MODIFY amount INT DEFAULT NULL"
    execute "ALTER TABLE measure_points MODIFY cost INT DEFAULT NULL"
    execute "ALTER TABLE order_items MODIFY price INT DEFAULT NULL"
    execute "ALTER TABLE payments MODIFY amount INT DEFAULT NULL"
    execute "ALTER TABLE products MODIFY price INT DEFAULT NULL"
    execute "ALTER TABLE registrations MODIFY total_sum INT DEFAULT NULL"
    execute "ALTER TABLE registrations MODIFY total_vat INT DEFAULT NULL"
    execute "ALTER TABLE registrations MODIFY donation INT DEFAULT NULL"
    execute "ALTER TABLE registrations MODIFY shipment_price INT DEFAULT NULL"
    execute "ALTER TABLE shipments MODIFY price INT DEFAULT NULL"
  end
end
