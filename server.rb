require 'socket'

# HTTP reply(200)
def http_reply200(c, path)
  size = File.stat(path).size.to_s
  case(path.split(".").last)
  when "html"
    type = "text/html"
  when "jpg"
    type = "image/jpeg"
  end
  c.puts "HTTP/1.0 200 OK"
  c.puts "Content-Length: " + size
  c.puts "Content-Type: " + type
  c.puts

  File.open(path) do |file|
    file.each_line do |line|
      c.puts line
    end
  end
end

# HTTP reply(404)
def http_reply404(c)
  c.puts "HTTP/1.0 404 Not Found"
  c.puts
end

# main loop
server = TCPServer.new 16503
pids = []
loop do
  # accept and start thread
  Thread.start(server.accept) do |client|
    #puts "open: " + Thread.current.to_s

    # parse header
    headers = []
    while header = client.gets
      break if header.chomp.empty?
      headers << header.chomp
    end

    # check file
    filepath = "html" + headers.first.split(" ")[1]
    filepath += "index.html" if filepath == "html/"
    #puts "access: " + filepath
    if File.exist?(filepath)
      # reply 200
      http_reply200(client, filepath)
    else
      # reply 404
      http_reply404(client)
    end

    # end thread
    client.close
    #puts "close: " + Thread.current.to_s
  end
end

