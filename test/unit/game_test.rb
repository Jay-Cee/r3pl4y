require 'test_helper'

class GameTest < ActiveSupport::TestCase
	test "discrete_average_rating should return 1 for any values less than 1.8" do
     game = Game.new 
		 game.rate_average = 1.5
		 assert_equal(1, game.discrete_average_rating)
   end

	test "discrete_average_rating should return 2 for any values less than 2.6" do
     game = Game.new 
		 game.rate_average = 2.5
		 assert_equal(2, game.discrete_average_rating)
   end

	test "discrete_average_rating should return 3 for any values less than 3.4" do
     game = Game.new 
		 game.rate_average = 3.3
		 assert_equal(3, game.discrete_average_rating)
   end

	test "discrete_average_rating should return 4 for any values less than 4.2" do
     game = Game.new 
		 game.rate_average = 3.9
		 assert_equal(4, game.discrete_average_rating)
   end

	test "discrete_average_rating should return 5 for any values equal or greter to 4.2"  do
		 game = Game.new 
		 game.rate_average = 4.2
		 assert_equal(5, game.discrete_average_rating)
   end
end
