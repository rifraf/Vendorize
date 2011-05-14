@echo off
rem
rem The 'rvm' below is implemented in a fake rvm.bat file that
rem was hacked together before pik. 
rem
rem Test prerequisites: rspec (gem install rspec --version 1.3.0)
rem
rem call rvm 185
call pik 1.8.5
  call rake clean test
rem call rvm 186
call pik 1.8.6
  call rake clean test
rem call rvm 187
call pik 187-www
  call rake clean test
rem call rvm 191
call pik 192-Nanoc
  rem has: warning: loading in progress, circular require considered harmful
  call rake clean test
call pik 1.9.2p180  
  call rake clean test
rem call rvm jruby
call pik "jruby 1.6.1"
  call rake clean test
rem call rvm ironruby
call pik "IronRuby 1.1.3.0"
  call rake clean test
rem call pik "IronRuby 1.1.4.0"
rem   call rake clean test
