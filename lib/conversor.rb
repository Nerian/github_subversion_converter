
module Conversor
   class Conversor
      
     def initialize(output, name)
       @output = output    
       @svn_name = name  
     end               
     
     def set_svn_origin(svn_origin)
      @svn_origin = svn_origin
     end
     
     def checkout_svn_repo()
      if(File.exist?("rm /temp/"+@svn_name))
        system("rm /temp/"+@svn_name) 
      end
      system("svn checkout "+ @svn_origin + " /tmp/"+@svn_name)
     end
     
   end
end