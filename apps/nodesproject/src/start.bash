#!/bin/bash

erl -sname bob worker:start() &

erl -sname alice worker:start() &

erl -sname distributor distributor:start() &

 