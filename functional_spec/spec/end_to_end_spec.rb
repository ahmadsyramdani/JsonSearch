require 'spec_helper'
require 'pry'
require 'table_print'

RSpec.describe 'End To End Suite', type: :aruba do

  describe "Run the search" do
    before(:each) do
      spec_dir = File.join(File.dirname(File.expand_path(__FILE__)))
      bin_dir = File.join(spec_dir,'..','..','bin')
      bin_dir = bin_dir.gsub(' ', '\ ')
      run_command("ruby #{bin_dir}/main.rb")
    end

    describe "search text" do
      it "should no data" do
        type ""
        stop_all_commands
        output = clear_output(last_command_started.output)
        expect(output).to eq("No data.")
      end

      it "should appear name of language only" do
        type "Lips Common"
        stop_all_commands
        output = clear_output(last_command_started.output)
        expect(output).to include("Common Lisp")
      end

      it "should appear name of language only second test" do
        type "Lisp"
        stop_all_commands
        output = clear_output(last_command_started.output)
        expect(output).not_to include("Common Lisp")
        expect(output).to include("Lisp")
      end

      it "should appear exact matches" do
        type "Interpreted \"Thomas Eugene\""
        stop_all_commands
        output = clear_output(last_command_started.output)
        expect(output).not_to include("Haskell")
        expect(output).to include("BASIC")
      end

      it "should appear from different field" do
        type "Scripting Microsoft"
        stop_all_commands
        output = clear_output(last_command_started.output)
        expect(output).not_to include("Gary Grossman")
        expect(output).to include("Microsoft")
      end

      it "should appear with negative searches" do
        type "John --array"
        stop_all_commands
        output = clear_output(last_command_started.output)
        expect(output).not_to include("Chapel")
        expect(output).not_to include("Fortran")
        expect(output).to include("BASIC")
        expect(output).to include("Haskell")
        expect(output).to include("Lisp")
      end

      it "should appear with multiple negative searches" do
        type "John --array --basic --metaprogramming"
        stop_all_commands
        output = clear_output(last_command_started.output)
        expect(output).not_to include("Chapel")
        expect(output).not_to include("Fortran")
        expect(output).not_to include("BASIC")
        expect(output).not_to include("Lisp")
        expect(output).not_to include("Haskell")
        expect(output).to include("S-Lang")
      end

      it "should appear with global searches" do
        type "Data-oriented"
        stop_all_commands
        output = clear_output(last_command_started.output)
        expect(output).to include("SQL")
        expect(output).to include("Visual FoxPro")
        expect(output).not_to include("Visual Basic")
        expect(output).not_to include("XL")
      end
    end
  end
end
