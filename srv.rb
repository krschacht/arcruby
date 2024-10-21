# (mac defop-raw (name parms . body)
#   (w/uniq t1
#     `(= (srvops* ',name)
#         (fn ,parms
#           (let ,t1 (msec)
#             (do1 (do ,@body)
#                  (save-optime ',name (- (msec) ,t1))))))))

# (mac defopr-raw (name parms . body)
#   `(= (redirector* ',name) t
#       (srvops* ',name)     (fn ,parms ,@body)))

# (mac defop (name parm . body)
#   (w/uniq gs
#     `(do (wipe (redirector* ',name))
#          (defop-raw ,name (,gs ,parm)
#            (w/stdout ,gs (prn) ,@body)))))

#~[:df, :dfop, [:name, :parm, :body], [progn, [prn, 'hello'], :body]]] # should be defined using mac or lit but instead I just added another exclusion for dfop in array_proc_execution
