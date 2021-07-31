# Ruby HTTPD CGI Example

PoC to get a Ruby [CGI script] in Apache's HTTPD server.

One can use the [CGI class] with the caveat that whenever instantiating it, it
will read STDIN to parse the request body and that's troublesome when using
a format other than URL Form Encoded, e.g., JSON.

What one can do is first read STDIN and then instantiate `cgi = CGI.new` to get
easier handling of the request.

## How To

```bash
$ echo "build the image"
$ docker build . -t httpd:ruby-cgi
$ echo "spin up a container"
$ ./bin/run_httpd
$ curl -X POST http://localhost:8080/cgi-bin/simple-store --data '{"message":"hello"}'
$ cat cgi-bin/message.json
{"message":"hello"}
```

[CGI script]: https://httpd.apache.org/docs/2.4/howto/cgi.html
[CGI class]: https://ruby-doc.org/stdlib-3.0.2/libdoc/cgi/rdoc/CGI.html
