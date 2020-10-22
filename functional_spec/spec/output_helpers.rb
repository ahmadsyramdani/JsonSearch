module OutputHelpers
  def clear_output(output)
    new_output = delete_printed_command(output)
    return new_output
  end

  def delete_printed_command(text)
    new_text = text.gsub("To quit application type /q", '')
    new_text = new_text.gsub("\n", '')
    new_text = new_text.gsub("Search >", '')
    new_text = new_text.strip
    return new_text
  end
end
