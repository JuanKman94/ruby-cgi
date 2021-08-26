# frozen_string_literal: true

require "json"
require "logger"

class SimpleStoreResponse
  HTTP_OK = 200
  HTTP_BAD_REQUEST = 400
  HTTP_NOT_FOUND = 404

  attr_reader :http_code, :body

  def initialize(request_method:, request_body:, filename:, storage:, logger: STDERR)
    @request_method = request_method
    @request_body = request_body
    @filename = filename
    @storage = storage
    @log = Logger.new(logger, File::WRONLY | File::APPEND)
  end

  def process_request!
    process_get if http_get?
    process_post if http_post?
  end

  def process_get
    resp = {}

    if File.exist?(fname) && File.readable?(fname)
      resp[:data] = File.read(fname)
      @http_code = HTTP_OK
    else
      @http_code = HTTP_NOT_FOUND
      resp[:error] = "Not found"
      @content_type = "application/json"
    end

    @body = JSON.dump(resp)
  end

  def process_post
    resp = {}
    raise "Empty payload" if @request_body.nil? || @request_body.empty?

    File.open(fname, File::WRONLY | File::CREAT) { |f| f.write @request_body }
    @http_code = HTTP_OK
  rescue StandardError => e
    # catch every error as to not leak server info
    @log.error e.message
    @http_code = HTTP_BAD_REQUEST
    resp[:error] = "Bad request"
    @content_type = "application/json"
  ensure
    @body = JSON.dump(resp)
  end

  def content_type = @content_type || "text/plain"
  def http_get? = @request_method.upcase == "GET"
  def http_post? = @request_method.upcase == "POST"

  def fname = "#{@storage}/#{@filename}"
end
