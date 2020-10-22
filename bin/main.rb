require_relative "./searchable.rb"

class Main
  def run
    puts "To quit application type /q"
    loop do
      while (1)
        print("Search > ")
        command = STDIN.gets.chomp
        break if command == '/q'
        Searchable.new(command).run
      end
      break
    end
  end

  Main.new().run
end
