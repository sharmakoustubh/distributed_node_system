#!/bin/bash

erl -sname bob <<EOF 
c(worker),
worker:start().

EOF

#erl -sname alice <<EOF 
#c(worker),
#worker:start().

#EOF

#erl -sname distributor distributor:start() &
