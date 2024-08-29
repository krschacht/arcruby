fn[:dir, :path] { Dir.entries(_1).reject { [`.`, `..`].include?(it) } }
