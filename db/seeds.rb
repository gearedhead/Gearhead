# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

puts 'CREATING ROLES'
Role.create!([
                { :name => 'admin' },
                { :name => 'doner' },
                { :name => 'volunteer' },
                {:name => 'journalist'}
             ])
puts 'SETTING UP DEFAULT USER LOGIN'
user = User.create! :name => 'Administrator',
                    :email => 'admin@indiandoners.org',
                    :password => 'Admin123$',
                    :password_confirmation => 'Admin123$'

puts 'User created: ' << user.name

user.add_role :admin

