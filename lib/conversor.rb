require 'find'

module Conversor
   class Conversor
                     
     #output is used for Cucumber testing.
     #svn_address_origin is the online address of the svn repo that we can to mirror from
     #svn_address_destiny is the online address of the svn repo that we want to mirror to  
     #svn_origin_name is the name of the checkout origin repo.
     #svn_destiny_name is the name of the checkout destiny repo.
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
         puts "-------Trying to apply revision #{revision_that_we_want_the_destiny_to_be_in.to_s}, final revision: #{@final_revision_that_you_want_to_mirror} -------"         
         perform_conversion_operations(revision_that_we_want_the_destiny_to_be_in.to_s)
         
         if not destiny_repo_online_revision.to_i == revision_that_we_want_the_destiny_to_be_in            
           puts "====Something went wrong, check the log===="
           puts "destiny_repo_online_revision: #{destiny_repo_online_revision} svn_destiny_revision: #{revision_that_we_want_the_destiny_to_be_in}"
           continue = false
         end           
         revision_that_we_want_the_destiny_to_be_in = revision_that_we_want_the_destiny_to_be_in + 1 
         puts "--------------"
       end
     end                                
           
     def perform_conversion_operations(revision_number_that_we_want_to_copy_to_destiny)  
      checkout_origin_repo(revision_number_that_we_want_to_copy_to_destiny)                                                                    
      
      # SVN Remove files that are in destiny but are not in origin 
      list_of_files_that_should_be_removed = []
      Dir.glob(File.join("/tmp/#{@svn_destiny_name}", '**', '*')) do |file_path_destiny|
        if not file_path_destiny.include?(".svn")
          file_path_origin = file_path_destiny.gsub(svn_destiny_name, svn_origin_name)
          #Check if it doesnt exist in origin
          if not File.exist?(file_path_origin)
            #Schedule deletion by svn 
            puts "The file #{file_path_destiny} does not exist in #{file_path_origin} and so is scheduled to removal in svn"
            system("svn remove "+file_path_destiny)
            list_of_files_that_should_be_removed.push(file_path_destiny)
          end          
        end
      end                         
      
      list_of_files_that_should_be_removed.each do |name|
        puts "file #{name} was removed"
        system("rm -Rf #{name}")
      end                                                
      
      puts "\n--> Done removing files.\n"
          
      # Find all .svn in origin and delete them 
      puts "\n--> Removing .svn files from origin\n"
      Dir.glob("/tmp/#{@svn_origin_name}/**/.svn", File::FNM_DOTMATCH) do |file_path_origin|                                    
        puts "Removing .svn file from"+ file_path_origin
        system("rm -Rf #{file_path_origin}")         
      end   
      puts "\n--> End removing files from origin\n"                        
            
      #  Copy files that are in origin to destiny.
      puts "\n--> Copying files from origin to destiny\n"        
      Dir.glob(File.join("/tmp/#{@svn_origin_name}", '**', '*')) do |file_path_origin|                                            
        if not file_path_origin.include?(".svn")                                                
          file_path_destiny = file_path_origin.gsub(svn_origin_name, svn_destiny_name)        
          puts "Copying file from "+file_path_origin+"     to destiny: "+file_path_destiny
          if File.directory?(file_path_origin)
            system("mkdir #{file_path_destiny}")
          else
            system("cp "+file_path_origin+" "+file_path_destiny)         
          end
        end                                                    
      end                            
                 
      puts "\n--> End copying files\n" 
      
      puts "\n\n ======= Current origin schema ======\n"
      list_directory("/tmp/#{svn_origin_name}")
      puts "\n\n ======= Current destiny schema ======\n" 
      list_directory("/tmp/#{svn_destiny_name}")                 
                            
      puts "\n--> We start copy and write process "
      
      
      
      # Check if it is a phantom commit. Phantom commits are commit that had just changes to .gitignore file. 
      # Github removes that file from the svn revision, so we are left with two subsequent revisions that are exactly 
      # the identical. SVN commit with changes won't do anything. 
      # To evade this problem, we make a fake file, .github file, so we have something to commit. 
      # It will be erased in the next commit, so it won't cause any problem.  
      
      # system("cd /tmp/"+@svn_destiny_name +" && "+"svn status | grep '^\?' | awk '{print $2}' | xargs svn add"+" && svn commit -m '"+revision_number_that_we_want_to_copy_to_destiny+"'"+ " && "+"svn update") 
      if no_changes_to_update?()
        system("touch /tmp/#{@svn_destiny_name}/github_phantom_file")
      end
        
      system("cd /tmp/"+@svn_destiny_name +" && "+"svn status | grep '^\?' | awk '{print $2}' | xargs svn add "+ "&& svn commit -m '"+revision_number_that_we_want_to_copy_to_destiny+"'"+ " && "+"svn update")
      puts "\n-->End copy and paste process\n" 
      
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
         puts revision
         revision
     end 
     
     def list_directory(directory)       
       Dir.glob( File.join(directory, '**', '*') ) { |file| puts file }   
     end
          
   end
end