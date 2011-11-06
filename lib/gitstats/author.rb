class Author
  include Comparable

  def self.include_mail=(include_mail)
    @@include_mail = include_mail
  end

  def self.include_mail
    @@include_mail ||= false
    @@include_mail
  end

  attr_reader :name
  attr_reader :email

  def initialize(name, email)
    @name = name
    @email = email
  end

  def <=>(b)
    to_i <=> b.to_i
  end

  def to_s
    if self.class.include_mail
      "#{name} <#{email}>"
    else
      name
    end
  end

  def eql?(b)
    to_s.hash == b.to_s.hash
  end

  def hash
    to_s.hash
  end
end

