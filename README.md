GitHub Subversion Converter – GitSC
====================================   

GitSC has nothing to do with StarCraft. GitSC is a ruby command line script that will allow you to transfer the commits from a  GitHub SVN repo to a real repo anywhere.

It really can transfer commits from SVN repos hosted anywhere, but GitSC is optimised to deal with GitHub SVN little nuances. 

It can keep transferring commits from origin to destiny after the initial transfer. It just pick where it left.

What GitSC does is to commit changes one by one from the origin to destiny. In such process it performs some validations to deal with GitHub SVN little nuances, namely Phantom commits ( I created a fancy word, yeah! ^_^ ). So it is VERY slow. Transferring 50 commits can take 5 min. 

So if you just want to clone real SVN repos, not hosted at GitHub, I recommend you do check [svnsync](http://svnbook.red-bean.com/en/1.5/svn.ref.svnsync.html SVNSYNC). 
 
Current Status
====================================

* Transferring full GitHub repo to another SVN repo works
* Transferring full GitHub repo to another SVN repo that already have commits seems to work, but I want to write more tests.
* Make commits retain the author name it is not implemented yet
* Make commits retain the commit message it is not implemented yet.


How to Use
====================================
Currently I just have the ruby class and cucumber tests. So it is not ready for use right now.

But the expected way of using is:

	GitSC --origin-repo *address* --destiny-repo *address*

                                              

Why are you doing this?
====================================
GitSC was born to fill a need. I had a couple of projects at school and it was mandatory to host the project at the faculty SVN servers. But I didn't want to use such useless version control system. I am a branch consuming addict. I can't live without superb branch support. SVN just doesn't give me that. 

At the same time I was learning ruby and reading Pragmatic Programmers's Behaviour Driven Development with Cucumber and RSpec. So it was the perfect occasion to apply the concepts. As I was developing this, I added a new trait to my personality. I am a test addict. Now I can't live without heavy testing :)
                                                               
Do you need help?
===================================

Yes! The application needs to be able to deal with very different scenarios. So Tests are very much welcomed. Also, I am not a Ruby expert – give time – so any kind of code review would be very much appreciate.

Thank you for your time.
  




 