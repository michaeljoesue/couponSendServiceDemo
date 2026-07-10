require 'json'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Import seed data from JSON file
def parse_json_file(path)
  file_path = Rails.root.join(path)
  file_content = File.read(file_path)
  JSON.parse(file_content)
end

account_data = parse_json_file('db/fixtures/account.json')
account_data.each do |data|
  Account.create(id: data['id'], username: data['username'])
  Balance.create(account_id: data['id'], value: data['value'])
end
