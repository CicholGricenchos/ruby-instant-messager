﻿# encoding: utf-8
require 'socket'
require 'thread'

module ClientManager
  def self.clients
    @clients
  end

  def self.init
    @clients = []
  end

  def self.send_to_all(data)
    puts data
    @clients.each do |c|
        c.body.send(data, 0) if c.recv_thread.alive?
    end
  end
end

class Client
  attr_accessor :body, :recv_thread, :name

  def initialize(c)
    @body = c
    @name = @body.recv(150, 0)
    puts "Client accepted. Whose name is #{@name}."
    @recv_thread = Thread.new do
      begin
        loop do
          data = @body.recv(150, 0)
          ClientManager.send_to_all(@name + "   #{Time.now}\n")
          ClientManager.send_to_all(data)
        end
      rescue
        puts "#{self.name} off-lined.\n"
        @clients.delete(self)
      end
    end
  end
end

ClientManager.init
server = TCPServer.open(2000)
puts 'Listening..'
loop { ClientManager.clients << Client.new(server.accept) }