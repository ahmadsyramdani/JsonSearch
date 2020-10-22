require_relative "./searchable.rb"

class Main
  def run
    puts "To quit application type /q"
    loop do
      while (1)
        print("Search > ")
        command = STDIN.gets.chomp #read user's input
        break if command == '/q'
        Searchable.new(command).run #calling search function and print the output
      end
      break
    end
  end

  Main.new().run
end
