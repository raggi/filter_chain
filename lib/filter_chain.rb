module FilterChain
  module Filters; end
  module Chains; end
  
  def self.filter(name)
    class_name = name.split('_').map { |part| part.capitalize }.join
    require "filter_chain/filters/#{name}"
    Filters.const_get(class_name).new
  rescue LoadError
    raise "Could not load filter file: filter_chain/filters/#{name}"
  rescue NameError
    raise "Could not find filter class: FilterChain::Filters::#{class_name}"
  end
  
  def self.chain(name)
    require "filter_chain/chains/#{name}"
    Chains.const_get(name.capitalize).new
  rescue LoadError
    raise "Could not load chain file: filter_chain/chains/#{name}"
  rescue NameError
    raise "Could not find chain class: FilterChain::Chains::#{name.capitalize}"
  end

  class Filter
    attr_accessor :rexp, :positive
    def initialize(rexp = /^(.*)$/, positive = true)
      @rexp = rexp
      @positive = positive
    end

    def match(line)
      if line =~ @rexp
        @positive ? Regexp.last_match : nil
      else
        line
      end
    end
  end

  class Chain
    attr_accessor :filters

    def initialize
      @filters = []
      yield self if block_given?
    end

    def add_filter(filter, positive = true)
      @filters ||= []
      filter = case filter
      when Regexp
        filter = Filter.new(filter, positive)
      when Filter
        filter
      when Chain
        filter
      end

      @filters << filter
    end

    def pos(filter)
      add_filter(filter, true)
    end

    def neg(filter)
      add_filter(filter, false)
    end

    def match(line)
      @filters.each do |filter|
        case result = filter.match(line)
        when line
          next
        when nil
          return
        else
          return result
        end
      end
      line
    end
  end

end