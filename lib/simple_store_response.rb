# frozen_string_literal: true

require "json"
require "logger"

class SimpleStoreResponse
  HTTP_OK = 200
  HTTP_BAD_REQUEST = 400
  HTTP_NOT_FOUND = 404

  attr_reader :http_status, :body

  def initialize(request_method, request_uri, request_body, logger: STDERR)
    @request_method = request_method
    @request_uri = request_uri
    @request_body = request_body
    @log = Logger.new(logger, File::WRONLY | File::APPEND)
  end

  def process_request!
    process_get if http_get?
    process_post if http_post?
  end

  def process_get
    resp = {}

    if File.exist?(fname) && File.readable?(fname)
      File.open(fname, "r") { |f| @body = f.read }
      @http_status = HTTP_OK
    else
      @http_status = HTTP_NOT_FOUND
      resp[:error] = "Not found"
      @content_type = "application/json"
    end

    @body = JSON.dump(resp)
  end

  def process_post
    resp = {}
    raise "File not writable" unless File.writable?(fname)
  rescue StandardError => e
    # catch every error as to not leak server info
    @log.error e.message
    @http_status = HTTP_BAD_REQUEST
    resp[:error] = "Bad request"
    @content_type = "application/json"
  ensure
    @body = JSON.dump(resp)
  end

  def content_type = @content_type || "text/plain"
  def http_get? = @request_method == "GET"
  def http_post? = @request_method == "POST"

  def fname
    @request_uri.split("/").last
  end
end
