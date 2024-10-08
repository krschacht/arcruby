load-posts
save-post
post
blogpage
viewpost
blogop
permalink
post-page
display-post
newpost
addpost
editpost
edit-page
archive
blog
bsv

require 'pry'
# system.rb

ddef = ->(*args) { args[1] }

ddef[ :sys, :cmd ] { system(cmd) }

(echo)

(def concat (a,b) (string a, " + ", b))

[ddef, :concat, [:a, :b], %[string, a, " + ", b] ]
_[ddef, :concat, [:a, :b]] { [string, :a, " + ", :b] }
ddef[:concat, [:a, :b]] { [string, :a, " + ", :b] }

concat = ->(a, b) { string[a, " + ", b] }

greet1 = ->(name) { "hello #{name}" }
greet1["keith"]

ddef = ->(name, *args, &block) {
  local_variable_set(name, ->(*args) { block[*args] })
}

ddef[:greet2, :name] { "hello #{_1}" }
@greet2["keith"]

sys = ->(cmd){ system(cmd) }
evl = ->(s){ eval(s) }
string = ->(*args){ args.join }
upcase = ->(s){ s.to_s.upcase }
sym = ->(s){ s.to_sym }
ivar_set = ->(key, val){ instance_variable_set(key.to_s, val) }
const_set = ->(key, val){ Object.const_set(upcase[key], val) }
struct = ->(*args){ Struct.new(*map[sym, args]) }
set = ->(*pairs){ pairs.each_slice(2) {|k, v| ivar_set[k, v] }}
dir_exists = ->(path){ Dir.exist?(path) }
iif = ->(val, &proc){ val && proc[] }
uunless = ->(val, &proc){ !val && proc[] }

# arc.rb

car = ->(lst){ lst.first }
cdr = ->(lst){ lst.drop(1) }
int = ->(s){ s.to_i }
each = ->(*args, &proc){ args.each { |item| proc.call(item) }}
map = ->(fn, lst){ lst.map { |item| fn[item] }}
max = ->(lst){ lst.max }
min = ->(lst){ lst.min }
ensure_dir = ->(path){
  uunless[dir_exists[path]] {
    sys[string["mkdir -p ", path]] }}

deftem = ->(*args){ const_set[car[args], Struct.new(cdr[args]) }

# ac.rb

dir = ->(path){ Dir.entries(path).reject { |entry| entry == '.' || entry == '..' } }


# blog.rb

# Blog tool example.  20 Jan 08, rev 21 May 09.
#
# To run:
# arc> (load "blog.arc")
# arc> (bsv)
# go to http://localhost:8080/blog

# (= postdir* "arc/posts/"  maxid* 0  posts* (table))
set[postdir: "arc/posts/"  maxid: 0,  posts: nil ]

# (= blogtitle* "A Blog")
set[blogtitle: "A Blog"]

# (deftem post  id nil  title nil  text nil)
deftem[:post, id: nil,  title: nil,  text: nil ]

# (def load-posts ()
#   (each id (map int (dir postdir*))
#     (= maxid*      (max maxid* id)
#        (posts* id) (temload 'post (string postdir* id)))))
deff[:load_posts, []
  _[each, :id, _[map, int, _[dir, @postdir]],
    _[set,


load_posts = ->(){
  each[id, map[int, dir[@postdir]]] { |id|
    set[@maxid,     max[@maxid, id]
        (posts* id) (temload 'post (string postdir* id)))
  }
}

(def save-post (p) (save-table p (string postdir* p!id)))

(def post (id) (posts* (errsafe:int id)))

(mac blogpage body
  `(whitepage
     (center
       (widtable 600
         (tag b (link blogtitle* "blog"))
         (br 3)
         ,@body
         (br 3)
         (w/bars (link "archive")
                 (link "new post" "newpost"))))))

(defop viewpost req (blogop post-page req))

(def blogop (f req)
  (aif (post (arg req "id"))
       (f (get-user req) it)
       (blogpage (pr "No such post."))))

(def permalink (p) (string "viewpost?id=" p!id))

(def post-page (user p) (blogpage (display-post user p)))

(def display-post (user p)
  (tag b (link p!title (permalink p)))
  (when user
    (sp)
    (link "[edit]" (string "editpost?id=" p!id)))
  (br2)
  (pr p!text))

(defopl newpost req
  (whitepage
    (aform [let u (get-user _)
             (post-page u (addpost u (arg _ "t") (arg _ "b")))]
      (tab (row "title" (input "t" "" 60))
           (row "text"  (textarea "b" 10 80))
           (row ""      (submit))))))

(def addpost (user title text)
  (let p (inst 'post 'id (++ maxid*) 'title title 'text text)
    (save-post p)
    (= (posts* p!id) p)))

(defopl editpost req (blogop edit-page req))

(def edit-page (user p)
  (whitepage
    (vars-form user
               `((string title ,p!title t t) (text text ,p!text t t))
               (fn (name val) (= (p name) val))
               (fn () (save-post p)
                      (post-page user p)))))

(defop archive req
  (blogpage
    (tag ul
      (each p (map post (rev (range 1 maxid*)))
        (tag li (link p!title (permalink p)))))))

(defop blog req
  (let user (get-user req)
    (blogpage
      (for i 0 4
        (awhen (posts* (- maxid* i))
          (display-post user it)
          (br 3))))))

# (def bsv ()
#   (ensure-dir postdir*)
#   (load-posts)
#   (asv))

bsv = ->(){
  ensure_dir[@postdir]
  load_posts[]
  asv[]
}
