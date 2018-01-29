fout = File.open(ARGV[1], 'w:utf-8')

File.open(ARGV[0], 'r:utf-8') do |f|
    new_q = false
  while c = f.getc
    if c == '"'
        new_q = !new_q
    elsif new_q && (c == "\r" || c== "\n")
        c = " "
    end
    fout.write(c)
  end
end

fout.close()
