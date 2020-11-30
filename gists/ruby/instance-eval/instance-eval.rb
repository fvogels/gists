class GreetingContext
  def hello(name)
    puts "Hello #{name}"
  end
end

def greeting(&block)
  context = GreetingContext.new.instance_eval(&block)
end

# Usage
greeting do
  hello 'John'
end
