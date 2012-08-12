require 'test_helper'

class ReviewTest < ActiveSupport::TestCase
	test "should say Now when review was published less than 60 seconds" do
		review = Review.new :published => Time.now - 59
		assert_equal('Now', review.published_from(Time.now))
	end

	test "should say dd minutes ago when less than 60 minutes" do
		review = Review.new :published => Time.now - (59 * 60)
		assert_equal('59 minutes ago', review.published_from(Time.now))
	end

	test "should say hh hours ago when less than 12 hours" do
		review = Review.new :published => Time.now - (11 * 3600)
		assert_equal('11 hours ago', review.published_from(Time.now))
	end

	test "should say Today 09:00 when less than 24 hours ago and same day" do
		now = Time.utc(2012, 1, 18, 23, 00)
		review = Review.new :published => now - (14 * 3600)
		assert_equal('Today 09:00', review.published_from(now))
	end

	test "should say Yesterday 21:00 when less than 24 hours ago but over date line" do
		now = Time.utc(2012, 1, 18, 11, 00)
		review = Review.new :published => now - (14 * 3600)
		assert_equal('Yesterday 21:00', review.published_from(now))
	end

	test "should say Yesterday 09:00 when less than 48 hours ago and same day" do
		now = Time.utc(2012, 1, 18, 23, 00)
		review = Review.new :published => now - (38 * 3600)
		assert_equal('Yesterday 09:00', review.published_from(now))
	end

	test "should say Monday 21:00 when less than 48 hours ago but over date line" do
		now = Time.utc(2012, 1, 18, 11, 00)
		review = Review.new :published => now - (38 * 3600)
		assert_equal('Monday 21:00', review.published_from(now))
	end

	test "should say Sunday 23:00 when less than 7 days ago" do
		now = Time.utc(2012, 1, 18, 23, 00)
		review = Review.new :published => now - (72 * 3600)
		assert_equal('Sunday 23:00', review.published_from(now))
	end

	test "should say 4 January, 23:00 when more than 7 days ago" do
		now = Time.utc(2012, 1, 18, 23, 00)
		review = Review.new :published => now - (14 * 24 * 3600)
		assert_equal('4 January, 23:00', review.published_from(now))
	end
end
