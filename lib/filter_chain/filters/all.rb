class FilterChain::Filters::All < FilterChain::Filter
  def initialize
    super(/(.*)/)
  end
end