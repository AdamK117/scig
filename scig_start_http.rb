require 'sinatra'

def scig_start_http(argv)
  options = {
    port: 4000,
    device_spec_path: nil,
    device_port_path: nil
  }

  option_parser = OptionParser.new do |opts|
    opts.banner = "Usage: scig start http [options]"

    opts.on("-p", "--port") do |port_number|
      options[:port] = port_number
    end
  end

  begin
    option_parser.parse! argv
  rescue
    OptionParser::InvalidOption
  end

  # Parse & validate the CLI arguments
  # Parse & validate the device spec
  # Validate can open handle to device
  # Create connection to device
  # Validate can start http server
  # Create http API
  # Boot server
  
  STDERR.puts('NYI')
  exit 1
end
