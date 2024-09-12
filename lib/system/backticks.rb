module Kernel
  alias_method :original_backticks, :`

  def `(str)
    # Escape double quotes within the string
    str = str.gsub(/'/, "\'")

    # Evaluate the string within the current context
    eval("'#{str}'", binding, __FILE__, __LINE__)
  end
end

class String
  alias_method :original_inspect, :inspect

  def inspect
    "`#{self}`"
  end
end

# https://www.reddit.com/r/ruby/comments/1f88k7y/is_it_a_really_bad_idea_to_override_backticks/
#
# First, I override backticks as planned in the initial post. Then, any time I import a gem I do so with safe_require “gem_name”, module: “core_gem_module”
#
# This safe_require method will do something like this:
#
# def safe_require(gem_name, module:) Thread.current[:use_original_backticks] = true require gem_name ensure Thread.current[:use_original_backticks] = false end
#
# make_module_safe(module)
#
# So while the import is running, a global will be flipped which my backticks monkey patch will check for. This will help ensure that no gem code breaks in the moment require is running. And then make_module_safe() will find all the subclasses within the module, and all submodules within it, and dynamically create a refinement and apply it to the class. The refinement will revert the backticks behavior back to default.
#
# If this works, it could be elegant. It would mean that backticks now “just work” in the way I would like them to. 99% of the time this won’t cause any problems but I avoid the 1% with a simple switch from using “require” to “safe_require”.
#
# Any feedback on this?