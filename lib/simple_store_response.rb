# frozen_string_literal: true

require "json"
require "logger"

class SimpleStoreResponse
  HTTP_OK = 200
  HTTP_BAD_REQUEST = 400
  HTTP_NOT_FOUND = 404
  VERSION = "0.1".freeze

  attr_reader :http_code, :body

  # Initialize store response processor
  #
  # @param [String] request_method HTTP request method
  # @param [String] request_body HTTP request body, if applicable (POST, PUT, PATCH)
  # @param [String] filename Filename for payload
  # @param [String] storage Directory where payload will be stored.
  #   NOTE: the effective user **MUST** have read & write permissions for this directory
  # @param [String|Logger] logger Logger stream or instance
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

    File.open(fname, File::WRONLY | File::CREAT) do |f|
      f.write @request_body
      f.truncate f.pos
    end
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

  def content_type
    @content_type || "text/plain"
  end

  def http_get?
    @request_method.upcase == "GET"
  end

  def http_post?
    @request_method.upcase == "POST"
  end

  def fname
    "#{@storage}/#{@filename}"
  end
end
