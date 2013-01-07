class StatsController < ApplicationController
  caches_page :new_users, :new_reviews
  
  def new_users
    data = ActiveRecord::Base.connection.select_rows("SELECT d, COUNT(users) FROM (SELECT (current_date - integer '365') + s.a AS d FROM generate_series(0,365,7) AS s(a)) dates INNER JOIN users ON users.created_at < d GROUP BY d ORDER BY d")

    cols = [ { :id => '', :label => 'Date', :pattern => '', :type => 'date' }, { :id => '', :label => 'Users', :pattern => '', :type => 'number' } ] 

    rows = data.map {|row| { :c => [{ :v => "Date(#{Date.strptime(row[0], "%Y-%m-%d").strftime("%Y, %-m, %-d")})", :f => nil }, { :v => row[1].to_i, :f => nil }] }}

    document = { :cols => cols, :rows => rows }

    respond_to do |format|
      format.json { render json: document } 
    end
  end

  def new_reviews
    data = ActiveRecord::Base.connection.select_rows("SELECT d, COUNT(reviews) FROM (SELECT (current_date - integer '365') + s.a AS d FROM generate_series(0,365,7) AS s(a)) dates INNER JOIN reviews ON reviews.created_at < d GROUP BY d ORDER BY d")

    cols = [ { :id => '', :label => 'Date', :pattern => '', :type => 'date' }, { :id => '', :label => 'Reviews', :pattern => '', :type => 'number' } ] 

    rows = data.map {|row| { :c => [{ :v => "Date(#{Date.strptime(row[0], "%Y-%m-%d").strftime("%Y, %-m, %-d")})", :f => nil }, { :v => row[1].to_i, :f => nil }] }}

    document = { :cols => cols, :rows => rows }

    respond_to do |format|
      format.json { render json: document } 
    end
  end
end
