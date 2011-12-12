require 'rubygems'
require 'sinatra'
require 'rdiscount'
require 'coderay'

use Rack::Static, :urls => ["/stylesheets"], :root => "public"

get '/' do
  erb :index
end
