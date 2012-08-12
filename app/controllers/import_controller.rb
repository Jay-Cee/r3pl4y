require 'aws/s3'

class ImportController < ApplicationController
	before_filter :authenticate_user!
  before_filter :authenticate_admin!

  def index
		@platforms_list = Tag.where("category = 'platform'").order('name').collect {|t| [t.name, t.id]}
  end

  def perform
		raise "Unknown import platform" unless params['import_platform']
		platform = Tag.find(params[:import_platform]).name
    tempfile = params[:import_file].tempfile.path

    # establish s3 connection
    logger.debug "Open connection to S3"
    s3 = AWS::S3.new

    # application bucket
    bucket_name = 'files.r3pl4y.com'

    # store
    timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
    path = "import/#{platform}_#{timestamp}.csv"
    logger.debug "Store import file to #{path}"

    bucket = s3.buckets[bucket_name]
    object = bucket.objects[path]
    object.write(open(tempfile, "rb", :encoding => "BINARY"), :content_type => 'text/csv')

    # enqueue the game import job
    Delayed::Job.enqueue(GameImportJob.new(path, platform))

		redirect_to :action => 'index'
  end
end
