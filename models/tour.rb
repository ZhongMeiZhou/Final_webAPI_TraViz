require 'sinatra'
require 'sinatra/activerecord'
require_relative '../config/environments'

class Tour < ActiveRecord::Base
end