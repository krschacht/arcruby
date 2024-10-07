require 'socket'

~[:df, :asv, [],
  <<-RUBY
    puts 'ready to port 8080'
    server = TCPServer.new('localhost', 8080)
    srvops = {
      "/blog" => ->(request) {
        "HTTP/1.1 200 OK\n" +
        "Content-Type: text/html\n\n" +
        "<html><body bgcolor=#ffffff alink=#0000be><center><table width='600'><tr><td><b><a href='blog'>A Blog</a></b><br><br><br>" +
        "<br><br><br>" +
        "<a href='archive'>archive</a> | <a href='newpost'>new post</a></td></tr></table></center></body></html>"
      }
    }

    loop do
      client = server.accept
      request_line = client.gets
      next unless request_line

      # Parse the request line
      method, path, _ = request_line.split

      # Find the route in the routing table
      response = if srvops.key?(path)
                  srvops[path].call(request_line)
                else
                  "HTTP/1.1 404 Not Found\nContent-Type: text/plain\n\nRoute not found"
                end

      # Send the response
      client.print response
      puts method + " " + path

      client.close
    end
  RUBY
]