

# From:http://rpheath.com/posts/341-ruby-inject-with-index

module Enumerable
  def inject_with_index(injected)
    each_with_index{ |obj, index| injected = yield(injected, obj, index) }
    injected
  end
end
