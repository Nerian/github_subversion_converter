GitHub Subversion Converter – GitSC
====================================   

GitSC has nothing to do with StarCraft. GitSC is a ruby command line script that will allow you to transfer the commits from a  GitHub SVN repo to a real repo anywhere.

It really can transfer commits from SVN repos hosted anywhere, but GitSC is optimised to deal with GitHub SVN little nuances. 

It can keep transferring commits from origin to destiny after the initial transfer. It just pick where it left.

What GitSC does is to commit changes one by one from the origin to destiny. In such process it performs some validations to deal with GitHub SVN little nuances, namely Phantom commits ( I created a fancy word, yeah! ^_^ ). So it is VERY slow. Transferring 50 commits can take 5 min. 

A Phantom commit happens when the previous commit is exactly the same as the commit we are trying to commit. SVN won't allow such a commit so it won't never happen on a real SVN server. But as I said, GitHub does a little magic behind the scene and it removes the .gitignore files. Many times you just make a commit whose only change was the .gitignore file. In such case, you have a phantom commit in svn fake repo. GitCS it is capable of dealing with this, rest assured.

So if you just want to clone real SVN repos, not hosted at GitHub, I recommend you to check [svnsync](http://svnbook.red-bean.com/en/1.5/svn.ref.svnsync.html SVNSYNC). 
 
Current Status
====================================

* Transferring full GitHub repo to another SVN repo works. | it's done
* Transferring full GitHub repo to another SVN repo that already have commits | it's done
* Make commits retain the author name | it's done.
* Make commits retain the commit message | it's done.  
                    

* Make commits have the right date it is not done. 

The last feature requires modifying hooks script on the server side, which sucks and I don't really need it. So chances are that I won't add this feature. Feel free to fork the project and do it yourself, I will accept a pull request. 

The line you have to touch in on the method "perform\_conversion\_operations" inside "lib/conversor.rb". The last lines of that method call the method "update\_destiny\_server\_commit\_date\_to\_origin\_commit\_date()". You just have to implement that.


How to Use
====================================
Currently I just have the ruby class and cucumber tests. So it is not ready for use right now.

But the expected way of using is:

	GitSC --origin-repo *address* --destiny-repo *address*  
	
Take note, if two persons do this a the same time you could end with many duplicated commits. So I recommend that if you are working with other people your team designate just one person to do it. 	

                                              

Why are you doing this?
====================================
GitSC was born to fill a need. I had a couple of projects at school and it was mandatory to host the project at the faculty SVN servers. But I didn't want to use such useless version control system. I am a branch consuming addict. I can't live without superb branch support. SVN just doesn't give me that. 

At the same time I was learning ruby and reading Pragmatic Programmers's Behaviour Driven Development with Cucumber and RSpec. So it was the perfect occasion to apply the concepts. As I was developing this, I added a new trait to my personality. I am a test addict. Now I can't live without heavy testing :)
                                                               
Do you need help?
===================================

Yes! The application needs to be able to deal with very different scenarios. So Tests are very much welcomed. Also, I am not a Ruby expert – give time – so any kind of code review would be very much appreciate.

Thank you for your time.
  




 