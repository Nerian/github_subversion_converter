require 'find'

module Conversor
   class Conversor
                     
     # output is used for Cucumber testing.
     # svn_address_origin is the online address of the svn repo that we can to mirror from
     # svn_address_destiny is the online address of the svn repo that we want to mirror to  
     # svn_origin_name is the name of the checkout origin repo.
     # svn_destiny_name is the name of the checkout destiny repo.
     attr_accessor :output, :svn_address_origin, :svn_address_destiny, :svn_origin_name, :svn_destiny_name, :final_revision_that_you_want_to_mirror
      
     def initialize(output=STDOUT, svn_address_origin, svn_address_destiny)
       @output = output    
       @svn_origin_name = "origin"
       @svn_destiny_name = "destiny"
       @svn_address_origin = svn_address_origin
       @svn_address_destiny = svn_address_destiny
                        
       checkout_origin_repo()
       @final_revision_that_you_want_to_mirror = origin_repo_online_revision()          
     end                   
     
     def checkout_origin_repo(revision=nil)
      if(File.exist?("/tmp/"+@svn_origin_name))
        system("rm -Rf /tmp/"+@svn_origin_name) 
      end                        
      if not revision.nil?
        puts "checking out repo at "+@svn_address_origin+ " in /tmp/"+@svn_origin_name + " revision "+revision
        system("svn checkout "+"-r "+ revision +" "+@svn_address_origin + " /tmp/"+@svn_origin_name)
      else
        puts "checking out repo at "+@svn_address_origin+ " in /tmp/"+@svn_origin_name                                                                                         
        system("svn checkout "+@svn_address_origin + " /tmp/"+@svn_origin_name)
      end
      @output.puts "SVN origin Checkout complete"      
     end                                       
     
     def checkout_destiny_repo(revision=nil)       
       system("rm -Rf /tmp/"+@svn_destiny_name) 
       
       if not revision.nil?                                                                           
         puts "checking out repo at "+@svn_address_destiny+ " in /tmp/"+@svn_destiny_name+ " revision "+revision 
         system("svn checkout "+"-r "+revision+" "+ @svn_address_destiny + " /tmp/"+@svn_destiny_name)
       else
         puts "checking out repo at "+@svn_address_destiny+ " in /tmp/"+@svn_destiny_name
         system("svn checkout "+@svn_address_destiny + " /tmp/"+@svn_destiny_name)
       end
       @output.puts "SVN destiny Checkout complete"
     end
                                                                  
=begin rdoc
The algorithm do exactly this:
While the revision of both origin and destiny repo are not the same:
  Checkout the origin repo, at destiny revision number.
  Dump current working directory of origin into destiny
  Commit
  Update
  Repit with the next revision.
=end
     def perform_conversion()                                                            
       
       revision_that_we_want_the_destiny_to_be_in = destiny_repo_online_revision().to_i + 1                
       
       continue = true
       while(revision_that_we_want_the_destiny_to_be_in <= @final_revision_that_you_want_to_mirror.to_i and continue) 
         puts "\n\n-------Trying to apply revision #{revision_that_we_want_the_destiny_to_be_in.to_s}, final revision: #{@final_revision_that_you_want_to_mirror} -------\n"         
         perform_conversion_operations(revision_that_we_want_the_destiny_to_be_in.to_s)
         
         if not destiny_repo_online_revision.to_i == revision_that_we_want_the_destiny_to_be_in            
           puts "====Something went wrong, check the log===="
           puts "current destiny_repo_online_revision: #{destiny_repo_online_revision} svn_destiny_revision: #{revision_that_we_want_the_destiny_to_be_in}"
           continue = false
         end           
         revision_that_we_want_the_destiny_to_be_in = revision_that_we_want_the_destiny_to_be_in + 1 
         puts "\n--------------\n"
       end
     end
     
     
     def remove_files_from_destiny_repo_that_were_removed_in_origin_repo()
       # SVN Remove files that are in destiny but are not in origin 
       list_of_files_that_should_be_removed = []
       puts "\n--> Removing files that exist in destiny but are not in origin, which means they were removed and should be scheduled svn rm 'file'\n"
       Dir.glob(File.join("/tmp/#{@svn_destiny_name}", '**', '*')) do |file_path_destiny|
         if not file_path_destiny.include?(".svn")
           file_path_origin = file_path_destiny.gsub(svn_destiny_name, svn_origin_name)
           #Check if it doesnt exist in origin
           if not File.exist?(file_path_origin)
             #Schedule deletion by svn 
             puts "The file #{file_path_destiny} does not exist in #{file_path_origin} and so is scheduled to removal in svn"
             system("svn remove "+file_path_destiny)
             puts "done removing that file\n"
             list_of_files_that_should_be_removed.push(file_path_destiny)
           end          
         end
       end                         

       list_of_files_that_should_be_removed.each do |name|
         puts "file #{name} was removed"
         system("rm -Rf #{name}")
       end                                                

       puts "\n--> Done removing files.\n"      
     end
     
     def remove_SVN_files_from_origin() 
       # Find all .svn in origin and delete them 
       puts "\n--> Removing .svn files from origin\n"
       Dir.glob("/tmp/#{@svn_origin_name}/**/.svn", File::FNM_DOTMATCH) do |file_path_origin|                                    
         puts "Removing .svn file from"+ file_path_origin
         system("rm -Rf #{file_path_origin}")         
       end   
       puts "\n--> End removing files from origin\n"      
     end 
     
     
     def copy_files_from_origin_to_destiny()
       #  Copy files that are in origin to destiny.
       puts "\n--> Copying files from origin to destiny\n"        
       Dir.glob(File.join("/tmp/#{@svn_origin_name}", '**', '*')) do |file_path_origin|                                            
         if not file_path_origin.include?(".svn")                                                
           file_path_destiny = file_path_origin.gsub(svn_origin_name, svn_destiny_name)        
           puts "Copying file from "+file_path_origin+"     to destiny: "+file_path_destiny
           if File.directory?(file_path_origin)
             system("mkdir #{file_path_destiny}")
             puts "Done creating directory #{file_path_destiny} \n"
           else
             system("cp #{file_path_origin} #{file_path_destiny}")  
             puts "Done copying file to #{file_path_destiny} \n"       
           end
         end                                                    
       end                                             
       puts "\n--> End copying files\n"             
     end
     
     
     def check_if_this_is_a_phantom_commit()               
       # system("cd /tmp/"+@svn_destiny_name +" && "+"svn status | grep '^\?' | awk '{print $2}' | xargs svn add"+" && svn commit -m '"+revision_number_that_we_want_to_copy_to_destiny+"'"+ " && "+"svn update") 
       if no_changes_to_update?()
         puts "--> This is a phantom commit. This means that the previous commit and this have exactly the same files. It is not possible to do a commit that doesn't change anything. This either means that either there was an svn error, check the current directory scheme of origin and destiny, or that you just commited a .gitignore file. So we are adding a file 'github_phantom_file' to the repo. This happens when you are using Git and push just a change to .gitignore. Github removes that kind of file, but still make it a new revision."
         system("touch /tmp/#{@svn_destiny_name}/github_phantom_file")
       end       
      
     end                                          
           
     def perform_conversion_operations(revision_number_that_we_want_to_copy_to_destiny)  
       
      # Checkout a temporal repo that will contain the changes –– revision – that we want to apply to destiny
      checkout_origin_repo(revision_number_that_we_want_to_copy_to_destiny)                                                                    
                          
      # In the event that the next revision removed files, we should 'svn rm name' before doing the copy.
      remove_files_from_destiny_repo_that_were_removed_in_origin_repo()                                  
      
      # SVN files like '.svn' contain info about the state of the repo, revision, changes etc. It must not be 
      # copied to the destiny repo or we would be overwriting the destiny repo own '.svn' files. 
      # So we remove them from the temporal origin repo before copying from Origin to Destiny. 
      remove_SVN_files_from_origin()                                                   
      
      # We copy all files from origin repo to Destiny repo. This essencially makes the working directory in destiny identical 
      # to the working directory of origin, whose state is the the revision that we want to apply. 
      # Later we just have to svn add * everything. SVN will automatically add what changed.
      copy_files_from_origin_to_destiny()
                                                    
      # Show the current directory layout in origin and destiny
      # If they are the same, it means the we have a perfect copy. 
      puts "\n\n ======= Current origin schema ======\n"
      list_directory("/tmp/#{svn_origin_name}")           
      puts "\n\n ======= Current destiny schema ======\n" 
      list_directory("/tmp/#{svn_destiny_name}")                 
                                                          
      # Check if it is a phantom commit. Phantom commits are commit that had just changes to .gitignore file. 
      # Github removes that file from the svn revision, so we are left with two subsequent revisions that are exactly 
      # the identical. SVN commit with changes won't do anything. 
      # To evade this problem, we make a fake file, .github file, so we have something to commit. 
      # It will be erased in the next commit, so it won't cause any problem.
      check_if_this_is_a_phantom_commit()      
                      
      # The final stage is to 'svn add *' everything and commit to destiny online repo. If this goes well, we 
      # would have succefully commited the intended revision.
      puts "\n--> We start copy and write process\n"         
      system("cd /tmp/"+@svn_destiny_name +" && "+"svn status | grep '^\?' | awk '{print $2}' | xargs svn add "+ "&& svn commit -m '"+revision_number_that_we_want_to_copy_to_destiny+"'"+ " && "+"svn update")
      puts "\n-->End copy and paste process\n\n" 
      
     end
     
     def no_changes_to_update?()
      system("cd /tmp/#{@svn_destiny_name} && svn status >/tmp/svninfo2")
      if File.zero?("/tmp/svninfo2")
        return true
      else
        return false
      end                       
     end

     def origin_repo_online_revision()
        repo_online_revision(@svn_origin_name)
     end
     
     def destiny_repo_online_revision()
        repo_online_revision(@svn_destiny_name)  
     end
     
     def repo_online_revision(repo)
       system("svn info /tmp/"+repo+" > /tmp/svninfo")
         string_file = ""
         File.open("/tmp/svninfo","r").each do |line|
           string_file += line
         end                                     
         revision_line = /Revision: \d+/.match(string_file).to_s         
         revision = /\d+/.match(revision_line).to_s             
     end 
     
     def list_directory(directory)       
       Dir.glob( File.join(directory, '**', '*') ) { |file| puts file }   
     end
          
   end
end