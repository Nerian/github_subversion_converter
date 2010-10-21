
module Conversor
   class Conversor
                     
     #output is used for Cucumber testing.
     #svn_address_origin is the online address of the svn repo that we can to mirror from
     #svn_address_destiny is the online address of the svn repo that we want to mirror to  
     #svn_origin_name is the name of the checkout origin repo.
     #svn_destiny_name is the name of the checkout destiny repo.
     attr_accessor :output, :svn_address_origin, :svn_address_destiny, :svn_origin_name, :svn_destiny_name, :final_revision_that_you_want_to_mirror
      
     def initialize(output, svn_address_origin, svn_address_destiny)
       @output = output    
       @svn_origin_name = "origin"
       @svn_destiny_name = "destiny"
       @svn_address_origin = svn_address_origin
       @svn_address_destiny = svn_address_destiny
              
       if(final_revision_that_you_want_to_mirror.nil?)                                     
         checkout_origin_repo()
         final_revision_that_you_want_to_mirror = origin_repo_online_revision()
       else
         @final_revision_that_you_want_to_mirror = final_revision_that_you_want_to_mirror  
       end
         
     end                   
     
     def checkout_origin_repo(revision=nil)
      if(File.exist?("/tmp/"+@svn_origin_name))
        system("rm -Rf /tmp/"+@svn_origin_name) 
      end                        
      if not revision.nil?
        system("svn checkout "+"-r "+ revision +" "+@svn_address_origin + " /tmp/"+@svn_origin_name)
      else                                                                                         
        system("svn checkout "+@svn_address_origin + " /tmp/"+@svn_origin_name)
      end
      @output.puts "SVN origin Checkout complete"      
     end                                       
     
     def checkout_destiny_repo(revision=nil)
       if(File.exist?("/tmp/"+@svn_destiny_name))
         system("rm -Rf /tmp/"+@svn_destiny_name) 
       end        
       
       if not revision.nil?         
         system("svn checkout "+"-r "+revision+" "+ @svn_address_destiny + " /tmp/"+@svn_destiny_name)
       else
         system("svn checkout "+@svn_address_destiny + " /tmp/"+@svn_destiny_name)
       end
       @output.puts "SVN destiny Checkout complete"
     end
     
     #I assume that the repository from which you want to mirror has 
     def perform_conversion(revision_number_that_we_want_to_copy_to_destiny = origin_repo_online_revision)                       
       if origin_repo_online_revision == destiny_repo_online_revision
         perform_conversion_operation()
         perform_conversion(revision_number_that_we_want_to_copy_to_destiny+1)         
       else                                                          
         perform_conversion(revision_number_that_we_want_to_copy_to_destiny-1)
       end                     
     end                                
     
     def perform_conversion_operations(revision_number_that_we_want_to_copy_to_destiny)  
      checkout_origin_repo(revision_number_that_we_want_to_copy_to_destiny-1)
      
     end

     def origin_repo_online_revision()
        repo_online_revision(@svn_origin_name)
     end
     
     def destiny_repo_online_revision
        repo_online_revision(@svn_destiny_name)  
     end
     
     def repo_online_revision(repo)
       system("svn info /tmp/"+repo+" > /tmp/svninfo")
         string_file = ""
         File.open("/tmp/svninfo","r").each do |line|
           string_file += line
         end                                     
         revision_line = /Revision: \d/.match(string_file).to_s
         revision = /\d/.match(revision_line).to_s
     end
          
   end
end