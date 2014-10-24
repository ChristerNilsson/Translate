# encoding: UTF-8

#MODE=0 # Strings only.
MODE=1 # Strings, variable names, function names and comments. (default)

# TODO: The escape character, backslash is not handled. Workaround: change to "'" or '"' in the original file.
# TODO: Doesn't handle multiline comments. """ Save the string as one long line, embed \n.
# TODO: If 2 is missing it should be written instead of 5

@letters = 'abcdefghijklmnopqrstuvwxyzåäö_ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ'
@digits = '0123456789'

def trans word
  return word if word.swapcase == word
  return word if @ignore.include?(word)
  se = @hash[word]
  if se==nil
    @missing << word
    word
  else
    se
  end
end

def translate line
  line << "\n" if line[-1] != "\n"
  res = ''
  state = 0
  cand = ''
  line.size.times do |i|
    ch = line[i]
    case state
    when 0 # normal
      if ch.swapcase != ch
        state = 1
      elsif ch=="'"
        state = 2
      elsif ch=='"'
        state = 3
      elsif ch=='#'
        state = 4
      end
      if state==0
        res << ch
      else
        cand = ch
      end
    when 1 # name
      state = 0 if !(@letters + @digits).include?(ch)
      if state==0
        res << trans(cand) + ch if MODE==1
      else
        cand << ch
      end
    when 2 # string with delimiters ''
      state = 0 if ch=="'"
      cand << ch
      res << trans(cand) if state==0
    when 3 # string with delimiters ""
      state = 0 if ch=='"'
      cand << ch
      res << trans(cand) if state==0
    when 4 # comment #
      return res + (MODE==1 ? trans(cand + line.chomp[i..-1]) : '')
    end
  end
  res.chomp
end

def read_file line,filename,lang
  fn = line.gsub('@','')
  if fn==filename
    puts "Problem: Self Recursive Call #{filename}"
  else
    read_trans fn,lang
  end
end

def read_string line
  ch = line[0]
  if line.include?(ch + '|' + ch)
    en,cc = line.split(ch + '|' + ch)
    @hash[en + ch] = ch + cc
  else
    @hash[line]=line
  end
end

def read_comment line
  if line.include?('|#')
    en,cc = line.split('|#')
    @hash[en] = '#' + cc
  else
    @hash[line]=line
  end
end

def read_name line
  if line.include?('|')
    en,cc = line.split('|')
    @hash[en]=cc
  else
    @hash[line]=line
  end
end

def read_trans fn,lang
  if fn.include?('.')
    filename = 'ignore/' + fn
  else
    filename = 'phrases/' + lang + '/' + fn + '.' + lang
  end
  lines = File.open(filename,'r:UTF-8').readlines.map {|word|word.chomp}
  lines.each do |line|
    case line[0]
    when '@'; read_file(line,filename,lang)
    when "'"; read_string(line)
    when '"'; read_string(line)
    when '#'; read_comment(line) # if MODE==1
    else      read_name line  # if MODE==1
    end
  end
end

def get_filenames command
  filenames = []
  extensions = []
  command.each do |word|
    if word[0]=='.'
      extensions << word.gsub('.','')
    else
      filenames << word.gsub('.','')
    end
  end
  res = []
  extensions.each do |e|
    filenames.each do |f|
      res << [f,e]
    end
  end
  res
end

def execute command
  start = Time.now
  @ignore = File.open('ignore/python.txt','r:UTF-8').readlines.map {|word|word.chomp}
  @line_count = 0

  filenames = get_filenames(command)
  filenames.each do |filename,lang|
    @hash = {}
    @missing = []
    read_trans(filename, lang)
    original = File.open('original/' + filename + '.py').readlines
    translated = File.open('translated/' + lang + '/' + filename + '.py','w:UTF-8')
    original.each do |line|
      translated.puts translate(line)
    end
    translated.close

    missing = File.open('feedback/' + lang + '/' + filename + '.txt','w:UTF-8')
    @missing = @missing.sort.uniq
    @missing.each do |line|
      ch = line[0]
      extra = '|***'
      extra = '|# ***' if ch=='#'
      extra = '|"***"' if ch=='"'
      extra = "|'***'" if ch=="'"
      missing.puts line + extra
    end
    missing.close
    puts "#{@missing.count} lines written to feedback/#{lang}/#{filename}.txt"
    @line_count += original.size

  end

  secs = Time.now-start
  klpm = (60 * @line_count / secs / 1000).round
  puts
  puts "#{(1000*secs).round} ms  line_count: #{@line_count}  KLPM:#{klpm}"

end

if ARGV == []
  puts 'Example:'
  puts '  translate reversi .se'
else
  execute ARGV
end
