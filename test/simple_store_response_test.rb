# frozen_string_literal: true

require "test_helper"
require_relative "../lib/simple_store_response.rb"

class SimpleStoreResponseTest < Minitest::Spec
  describe "#http_code" do
    before { subject.process_request! }

    let(:request_body) { nil }
    let(:filename) { "file.json" }
    let(:storage) { "#{File.dirname(__FILE__)}/fixtures" }
    let(:fname) { "#{storage}/#{filename}" }

    subject do
      SimpleStoreResponse.new(
        request_method: request_method,
        request_body: request_body,
        filename: filename,
        storage: storage,
        logger: nil
      )
    end

    context "when request is GET" do
      let(:request_method) { "GET" }

      context "document exists" do
        it "sets status to 200 OK" do
          assert_equal 200, subject.http_code
        end
      end

      context "document does not exist" do
        let(:filename) { "notfound.json" }

        it "sets status to 404 NOT FOUND" do
          assert_equal 404, subject.http_code
        end
      end
    end

    context "when request is POST" do
      let(:request_method) { "POST" }
      let(:request_body) { "Test payload." }
      let(:filename) { "new_filename" }

      context "when request_body is not empty" do
        after { File.unlink(fname) if File.exist?(fname) }

        it "sets status to 200 OK" do
          assert_equal 200, subject.http_code
        end
      end

      context "when request_body is empty" do
        let(:request_body) { "" }

        it "sets status to 400 BAD REQUEST" do
          assert_equal 400, subject.http_code
        end
      end
    end
  end

  describe "#body" do
    let(:document_str) { File.read(fname) }
    let(:filename) { "file.json" }
    let(:storage) { "#{File.dirname(__FILE__)}/fixtures" }
    let(:fname) { "#{storage}/#{filename}" }

    subject do
      SimpleStoreResponse.new(
        request_method: request_method,
        request_body: request_body,
        filename: filename,
        storage: storage,
        logger: nil
      )
    end

    before { subject.process_request! }

    context "when request is GET" do
      let(:request_method) { "GET" }
      let(:request_body) { nil }

      context "document exists" do
        it "sets content in data field" do
          assert_match JSON.parse(subject.body)["data"], document_str
        end
      end

      context "document does not exist" do
        let(:filename) { "notfound.json" }

        it "includes error" do
          assert_match "error", subject.body
        end
      end
    end

    context "when request is POST" do
      let(:request_method) { "POST" }
      let(:request_body) { "Test payload." }
      let(:filename) { "new_filename" }

      context "when request_body is not empty" do
        after { File.unlink(fname) if File.exist?(fname) }

        it "stores the contents" do
          assert_path_exists fname
        end
      end

      context "when request_body is empty" do
        let(:request_body) { "" }

        it "adds an error" do
          assert_match "error", subject.body
        end
      end
    end
  end

  describe "#fname" do
    let(:filename) { "file.json" }
    let(:storage) { "#{File.dirname(__FILE__)}/fixtures" }

    subject { SimpleStoreResponse.new(request_method: nil, request_body: nil, filename: filename, storage: storage) }

    it "gives path" do
      assert_includes subject.fname, filename
      assert_includes subject.fname, storage
    end
  end
end
