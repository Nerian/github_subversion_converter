
module Conversor
   class Conversor
     
     attr_accessor :output, :svn_address_origin, :svn_address_destiny, :svn_origin_name, :svn_destiny_name
      
     def initialize(output)
       @output = output    
       @svn_origin_name = "origin"
       @svn_destiny_name = "destiny"  
     end                   
     
     def checkout_origin_repo()
      if(File.exist?("/tmp/"+@svn_origin_name))
        system("rm -Rf /tmp/"+@svn_origin_name) 
      end
      system("svn checkout "+ @svn_address_origin + " /tmp/"+@svn_origin_name)
      @output.puts "SVN origin Checkout complete"      
     end                                       
     
     def checkout_destiny_repo()
       if(File.exist?("/tmp/"+@svn_destiny_name))
         system("rm -Rf /tmp/"+@svn_destiny_name) 
       end
       system("svn checkout "+ @svn_address_destiny + " /tmp/"+@svn_destiny_name)
       @output.puts "SVN destiny Checkout complete"
     end
     
     def perform_conversion()
       
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