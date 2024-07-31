require 'json'
require 'net/http'
require 'pp'

docs = ARGF.read.lines

request = []
docs.each do |doc|
  op = {create: {_index: "test"}}
  doc_json = JSON.parse(doc)
  if doc_json['_id']
    op[:create][:_id] = doc_json['_id']
    doc_json.delete('_id')
  end
  request << JSON.dump(op)
  request << JSON.dump(doc_json)
end

Net::HTTP.start('localhost', 9200) do |http|
  req = Net::HTTP::Post.new("/_bulk")
  req.body = request.join("\n") + "\n"
  req.content_type = "application/json"
  response = http.request(req)

  puts response.code
  puts response.body
end
