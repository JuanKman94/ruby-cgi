# frozen_string_literal: true

require "test_helper"
require_relative "../../lib/simple_store_response.rb"

class SimpleStoreResponseTest < Minitest::Spec
  describe "#body" do
    let(:document_str) { '{"saludo":"hola"}' }
    let(:request_uri) { "/path/to/file.json" }

    subject { SimpleStoreResponse.new(request_method, request_uri, req_body) }

    before { subject.process_request! }

    context "when request is GET" do
      let(:request_method) { "GET" }
      let(:req_body) { nil }

      context "document exists" do
        it "matches document content" do
          assert_match document_str, subject.body
        end
      end

      context "document does not exist" do
        it "includes error" do
          assert_match "error", subject.body
        end
      end
    end

    context "when request is POST" do
      let(:request_method) { "POST" }
      let(:req_body) { document_str }

      context "when req_body is not empty" do
        it "stores the contents" do
        end
      end

      context "when req_body is empty" do
        let(:req_body) { "" }

        it "adds an error" do
          assert_match "error", subject.body
        end
      end
    end
  end

  describe "#fname" do
    let(:http_method) { "GET" }
    let(:http_uri) { "/path/to/file.json" }
    subject { SimpleStoreResponse.new(http_method, http_uri, nil) }

    it "gives uri basename" do
      assert_equal "file.json", subject.fname
    end

    context "when request is POST" do
      let(:http_method) { "POST" }

      it "gives uri basename" do
        assert_equal "file.json", subject.fname
      end
    end
  end
end
