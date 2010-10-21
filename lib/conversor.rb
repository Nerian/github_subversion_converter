
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
                        
       checkout_origin_repo()
       @final_revision_that_you_want_to_mirror = origin_repo_online_revision()          
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
         
     def perform_conversion()
       svn_destiny_revision = destiny_repo_online_revision().to_i
     
       while(svn_destiny_revision < @final_revision_that_you_want_to_mirror.to_i)
         perform_conversion_operations(svn_destiny_revision.to_s)
         svn_destiny_revision = svn_destiny_revision + 1 
       end
     end                                
           
     #Hay que hacer los svn rm y svn add analizando la jerarquia
     def perform_conversion_operations(revision_number_that_we_want_to_copy_to_destiny)  
      checkout_origin_repo(revision_number_that_we_want_to_copy_to_destiny)
      system("rm -Rf /tmp/"+@svn_origin_name+"/.svn")      
      system("rm -Rf /tmp/.svn")
      system("cp -Rf /tmp/"+@svn_destiny_name+"/.svn /tmp/.svn" )
      system("rm -Rf /tmp/"+@svn_destiny_name+"/")
      system("cp -Rf /tmp/"+@svn_origin_name+"/ /tmp/"+@svn_destiny_name+"/")
      system("cp -Rf /tmp/.svn /tmp/"+@svn_destiny_name+"/")
      #system("cd /tmp/"+@svn_destiny_name +" && "+"svn add *"+" && svn commit -m '"+revision_number_that_we_want_to_copy_to_destiny+"'"+ " && "+"svn update")
      system("cd /tmp/"+@svn_destiny_name +""+""+" && svn commit -m '"+revision_number_that_we_want_to_copy_to_destiny+"'"+ " && "+"svn update")
      #system("svn add /tmp/"+@svn_destiny_name)
      #system("svn commit -m '"+revision_number_that_we_want_to_copy_to_destiny+"'")
      #system("svn update")      
      
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
         revision_line = /Revision: \d/.match(string_file).to_s         
         revision = /\d/.match(revision_line).to_s             
         puts revision
         revision
     end
          
   end
end