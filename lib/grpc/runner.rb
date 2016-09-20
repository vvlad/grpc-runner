require "grpc/runner/version"
require "grpc"

module GRPC::Runner
  @services = Set.new

  module_function

  def services
    @services
  end

  def run
    @services.each do |service|
      server.handle(service)
    end
    server.run_till_terminated
  end

  def address
    "0.0.0.0:" << ENV.fetch("PORT", "8083")
  end

  def server
    @server ||= begin
      server = GRPC::RpcServer.new
      server.add_http2_port(address, :this_port_is_insecure)
      server
    end
  end
end

module GRPC::GenericService::Dsl
  alias dsl_inherited inherited

  def inherited(subclass)
    GRPC::Runner.services << subclass
    dsl_inherited(subclass)
  end
end
