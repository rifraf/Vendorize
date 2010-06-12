@echo off
call rvm 185
  call rake clean test
call rvm 186
  call rake clean test
call rvm 187
  call rake clean test
call rvm 191
  call rake clean test
call rvm jruby
  call rake clean test
call rvm ironruby
  call rake clean test
