#!/usr/bin/env ruby
require "./lib/brackets"

# (= postdir* "arc/posts/"  maxid* 0  posts* (table))
~[:set, :@postdir, "rocket/posts/",  :@maxid, 0,  :@posts, [table]]

# (= blogtitle* "A Blog")
~[:set, :@blogtitle, "A Blog"]

# (deftem post  id nil  title nil  text nil)
~[:dftem, :POST,  :id, nil,  :title, nil,  :text, nil]

# (def load-posts ()
#   (each id (map int (dir postdir*))
#     (= maxid*      (max maxid* id)
#        (posts* id) (temload 'post (string postdir* id)))))
~[:df, :load_posts, [],
  [:each, :id, [:map, int, [:dir, @postdir]],
               [:set, :@maxid,       [:max, :@maxid, :id],
                      [@posts, :id], [:temload, :POST, [:string, @postdir, :id]]]]]

# (def save-post (p) (save-table p (string postdir* p!id)))
~[:df, :save_post, :p, [save_table, :p, [string, @postdir, :'p.id']]]

# (def post (id) (posts* (errsafe:int id)))
~[:df, :post, :id, [@posts, [int, :id]]]  # not sure what errsafe should do

# (mac blogpage body
#   `(whitepage
#      (center
#        (widtable 600
#          (tag b (link blogtitle* "blog"))
#          (br 3)
#          ,@body
#          (br 3)
#          (w/bars (link "archive")
#                  (link "new post" "newpost"))))))

# (defop viewpost req (blogop post-page req))

# (def blogop (f req)
#   (aif (post (arg req "id"))
#        (f (get-user req) it)
#        (blogpage (pr "No such post."))))

# (def permalink (p) (string "viewpost?id=" p!id))
~[:df, :permalink, :p, [:string, 'viewpost?id=', :'p.id']]

# (def post-page (user p) (blogpage (display-post user p)))

# (def display-post (user p)
#   (tag b (link p!title (permalink p)))
#   (when user
#     (sp)
#     (link "[edit]" (string "editpost?id=" p!id)))
#   (br2)
#   (pr p!text))

# (defopl newpost req
#   (whitepage
#     (aform [let u (get-user _)
#              (post-page u (addpost u (arg _ "t") (arg _ "b")))]
#       (tab (row "title" (input "t" "" 60))
#            (row "text"  (textarea "b" 10 80))
#            (row ""      (submit))))))

# (def addpost (user title text)
#   (let p (inst 'post 'id (++ maxid*) 'title title 'text text)
#     (save-post p)
#     (= (posts* p!id) p)))

# (defopl editpost req (blogop edit-page req))

# (def edit-page (user p)
#   (whitepage
#     (vars-form user
#                `((string title ,p!title t t) (text text ,p!text t t))
#                (fn (name val) (= (p name) val))
#                (fn () (save-post p)
#                       (post-page user p)))))

# (defop archive req
#   (blogpage
#     (tag ul
#       (each p (map post (rev (range 1 maxid*)))
#         (tag li (link p!title (permalink p)))))))

# (defop blog req
#   (let user (get-user req)
#     (blogpage
#       (for i 0 4
#         (awhen (posts* (- maxid* i))
#           (display-post user it)
#           (br 3))))))

# (def bsv ()
#   (ensure-dir postdir*)
#   (load-posts)
#   (asv))

~[df, :bsv, [], [progn,
  [ensure_dir, @postdir],
  [load_posts],
  [asv]]]

binding.irb