#!/usr/bin/ruby

class ProjectExecution
  require 'openssl'
  require 'stringio'
  require 'open-uri'
  require 'curb'
  require 'base64'
  require "io/console"

  def file_backup file = __FILE__ , dir = '/tmp/', append = ('-' + Time.now.hash.abs.to_s)
    contents = File.read file
    File.write (dir + '/' + file + append), contents
    contents
  end


  def save_file url, location, wtime=0
  require 'open-uri'
   require 'fileutils'
   FileUtils.mkdir_p File.dirname location # note "~" doesn't work
    contents = open(url).read
    r = File.write location, contents
    sleep wtime
    contents
  end

  def url_to_str url
  require 'open-uri'
    contents = open(url).read
  end

  def dec args=ARGV
    password, iv, encrypted = args
    decipher = OpenSSL::Cipher.new('aes-128-cbc')
    decipher.decrypt
    decipher.key = Digest::SHA256.hexdigest password
    decipher.iv = Base64.decode64 iv
    plain = decipher.update(Base64.decode64 encrypted) + decipher.final
  end


  def read_and_output_simple args=ARGV

    STDERR.print "iv:"
    # basically => any string other than "" or the default one:
    iv = args.shift.to_s.split("\0").first || (url_to_str 'out.enc.iv.base64')
    STDERR.puts
    STDERR.print "encrypted:"
    # basically => any string other than "" or the default one:
    encrypted = args.shift.to_s.split("\0").first || (url_to_str 'out.enc.encrypted.base64')
    STDERR.puts "#{encrypted}"
    STDERR.puts
    STDERR.print "password:"
    password = args.shift || begin STDIN.noecho{ gets}.chomp rescue gets.chomp end
    STDERR.puts
    pw_plain = dec [password, iv, encrypted]
    STDOUT.puts pw_plain
  end

  def main args=ARGV
    file_backup
    read_and_output_simple args
  end
end

ProjectExecution.new.main