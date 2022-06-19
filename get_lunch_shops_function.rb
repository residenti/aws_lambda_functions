require 'net/http'
require 'uri'
require 'nkf'
require 'json'
require 'rexml/document'

Shop = Struct.new(:name)

def lambda_handler(event:, context:)
  query = event['queryStringParameters']
  params = { key: ENV['API_KEY'], address: query['address'], lat: query['lat'], lng: query['lng'] }
  uri = URI.parse(ENV['URL'])
  uri.query = URI.encode_www_form(params)
  res = Net::HTTP.get(uri)
  str = NKF.nkf('-h1 -w', res)
  doc = REXML::Document.new(str)
  shops = REXML::XPath.match(doc, '/results/shop').map do |shop|
    name = shop.elements['name']&.text
    Shop.new(name).to_h
  end
  { statusCode: 200, body: JSON.generate({ shops: shops }) }
end
