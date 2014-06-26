class RealtimeBuildsController < FayeRails::Controller
  channel '/build_status/**' do
    subscribe do
      puts "Received on #{channel}: #{inspect}"
    end
  end
end
