class CreateTours < ActiveRecord::Migration
  def change
  	create_table :tours do |t|
  	  t.string  :country
  	  t.text :tours
      t.timestamps null:false
  	end
  end
end

# run rake db:migrate
