require 'aws-sdk'

module Chap
  class S3
    attr_reader :options, :config
    def initialize(options={})
      @options = options
      @config = Config.new(options)
    end

    def s3
      @s3 ||= AWS::S3.new(
        :access_key_id => @config.yaml['s3']['access_key_id'],
        :secret_access_key => @config.yaml['s3']['secret_access_key']
      )
    end

    def bucket
      name = @config.yaml['s3']['bucket']
      s3.buckets[name]
    end

    def upload(source,raw=false)
      path = @config.yaml['s3']['path']
      # bucket.objects.create(path, source)
      obj = bucket.objects[path]
      data = raw ? source : Pathname.new(source)
      obj.write(data)
    end

    def download
      path = @config.yaml['s3']['path']
      obj = bucket.objects[path]
      obj.read
    end

    def change(variables)
      json = download
      data = JSON.load(json)
      variables.each { |k,v| data[k] = v }
      json = JSON.pretty_generate(data)
      upload(json,true)
    end
  end
end
