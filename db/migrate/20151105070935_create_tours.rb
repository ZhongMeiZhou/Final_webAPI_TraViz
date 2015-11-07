class CreateTours < ActiveRecord::Migration
  def change
  	create_table :tours do |t|
  	  t.string  :country
  	  t.text :title
  	  t.float :price
  	end
  end
end

# run rake db:migrate