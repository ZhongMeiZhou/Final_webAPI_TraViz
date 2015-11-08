class CreateTours < ActiveRecord::Migration
  def change
  	drop_table :tours
  	create_table :tours do |t|
  	  t.string  :country
  	  t.text :tours
  	  t.timestamps null:false
  	end
  end
end
