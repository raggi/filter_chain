class FilterChain::Filters::None < FilterChain::Filter
  def initialize
    super(/(.*)/, false)
  end
end