# frozen_string_literal: true

require "json"

class SimpleStoreResponse
  HTTP_OK = 200
  HTTP_BAD_REQUEST = 400
  HTTP_NOT_FOUND = 404

  attr_reader :http_status, :body

  def initialize(request_method, request_uri, request_body, logger: STDERR)
    @request_method = request_method
    @request_uri = request_uri
    @request_body = request_body
    @logger = logger
  end

  def process_request!
    process_get if http_get?
    process_post if http_post?
  end

  def process_get
    if File.exist?(fname) && File.readable?(fname)
      File.open(fname, "r") { |f| @body = f.read }
      @http_status = HTTP_OK
    else
      @http_status = HTTP_NOT_FOUND
      @body = JSON.dump({ message: "Not found" })
      @content_type = "application/json"
    end
  end

  def content_type = @content_type || "text/plain"

  def process_post
    raise "File not writable" unless File.writable?(fname)
  rescue StandardError => e
    # catch every error as to not leak server info
    log e.message, "ERROR"
    @http_status = HTTP_BAD_REQUEST
    @body = JSON.dump({ message: "Bad request" })
    @content_type = "application/json"
  end

  def log(message, level = "DEBUG")
    @logger.write "[#{level}] #{message}\n"
  end

  def http_get? = @request_method == "GET"
  def http_post? = @request_method == "POST"

  def fname
    @request_uri.split("/").last
  end
end
