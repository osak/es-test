require 'time'
require 'json'

Envelope = Struct.new(:timestamp, :raw, :level, :message_log, :tool_call_log) do
  def to_h
    {
      timestamp: timestamp.strftime("%Y-%m-%dT%H:%M:%S.%N%:z"),
      raw: raw,
      level: level,
      message_log: message_log&.to_h,
      tool_call_log: tool_call_log&.to_h,
    }
  end
end
MessageLog = Struct.new(:message, :tool_call)
ToolCallLog = Struct.new(:id, :name, :params_json, :response_json)

class BaseParser
  def initialize
    @buf = ''
  end

  def consume!(line)
    if line =~ /^\[([^\]]+)\]\[/
      # Beginning of new log entry
      log = consume_buf!
      if log != nil
        emit_log(log)
      end
    end

    if @buf != ""
      @buf += "\n"
    end
    @buf += line
  end

  def flush!
    consume_buf!
  end

  private
  def consume_buf!
    log = parse_buf
    @buf = ''
    log
  end

  def parse_buf
    if @buf == ''
      nil
    elsif m = @buf.match(/^\[([^\]]+)\]\[([^\]]+)\](.*)/m)
      _, timestamp_str, level_str, rest = m.to_a
      timestamp = Time.parse(timestamp_str)
      level = level_str.strip
      log_body = parse_body(rest)
      Envelope.new(timestamp, @buf, level, log_body[:message_log], log_body[:tool_call_log])
    else
      STDERR.puts "parse error: #{@buf}"
      nil
    end
  end

  def parse_body(text)
    log = parse_tool_call(text)
    return { tool_call_log: log } if log != nil

    log = parse_message(text)
    return { message_log: log } if log != nil

    STDERR.puts "Unknown log body format: #{text}"
    {}
  end

  def parse_tool_call(text)
    if m = text.strip.match(/^Tool call (.*)<(.*)>\((.*)\) => (.*)$/)
      _, id, name, params_json, response_json = m.to_a
      ToolCallLog.new(id, name, params_json, response_json)
    else
      nil
    end
  end

  def parse_message(text)
    message = text
    if m = text.match(/\(calling (.*)\)$/m)
      tool_call = m[1]
    end
    MessageLog.new(message, tool_call)
  end

  def emit_log(log)
    raise 'Not implemented'
  end
end

class LogParser < BaseParser
  private 
  def emit_log(log)
    puts JSON.dump(log.to_h)
  end
end

def main
  parser = LogParser.new
  ARGF.each_line do |line|
    parser.consume!(line)
  end
  parser.flush!
end

main
