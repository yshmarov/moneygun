class HelloWorldJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "Hello, world!"
    # Do something later
  end
end
